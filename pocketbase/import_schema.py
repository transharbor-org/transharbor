#!/usr/bin/env python3
"""
Prepare PocketBase schema for import by handling circular rule dependencies.
1. Create batches with rules stripped for initial import
2. Generate rule update commands for after import
"""
import json
import sys
import os

def get_dependencies(collection, include_rules=True):
    """Extract collection names this collection depends on."""
    deps = set()
    
    # Dependencies from relation fields
    for field in collection.get('fields', []):
        if field.get('type') == 'relation':
            coll_id = field.get('collectionId', '')
            if coll_id == '_pb_users_auth_':
                deps.add('users')
            elif not coll_id.startswith('_pb_') and not coll_id.startswith('pbc_'):
                deps.add(coll_id)
    
    # Dependencies from rules (only if requested)
    if include_rules:
        import re
        rules = [
            collection.get('listRule', ''),
            collection.get('viewRule', ''),
            collection.get('createRule', ''),
            collection.get('updateRule', ''),
            collection.get('deleteRule', '')
        ]
        
        for rule in rules:
            if rule:
                matches = re.findall(r'@collection\.([a-z_]+)', rule)
                for match in matches:
                    if match == 'users':
                        deps.add('users')
                    elif not match.startswith('_'):
                        deps.add(match)
    
    return deps

def strip_rules(collection):
    """Create a copy of collection without access rules."""
    coll_copy = collection.copy()
    coll_copy['listRule'] = None
    coll_copy['viewRule'] = None
    coll_copy['createRule'] = None
    coll_copy['updateRule'] = None
    coll_copy['deleteRule'] = None
    return coll_copy

def create_batches(collections):
    """Create batches of collections in dependency order (by fields only)."""
    # Separate auth and base collections
    auth_colls = [c for c in collections if c.get('type') == 'auth']
    base_colls = [c for c in collections if c.get('type') == 'base']
    
    batches = []
    
    # Batch 1: Auth collections (no dependencies)
    if auth_colls:
        batches.append([strip_rules(c) for c in auth_colls])
    
    # Process base collections by dependency level (fields only, ignore rules)
    remaining = base_colls.copy()
    created = set(c['name'] for c in auth_colls)
    
    max_iterations = len(base_colls) + 1
    iteration = 0
    
    while remaining and iteration < max_iterations:
        iteration += 1
        batch = []
        
        # Check which collections can be added (don't update created set yet)
        for coll in remaining:
            deps = get_dependencies(coll, include_rules=False)  # Only field deps
            if deps.issubset(created):
                batch.append(strip_rules(coll))  # Strip rules for import
        
        if batch:
            batches.append(batch)
            for coll in batch:
                created.add(coll['name'])
            remaining = [c for c in remaining if c['name'] not in created]
        else:
            if remaining:
                batches.append([strip_rules(c) for c in remaining])
            break
    
    return batches

def main():
    if len(sys.argv) < 2:
        print("Usage: import_schema.py <schema.json>", file=sys.stderr)
        sys.exit(1)
    
    with open(sys.argv[1], 'r') as f:
        collections = json.load(f)
    
    # Create batches for import (without rules)
    batches = create_batches(collections)
    
    # Output batches as JSON files
    for i, batch in enumerate(batches, 1):
        output = {
            "collections": batch,
            "deleteMissing": False
        }
        filename = f"/tmp/batch{i}.json"
        with open(filename, 'w') as f:
            json.dump(output, f)
        
        names = [c['name'] for c in batch]
        print(f"Batch {i}: {len(batch)} collections - {', '.join(names)}")
    
    # Save original collections with rules for later update
    with open('/tmp/collections_with_rules.json', 'w') as f:
        json.dump(collections, f)
    
    print(f"Created {len(batches)} batches (rules stripped for import)")

if __name__ == '__main__':
    main()

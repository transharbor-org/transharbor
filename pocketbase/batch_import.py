#!/usr/bin/env python3
"""
Split PocketBase schema into batches for import to handle dependencies.
"""
import json
import sys

def get_dependencies(collection):
    """Extract collection names this collection depends on via relations."""
    deps = set()
    for field in collection.get('fields', []):
        if field.get('type') == 'relation':
            coll_id = field.get('collectionId', '')
            # Map special IDs back to collection names
            if coll_id == '_pb_users_auth_':
                deps.add('users')
            elif not coll_id.startswith('_pb_') and not coll_id.startswith('pbc_'):
                # Regular collection name reference
                deps.add(coll_id)
    return deps

def create_batches(collections):
    """Create batches of collections in dependency order."""
    # Separate auth and base collections
    auth_colls = [c for c in collections if c.get('type') == 'auth']
    base_colls = [c for c in collections if c.get('type') == 'base']
    
    batches = []
    
    # Batch 1: Auth collections (no dependencies)
    if auth_colls:
        batches.append(auth_colls)
    
    # Process base collections by dependency level
    remaining = base_colls.copy()
    created = set(c['name'] for c in auth_colls)
    
    max_iterations = len(base_colls) + 1
    iteration = 0
    
    while remaining and iteration < max_iterations:
        iteration += 1
        batch = []
        
        # Check which collections can be added (don't update created set yet)
        for coll in remaining:
            deps = get_dependencies(coll)
            # Can add if all dependencies are created
            if deps.issubset(created):
                batch.append(coll)
        
        if batch:
            batches.append(batch)
            # Now update created set for next iteration
            for coll in batch:
                created.add(coll['name'])
            remaining = [c for c in remaining if c not in batch]
        else:
            # No progress, add all remaining (circular deps or errors)
            if remaining:
                batches.append(remaining)
            break
    
    return batches

def main():
    if len(sys.argv) < 2:
        print("Usage: batch_import.py <schema.json>", file=sys.stderr)
        sys.exit(1)
    
    with open(sys.argv[1], 'r') as f:
        collections = json.load(f)
    
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
    
    print(f"Created {len(batches)} batches")

if __name__ == '__main__':
    main()

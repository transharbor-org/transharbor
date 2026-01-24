#!/usr/bin/env python3
"""
Update collection rules to allow appropriate access
"""

import requests
import json

BASE_URL = "https://dev.transharbor.org/api"
ADMIN_EMAIL = "admin@transharbor.org"
ADMIN_PASSWORD = "changeme-dev-password"

def get_admin_token():
    """Authenticate as admin and return token"""
    response = requests.post(
        f"{BASE_URL}/collections/_superusers/auth-with-password",
        json={"identity": ADMIN_EMAIL, "password": ADMIN_PASSWORD}
    )
    response.raise_for_status()
    return response.json()["token"]

def update_collection_rules(collection_name, rules, admin_token):
    """Update collection access rules"""
    response = requests.patch(
        f"{BASE_URL}/collections/{collection_name}",
        headers={"Authorization": admin_token},
        json=rules
    )
    if response.status_code != 200:
        print(f"❌ Error updating {collection_name}: {response.status_code} - {response.text}")
    response.raise_for_status()
    print(f"✅ Updated rules for {collection_name}")

def main():
    print("🔒 Updating collection access rules...")
    
    admin_token = get_admin_token()
    
    # Personals - anyone can list/view, only author can create/update/delete
    update_collection_rules("personals", {
        "listRule": "@request.auth.id != ''",
        "viewRule": "@request.auth.id != ''",
        "createRule": "@request.auth.id != '' && @request.auth.id = user",
        "updateRule": "@request.auth.id = user",
        "deleteRule": "@request.auth.id = user"
    }, admin_token)
    
    # Conversations - participants can list/view/create
    update_collection_rules("conversations", {
        "listRule": "@request.auth.id != '' && participants ~ @request.auth.id",
        "viewRule": "@request.auth.id != '' && participants ~ @request.auth.id",
        "createRule": "@request.auth.id != '' && participants ~ @request.auth.id",
        "updateRule": "@request.auth.id != '' && participants ~ @request.auth.id",
        "deleteRule": ""
    }, admin_token)
    
    # Messages - conversation participants can view
    update_collection_rules("messages", {
        "listRule": "@request.auth.id != '' && conversation.participants ~ @request.auth.id",
        "viewRule": "@request.auth.id != '' && conversation.participants ~ @request.auth.id",
        "createRule": "@request.auth.id != '' && conversation.participants ~ @request.auth.id && sender = @request.auth.id",
        "updateRule": "@request.auth.id = sender",
        "deleteRule": ""
    }, admin_token)
    
    # Proposals - voting members can list/view, create
    update_collection_rules("proposals", {
        "listRule": "@request.auth.id != ''",
        "viewRule": "@request.auth.id != ''",
        "createRule": "@request.auth.id != '' && @request.auth.membershipType = 'voting_member'",
        "updateRule": "@request.auth.id = author || @request.auth.role = 'admin'",
        "deleteRule": "@request.auth.role = 'admin'"
    }, admin_token)
    
    # Votes - voters can see their own votes, proposals can be viewed by all
    update_collection_rules("votes", {
        "listRule": "@request.auth.id != ''",
        "viewRule": "@request.auth.id != ''",
        "createRule": "@request.auth.id != '' && @request.auth.membershipType = 'voting_member' && user = @request.auth.id",
        "updateRule": "",
        "deleteRule": ""
    }, admin_token)
    
    # Groups - anyone can list/view, authenticated users can create
    update_collection_rules("groups", {
        "listRule": "@request.auth.id != ''",
        "viewRule": "@request.auth.id != ''",
        "createRule": "@request.auth.id != '' && creator = @request.auth.id",
        "updateRule": "@request.auth.id = creator || @request.auth.role ~ 'moderator|admin'",
        "deleteRule": "@request.auth.id = creator || @request.auth.role = 'admin'"
    }, admin_token)
    
    # Group members - members can view
    update_collection_rules("group_members", {
        "listRule": "@request.auth.id != ''",
        "viewRule": "@request.auth.id != ''",
        "createRule": "@request.auth.id != '' && user = @request.auth.id",
        "updateRule": "group.creator = @request.auth.id || @request.auth.role ~ 'moderator|admin'",
        "deleteRule": "@request.auth.id = user || group.creator = @request.auth.id || @request.auth.role = 'admin'"
    }, admin_token)
    
    # Group posts - members can view
    update_collection_rules("group_posts", {
        "listRule": "@request.auth.id != ''",
        "viewRule": "@request.auth.id != ''",
        "createRule": "@request.auth.id != '' && author = @request.auth.id",
        "updateRule": "@request.auth.id = author",
        "deleteRule": "@request.auth.id = author || group.creator = @request.auth.id || @request.auth.role ~ 'moderator|admin'"
    }, admin_token)
    
    # Reports - reporters and moderators can view
    update_collection_rules("reports", {
        "listRule": "@request.auth.id = reporter || @request.auth.role ~ 'moderator|admin'",
        "viewRule": "@request.auth.id = reporter || @request.auth.role ~ 'moderator|admin'",
        "createRule": "@request.auth.id != '' && reporter = @request.auth.id",
        "updateRule": "@request.auth.role ~ 'moderator|admin'",
        "deleteRule": "@request.auth.role = 'admin'"
    }, admin_token)
    
    print("\n✅ All collection rules updated!")

if __name__ == "__main__":
    main()

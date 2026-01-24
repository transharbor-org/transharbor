#!/usr/bin/env python3
"""
Seed mock data for TransHarbor development/testing
Creates users, posts, messages, proposals, and votes
"""

import requests
import json
from datetime import datetime, timedelta
import random

BASE_URL = "https://dev.transharbor.org/api"
ADMIN_EMAIL = "admin@transharbor.org"
ADMIN_PASSWORD = "changeme-dev-password"

# Mock user data
MOCK_USERS = [
    {
        "username": "alex_river",
        "email": "alex@example.com",
        "password": "password123",
        "name": "Alex Rivera",
        "bio": "Trans activist and software developer. Building community through technology 🏳️‍⚧️",
        "role": "user",
        "membership_type": "voting_member"
    },
    {
        "username": "sam_chen",
        "email": "sam@example.com",
        "password": "password123",
        "name": "Sam Chen",
        "bio": "Non-binary artist and community organizer. They/them pronouns.",
        "role": "user",
        "membership_type": "voting_member"
    },
    {
        "username": "jordan_blake",
        "email": "jordan@example.com",
        "password": "password123",
        "name": "Jordan Blake",
        "bio": "Trans educator advocating for inclusive spaces. She/her.",
        "role": "moderator",
        "membership_type": "voting_member"
    },
    {
        "username": "casey_moore",
        "email": "casey@example.com",
        "password": "password123",
        "name": "Casey Moore",
        "bio": "Genderfluid writer and poet. Any pronouns welcome 💜",
        "role": "user",
        "membership_type": "voting_member"
    },
    {
        "username": "riley_nguyen",
        "email": "riley@example.com",
        "password": "password123",
        "name": "Riley Nguyen",
        "bio": "Trans healthcare advocate working to improve access for all.",
        "role": "user",
        "membership_type": "non_voting"
    },
    {
        "username": "taylor_kim",
        "email": "taylor@example.com",
        "password": "password123",
        "name": "Taylor Kim",
        "bio": "Non-binary musician and sound engineer. Creating safe spaces through art.",
        "role": "user",
        "membership_type": "voting_member"
    }
]

PERSONAL_POSTS = [
    "Just hit my 2 year HRT anniversary! Feeling grateful for this amazing community 🎉",
    "Anyone else find it exhausting constantly having to come out in new spaces? Need some solidarity today.",
    "Reminder: Your identity is valid regardless of medical transition. You are enough as you are 💙💗🤍💗💙",
    "Had such a great time at the trans meetup today! Love seeing our community thrive in person.",
    "Does anyone have recommendations for trans-friendly therapists in the area?",
    "Celebrating another year of being my authentic self! This journey has been challenging but so worth it.",
    "Pro tip: Found an amazing gender-affirming clothing store downtown. DM me for details!",
    "Sometimes the weight of constantly educating people is exhausting. Taking a self-care day today.",
]

PROPOSALS = [
    {
        "title": "Establish Community Guidelines Enforcement Team",
        "description": "Proposal to create a dedicated team of moderators to enforce community guidelines and handle reports. Team would consist of 3-5 voting members elected quarterly.",
        "category": "governance"
    },
    {
        "title": "Monthly Community Virtual Meetups",
        "description": "Organize monthly virtual meetups for community members to connect, share experiences, and build relationships in a safe online space.",
        "category": "community"
    },
    {
        "title": "Resource Library for Trans Healthcare",
        "description": "Create and maintain a comprehensive resource library with information about trans healthcare providers, insurance navigation, and medical transition resources.",
        "category": "resources"
    },
    {
        "title": "Partner with Local LGBTQ+ Organizations",
        "description": "Establish partnerships with 2-3 local LGBTQ+ organizations to expand our reach and provide additional resources to community members.",
        "category": "partnerships"
    }
]

MESSAGES = [
    "Hey! Just wanted to reach out and say welcome to the community!",
    "Thanks so much! Really excited to be here and connect with everyone.",
    "Have you been to any of the meetups? They're really great.",
    "Not yet, but I'm planning to attend the next one!",
    "Did you see the proposal about the community guidelines? Would love to hear your thoughts.",
    "Yeah, I think it's a great idea. We definitely need clearer enforcement.",
    "Totally agree. I'm planning to vote yes on it.",
]


def get_admin_token():
    """Authenticate as admin and return token"""
    response = requests.post(
        f"{BASE_URL}/collections/_superusers/auth-with-password",
        json={"identity": ADMIN_EMAIL, "password": ADMIN_PASSWORD}
    )
    response.raise_for_status()
    return response.json()["token"]


def create_user(user_data, admin_token):
    """Create a user account"""
    # Create auth account
    create_data = {
        "username": user_data["username"],
        "email": user_data["email"],
        "emailVisibility": True,
        "password": user_data["password"],
        "passwordConfirm": user_data["password"],
        "name": user_data["name"],
        "bio": user_data["bio"],
        "role": user_data["role"],
        "membership_type": user_data["membership_type"]
    }
    
    response = requests.post(
        f"{BASE_URL}/collections/users/records",
        headers={"Authorization": admin_token},
        json=create_data
    )
    response.raise_for_status()
    return response.json()


def get_user_token(email, password):
    """Get auth token for a user"""
    response = requests.post(
        f"{BASE_URL}/collections/users/auth-with-password",
        json={"identity": email, "password": password}
    )
    response.raise_for_status()
    return response.json()["token"], response.json()["record"]["id"]


def create_personal_post(content, user_id, admin_token):
    """Create a personal post (using admin token to bypass rules)"""
    response = requests.post(
        f"{BASE_URL}/collections/personals/records",
        headers={"Authorization": admin_token},
        json={
            "user": user_id,
            "content": content,
            "likes": 0,
            "comments": 0
        }
    )
    if response.status_code != 200:
        print(f"    ❌ Error creating post: {response.status_code} - {response.text}")
    response.raise_for_status()
    return response.json()


def create_proposal(proposal_data, user_id, admin_token):
    """Create a governance proposal (using admin token to bypass rules)"""
    start_date = datetime.now().isoformat() + "Z"
    end_date = (datetime.now() + timedelta(days=7)).isoformat() + "Z"
    
    response = requests.post(
        f"{BASE_URL}/collections/proposals/records",
        headers={"Authorization": admin_token},
        json={
            "author": user_id,
            "title": proposal_data["title"],
            "description": proposal_data["description"],
            "status": "active",
            "votesFor": 0,
            "votesAgainst": 0,
            "votesAbstain": 0,
            "startDate": start_date,
            "endDate": end_date
        }
    )
    if response.status_code != 200:
        print(f"    ❌ Error creating proposal: {response.status_code} - {response.text}")
    response.raise_for_status()
    return response.json()


def create_vote(proposal_id, vote_type, user_id, admin_token):
    """Cast a vote on a proposal (using admin token to bypass rules)"""
    response = requests.post(
        f"{BASE_URL}/collections/votes/records",
        headers={"Authorization": admin_token},
        json={
            "proposal": proposal_id,
            "user": user_id,
            "vote_type": vote_type
        }
    )
    response.raise_for_status()
    return response.json()


def create_conversation(participant_ids, admin_token):
    """Create a conversation between users"""
    response = requests.post(
        f"{BASE_URL}/collections/conversations/records",
        headers={"Authorization": admin_token},
        json={
            "participants": participant_ids,
            "lastMessage": "",
            "lastMessageTime": datetime.now().isoformat() + "Z",
            "unreadCount": {}
        }
    )
    response.raise_for_status()
    return response.json()


def create_message(conversation_id, sender_id, content, admin_token):
    """Create a message in a conversation (using admin token to bypass rules)"""
    response = requests.post(
        f"{BASE_URL}/collections/messages/records",
        headers={"Authorization": admin_token},
        json={
            "conversation": conversation_id,
            "sender": sender_id,
            "content": content,
            "read": False
        }
    )
    response.raise_for_status()
    return response.json()


def main():
    print("🌱 Starting TransHarbor mock data seeding...")
    
    # Get admin token
    print("\n🔑 Authenticating as admin...")
    admin_token = get_admin_token()
    print("✅ Admin authenticated")
    
    # Create users
    print("\n👥 Creating mock users...")
    created_users = []
    for user_data in MOCK_USERS:
        try:
            user = create_user(user_data, admin_token)
            created_users.append({
                "id": user["id"],
                "email": user_data["email"],
                "password": user_data["password"],
                "username": user_data["username"],
                "name": user_data["name"]
            })
            print(f"  ✅ Created user: {user_data['username']}")
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 400:
                print(f"  ⚠️  User {user_data['username']} already exists, fetching...")
                # Still add to list for token retrieval
                created_users.append({
                    "id": None,  # Will be filled when getting token
                    "email": user_data["email"],
                    "password": user_data["password"],
                    "username": user_data["username"],
                    "name": user_data["name"]
                })
            else:
                raise
    
    # Get user tokens
    print("\n🔐 Getting user tokens...")
    user_tokens = {}
    for user in created_users:
        token, user_id = get_user_token(user["email"], user["password"])
        user["token"] = token
        user["id"] = user_id
        user_tokens[user["username"]] = token
    
    # Create personal posts
    print("\n📝 Creating personal posts...")
    for i, post_content in enumerate(PERSONAL_POSTS):
        user = created_users[i % len(created_users)]
        create_personal_post(post_content, user["id"], admin_token)
        print(f"  ✅ {user['name']} posted")
    
    # Create proposals
    print("\n🗳️  Creating governance proposals...")
    created_proposals = []
    for i, proposal in enumerate(PROPOSALS):
        user = created_users[i % len(created_users)]
        prop = create_proposal(proposal, user["id"], admin_token)
        created_proposals.append(prop)
        print(f"  ✅ {user['name']}: {proposal['title']}")
    
    # Cast votes on proposals
    print("\n✅ Casting votes on proposals...")
    for proposal in created_proposals:
        # Random voting: 60-80% vote yes, rest vote no
        for user in created_users:
            # Only voting members can vote
            if random.random() < 0.8:  # 80% participation rate
                vote_type = "for" if random.random() < 0.7 else "against"
                try:
                    create_vote(proposal["id"], vote_type, user["id"], admin_token)
                    print(f"  ✅ {user['name']} voted {vote_type} on '{proposal['title'][:40]}...'")
                except:
                    pass  # Skip if already voted
    
    # Create conversations and messages
    print("\n💬 Creating conversations and messages...")
    # Create 3 conversations between different pairs
    conversation_pairs = [
        (created_users[0], created_users[1]),
        (created_users[2], created_users[3]),
        (created_users[0], created_users[4])
    ]
    
    for user1, user2 in conversation_pairs:
        conv = create_conversation([user1["id"], user2["id"]], admin_token)
        print(f"  💬 Conversation: {user1['name']} ↔️ {user2['name']}")
        
        # Add 3-4 messages to each conversation
        num_messages = random.randint(3, 4)
        for i in range(num_messages):
            sender = user1 if i % 2 == 0 else user2
            message_content = MESSAGES[i % len(MESSAGES)]
            create_message(conv["id"], sender["id"], message_content, admin_token)
            print(f"    ✉️  {sender['name']}: {message_content[:50]}...")
    
    print("\n🎉 Mock data seeding complete!")
    print(f"\n📊 Summary:")
    print(f"  • {len(created_users)} users created")
    print(f"  • {len(PERSONAL_POSTS)} personal posts created")
    print(f"  • {len(created_proposals)} governance proposals created")
    print(f"  • ~{len(created_users) * len(created_proposals) * 0.8:.0f} votes cast")
    print(f"  • {len(conversation_pairs)} conversations with {len(conversation_pairs) * 3} messages")
    print(f"\n💡 All mock users have password: password123")


if __name__ == "__main__":
    main()

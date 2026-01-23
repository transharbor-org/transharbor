-- Phone Verification Collection Schema
-- This is a reference schema for PocketBase
-- Apply via PocketBase Admin UI or API

{
  "name": "phone_verification",
  "type": "base",
  "schema": [
    {
      "name": "phone",
      "type": "text",
      "required": true,
      "options": {
        "min": 10,
        "max": 20,
        "pattern": "^\\+[1-9]\\d{1,14}$"
      }
    },
    {
      "name": "otp",
      "type": "text",
      "required": true,
      "options": {
        "min": 6,
        "max": 6,
        "pattern": "^\\d{6}$"
      }
    },
    {
      "name": "verified",
      "type": "bool",
      "required": true
    },
    {
      "name": "expires_at",
      "type": "date",
      "required": true
    }
  ],
  "indexes": [
    "CREATE INDEX idx_phone_verification_phone ON phone_verification (phone)",
    "CREATE INDEX idx_phone_verification_verified ON phone_verification (verified)"
  ],
  "listRule": null,
  "viewRule": null,
  "createRule": "@request.auth.id != ''",
  "updateRule": null,
  "deleteRule": null,
  "options": {}
}

-- Users Collection Updates
-- Add phone fields to existing users collection

{
  "name": "users",
  "type": "auth",
  "schema": [
    {
      "name": "phone",
      "type": "text",
      "required": true,
      "unique": true,
      "options": {
        "min": 10,
        "max": 20,
        "pattern": "^\\+[1-9]\\d{1,14}$"
      }
    },
    {
      "name": "phoneVerified",
      "type": "bool",
      "required": true
    },
    {
      "name": "name",
      "type": "text",
      "required": false,
      "options": {
        "min": 1,
        "max": 100
      }
    }
  ],
  "indexes": [
    "CREATE UNIQUE INDEX idx_users_phone ON users (phone)"
  ],
  "listRule": "id = @request.auth.id",
  "viewRule": "id = @request.auth.id",
  "createRule": "",
  "updateRule": "id = @request.auth.id",
  "deleteRule": "id = @request.auth.id",
  "options": {
    "allowEmailAuth": false,
    "allowOAuth2Auth": false,
    "allowUsernameAuth": false,
    "exceptEmailDomains": null,
    "manageRule": null,
    "minPasswordLength": 8,
    "onlyEmailDomains": null,
    "requireEmail": false
  }
}

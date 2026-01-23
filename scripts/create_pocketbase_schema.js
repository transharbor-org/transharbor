#!/usr/bin/env node

/**
 * TransHarbor PocketBase Schema Creator
 * 
 * This script automatically creates all PocketBase collections via the Admin API
 * 
 * Usage:
 *   1. Start PocketBase: cd pocketbase && ./pocketbase serve
 *   2. Create admin account via http://127.0.0.1:8090/_/
 *   3. Run this script: node scripts/create_pocketbase_schema.js
 * 
 * Or set environment variables:
 *   POCKETBASE_URL=http://127.0.0.1:8090
 *   POCKETBASE_ADMIN_EMAIL=admin@example.com
 *   POCKETBASE_ADMIN_PASSWORD=yourpassword
 */

const readline = require('readline');

const POCKETBASE_URL = process.env.POCKETBASE_URL || 'http://127.0.0.1:8090';
const ADMIN_EMAIL = process.env.POCKETBASE_ADMIN_EMAIL;
const ADMIN_PASSWORD = process.env.POCKETBASE_ADMIN_PASSWORD;

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

async function authenticateAdmin(email, password) {
  console.log('🔐 Authenticating admin...');
  
  const response = await fetch(`${POCKETBASE_URL}/api/admins/auth-with-password`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      identity: email,
      password: password,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Authentication failed: ${error}`);
  }

  const data = await response.json();
  console.log('✓ Authenticated successfully');
  return data.token;
}

async function createCollection(token, collection) {
  console.log(`📦 Creating collection: ${collection.name}`);
  
  const response = await fetch(`${POCKETBASE_URL}/api/collections`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    },
    body: JSON.stringify(collection),
  });

  if (!response.ok) {
    const error = await response.text();
    
    // Check if collection already exists
    if (error.includes('already exists')) {
      console.log(`  ⚠️  Collection already exists: ${collection.name}`);
      return { exists: true };
    }
    
    throw new Error(`Failed to create ${collection.name}: ${error}`);
  }

  console.log(`  ✓ Created: ${collection.name}`);
  return await response.json();
}

async function main() {
  console.log('🚀 TransHarbor PocketBase Schema Creator');
  console.log('========================================\n');

  try {
    // Get admin credentials
    let email = ADMIN_EMAIL;
    let password = ADMIN_PASSWORD;

    if (!email) {
      email = await question('Admin email: ');
    }

    if (!password) {
      password = await question('Admin password: ');
    }

    console.log('');

    // Authenticate
    const token = await authenticateAdmin(email, password);

    // Load schema
    const fs = require('fs');
    const path = require('path');
    const schemaPath = path.join(__dirname, '..', 'pb_schema.json');
    
    if (!fs.existsSync(schemaPath)) {
      throw new Error('pb_schema.json not found! Make sure it exists in the project root.');
    }

    const collections = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
    console.log(`📋 Found ${collections.length} collections to create\n`);

    // Create collections
    let created = 0;
    let existing = 0;

    for (const collection of collections) {
      try {
        const result = await createCollection(token, collection);
        if (result.exists) {
          existing++;
        } else {
          created++;
        }
      } catch (error) {
        console.error(`  ❌ Error: ${error.message}`);
      }
    }

    console.log('\n✅ Schema creation complete!');
    console.log(`   Created: ${created} collections`);
    console.log(`   Existing: ${existing} collections`);
    console.log('\n🔗 PocketBase Admin: ' + POCKETBASE_URL + '/_/');
    console.log('🔗 API Base URL: ' + POCKETBASE_URL + '/api/');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  } finally {
    rl.close();
  }
}

// Check if fetch is available (Node 18+)
if (typeof fetch === 'undefined') {
  console.error('❌ This script requires Node.js 18 or later (for native fetch support)');
  console.log('   Please upgrade Node.js or use: npm install node-fetch');
  process.exit(1);
}

main();

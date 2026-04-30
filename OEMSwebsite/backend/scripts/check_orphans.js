const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkOrphans() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: process.env.SSL_MODE === 'REQUIRED' ? { rejectUnauthorized: false } : null,
  });

  console.log('Checking Operational Funds for orphans...');
  const [opOrphans] = await connection.query(`
    SELECT id, from_user_id, to_user_id FROM operational_funds
    WHERE from_user_id NOT IN (SELECT id FROM users)
       OR to_user_id NOT IN (SELECT id FROM users)
  `);
  console.log(`Found ${opOrphans.length} operational fund orphans.`);
  opOrphans.forEach(o => console.log(`- ID: ${o.id}, From: ${o.from_user_id}, To: ${o.to_user_id}`));

  console.log('\nChecking Expansion Funds for orphans...');
  const [exOrphans] = await connection.query(`
    SELECT id, manager_id FROM expansion_funds
    WHERE manager_id NOT IN (SELECT id FROM users)
  `);
  console.log(`Found ${exOrphans.length} expansion fund orphans.`);
  exOrphans.forEach(o => console.log(`- ID: ${o.id}, Manager: ${o.manager_id}`));

  await connection.end();
}

checkOrphans().catch(console.error);

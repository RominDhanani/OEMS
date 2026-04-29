const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkDatabase() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: { rejectUnauthorized: false }
  });

  const [tables] = await connection.query('SHOW TABLES');
  const tableNames = tables.map(t => Object.values(t)[0]);
  console.log('Tables found:', tableNames.length);

  for (const tableName of tableNames) {
    const [count] = await connection.query(`SELECT COUNT(*) as count FROM ${tableName}`);
    console.log(`- ${tableName}: ${count[0].count} rows`);
  }

  await connection.end();
}

checkDatabase().catch(console.error);

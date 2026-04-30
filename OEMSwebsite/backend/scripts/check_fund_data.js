const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkData() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: process.env.SSL_MODE === 'REQUIRED' ? { rejectUnauthorized: false } : null,
  });

  try {
    const [opFunds] = await connection.query('SELECT * FROM operational_funds LIMIT 5');
    console.log('Operational Funds sample:', opFunds);

    const [expFunds] = await connection.query('SELECT * FROM expansion_funds LIMIT 5');
    console.log('Expansion Funds sample:', expFunds);
  } catch (err) {
    console.error(err);
  } finally {
    await connection.end();
  }
}

checkData();

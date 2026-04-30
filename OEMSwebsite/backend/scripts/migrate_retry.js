require('dotenv').config();
const mysql = require('mysql2/promise');

async function migrate() {
  const config = {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: { rejectUnauthorized: false },
    connectTimeout: 60000, // 60 seconds timeout
  };

  let attempts = 0;
  const maxAttempts = 3;

  while (attempts < maxAttempts) {
    attempts++;
    console.log(`Migration attempt ${attempts}...`);
    let connection;
    try {
      connection = await mysql.createConnection(config);
      console.log('Connected to database.');

      const sql = `
        ALTER TABLE expenses 
        MODIFY COLUMN status ENUM(
          'PENDING_APPROVAL',
          'APPROVED',
          'REJECTED',
          'RECEIPT_APPROVED',
          'FUND_ALLOCATED',
          'COMPLETED',
          'EXPANSION_REQUESTED'
        ) DEFAULT 'PENDING_APPROVAL'
      `;

      console.log('Executing ALTER TABLE...');
      await connection.query(sql);
      console.log('ENUM Update Success!');
      process.exit(0);
    } catch (err) {
      console.error(`Attempt ${attempts} failed:`, err.message);
      if (attempts === maxAttempts) {
        console.error('All attempts failed.');
        process.exit(1);
      }
      console.log('Retrying in 5 seconds...');
      await new Promise(resolve => setTimeout(resolve, 5000));
    } finally {
      if (connection) await connection.end();
    }
  }
}

migrate();

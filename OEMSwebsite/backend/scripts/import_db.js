const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function importDatabase() {
  const sqlFilePath = path.join(__dirname, '../../database/OEMS.sql');
  console.log('Reading SQL file:', sqlFilePath);
  
  const sql = fs.readFileSync(sqlFilePath, 'utf8');
  
  // More robust split: semicolon followed by whitespace and/or newline
  const statements = sql.split(/;\s*$/m);

  console.log(`Connecting to ${process.env.DB_HOST}...`);
  
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: {
      rejectUnauthorized: false
    }
  });

  console.log('Connected! Starting import...');

  try {
    await connection.query('SET SESSION sql_require_primary_key = 0');
    console.log('Disabled sql_require_primary_key for session.');
  } catch (err) {
    console.warn('Warning: Could not disable sql_require_primary_key. Import may fail for some tables.');
  }

  let successCount = 0;
  let errorCount = 0;

  for (let statement of statements) {
    statement = statement.trim();
    if (!statement) continue;

    // Remove single line comments
    const cleanStatement = statement.split('\n')
      .filter(line => !line.trim().startsWith('-- '))
      .join('\n')
      .trim();

    if (!cleanStatement) continue;

    // Skip purely comment blocks (except for executable comments like /*!... */)
    if (cleanStatement.startsWith('/*') && cleanStatement.endsWith('*/') && !cleanStatement.startsWith('/*!')) {
      console.log('Skipping comment block');
      continue;
    }

    // Skip CREATE DATABASE and USE statements
    if (cleanStatement.toUpperCase().startsWith('CREATE DATABASE') || cleanStatement.toUpperCase().startsWith('USE ')) {
      console.log('Skipping:', cleanStatement.split('\n')[0]);
      continue;
    }

    try {
      await connection.query(cleanStatement);
      successCount++;
    } catch (err) {
      console.error('Error executing statement:', cleanStatement.substring(0, 100).replace(/\n/g, ' ') + '...');
      console.error(err.message);
      errorCount++;
    }
  }

  console.log(`Import completed. Success: ${successCount}, Errors: ${errorCount}`);
  await connection.end();
}

importDatabase().catch(err => {
  console.error('CRITICAL ERROR:', err);
  process.exit(1);
});

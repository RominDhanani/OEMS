const db = require('../config/database');
const cloudinary = require('../config/cloudinary');
const fs = require('fs');
const path = require('path');

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

async function uploadToCloudinary(filePath, folder) {
  try {
    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      resource_type: 'auto'
    });
    return result.secure_url;
  } catch (error) {
    console.error(`Error uploading ${filePath} to Cloudinary:`, error);
    return null;
  }
}

function resolveLocalPath(dbPath) {
  // Normalize slashes
  let cleanPath = dbPath.replace(/\\/g, '/');
  
  // Extract just the part after 'uploads/'
  const uploadsIndex = cleanPath.indexOf('uploads/');
  if (uploadsIndex !== -1) {
    const relativePath = cleanPath.substring(uploadsIndex + 8); // remove 'uploads/'
    return path.join(UPLOADS_DIR, relativePath);
  }
  return null;
}

async function migrateExpenses() {
  console.log('Migrating Expense Documents...');
  const [docs] = await db.execute("SELECT id, document_path FROM expense_documents WHERE document_path NOT LIKE 'http%'");
  let successCount = 0;
  
  for (const doc of docs) {
    const physicalPath = resolveLocalPath(doc.document_path);
    if (!physicalPath || !fs.existsSync(physicalPath)) {
      console.warn(`[WARN] File not found on disk for ID ${doc.id}: ${doc.document_path}`);
      continue;
    }

    console.log(`Uploading ID ${doc.id}...`);
    const cloudinaryUrl = await uploadToCloudinary(physicalPath, 'oems/expenses');
    
    if (cloudinaryUrl) {
      await db.execute('UPDATE expense_documents SET document_path = ? WHERE id = ?', [cloudinaryUrl, doc.id]);
      console.log(`[SUCCESS] Updated ID ${doc.id} -> ${cloudinaryUrl}`);
      successCount++;
    }
  }
  console.log(`Expense Documents Migration Complete: ${successCount}/${docs.length} migrated.\n`);
}

async function migrateCheques() {
  console.log('Migrating Cheque Images...');
  const [funds] = await db.execute("SELECT id, cheque_image_path FROM operational_funds WHERE cheque_image_path IS NOT NULL AND cheque_image_path != '' AND cheque_image_path NOT LIKE 'http%'");
  let successCount = 0;

  for (const fund of funds) {
    const physicalPath = resolveLocalPath(fund.cheque_image_path);
    if (!physicalPath || !fs.existsSync(physicalPath)) {
      console.warn(`[WARN] File not found on disk for Fund ID ${fund.id}: ${fund.cheque_image_path}`);
      continue;
    }

    console.log(`Uploading Fund ID ${fund.id}...`);
    const cloudinaryUrl = await uploadToCloudinary(physicalPath, 'oems/cheques');
    
    if (cloudinaryUrl) {
      await db.execute('UPDATE operational_funds SET cheque_image_path = ? WHERE id = ?', [cloudinaryUrl, fund.id]);
      console.log(`[SUCCESS] Updated Fund ID ${fund.id} -> ${cloudinaryUrl}`);
      successCount++;
    }
  }
  console.log(`Cheque Images Migration Complete: ${successCount}/${funds.length} migrated.\n`);
}

async function run() {
  try {
    await migrateExpenses();
    await migrateCheques();
    console.log('--- ALL MIGRATIONS FINISHED ---');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

run();

const db = require('../config/database');
const cloudinary = require('../config/cloudinary');
const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.join(__dirname, '..');

async function uploadToCloudinary(filePath, folder) {
  try {
    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      resource_type: 'image'
    });
    return result.secure_url;
  } catch (error) {
    console.error(`Error uploading ${filePath} to Cloudinary:`, error);
    return null;
  }
}

async function migrateProfiles() {
  console.log('Migrating Profile Images...');
  const [users] = await db.execute("SELECT id, profile_image FROM users WHERE profile_image IS NOT NULL AND profile_image != '' AND profile_image NOT LIKE 'http%'");
  let successCount = 0;
  
  for (const user of users) {
    let relativePath = user.profile_image;
    if (relativePath.startsWith('/')) {
        relativePath = relativePath.substring(1);
    }
    const physicalPath = path.join(ROOT_DIR, relativePath);
    
    if (!fs.existsSync(physicalPath)) {
      console.warn(`[WARN] File not found on disk for User ID ${user.id}: ${physicalPath}`);
      continue;
    }

    console.log(`Uploading User ID ${user.id}...`);
    const cloudinaryUrl = await uploadToCloudinary(physicalPath, 'oems/profiles');
    
    if (cloudinaryUrl) {
      await db.execute('UPDATE users SET profile_image = ? WHERE id = ?', [cloudinaryUrl, user.id]);
      console.log(`[SUCCESS] Updated User ID ${user.id} -> ${cloudinaryUrl}`);
      successCount++;
    }
  }
  console.log(`Profile Images Migration Complete: ${successCount}/${users.length} migrated.\n`);
  process.exit(0);
}

migrateProfiles();

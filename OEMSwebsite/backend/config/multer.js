const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('./cloudinary');

// Configure storage for expense documents
const expenseStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'oems/expenses',
    resource_type: 'auto', // Allows non-image files like PDFs
    allowed_formats: ['jpg', 'png', 'jpeg', 'pdf'],
  },
});

// Configure storage for expansion fund documents
const expansionStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'oems/expansion-funds',
    resource_type: 'auto',
    allowed_formats: ['jpg', 'png', 'jpeg', 'pdf'],
  },
});

// Configure storage for cheques
const chequeStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'oems/cheques',
    resource_type: 'auto',
    allowed_formats: ['jpg', 'png', 'jpeg', 'pdf'],
  },
});

// Configure storage for profile images
const profileStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'oems/profiles',
    resource_type: 'image',
    allowed_formats: ['jpg', 'png', 'jpeg', 'webp', 'gif'],
  },
});

// File filter (optional, Cloudinary also handles allowed_formats)
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only PDF, JPG, and PNG files are allowed.'), false);
  }
};

// Multer configuration
const expenseUpload = multer({
  storage: expenseStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024 // 10MB default
  }
});

const expansionUpload = multer({
  storage: expansionStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024
  }
});

const chequeUpload = multer({
  storage: chequeStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024
  }
});

const profileUpload = multer({
  storage: profileStorage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit for profiles
  }
});

module.exports = {
  expenseUpload,
  expansionUpload,
  chequeUpload,
  profileUpload,
};

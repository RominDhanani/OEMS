/**
 * Authentication Routes
 * Handles user registration, login, profile management, and OTP functionality.
 */

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { createNotification } = require('../utils/notifications');
const { sendEmail } = require('../utils/mailer');
const crypto = require('crypto');
const { isRealtimeEmail } = require('../utils/emailValidator');
const { authenticateToken } = require('../middleware/auth');
const { getIO } = require('../utils/socket');

// Configure Multer for profile images
const { profileUpload } = require('../config/multer');


// Request Registration OTP
router.post('/request-registration-otp', [
    body('email').isEmail().normalizeEmail()
], async (req, res) => {
    try {
        const { email } = req.body;

        // Realtime Email Validation (DNS, Disposable, Patterns)
        const emailCheck = await isRealtimeEmail(email);
        if (!emailCheck.isValid) {
            return res.status(400).json({ message: emailCheck.message });
        }

        // Check if user already exists
        const [existingUsers] = await db.execute('SELECT id FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'Email already registered' });
        }

        // Generate OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

        // Upsert into registration_verifications (optional: create this table or use a temp store)
        // For now, let's use the users table with a special 'VERIFYING' status or a separate table if it exists.
        // Better: Create a registration_otps table if it doesn't exist.
        await db.execute(
            'INSERT INTO registration_otps (email, otp_code, expires_at) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE otp_code = ?, expires_at = ?',
            [email, otp, otpExpires, otp, otpExpires]
        );

        await sendEmail(
            email,
            'Registration Verification Code',
            `Your verification code for registration is: ${otp}\n\nThis code is valid for 10 minutes.`
        );

        res.json({ message: 'Verification code sent to email' });
    } catch (error) {
        if (error.code === 'ER_NO_SUCH_TABLE') {
            // Fallback or create table if needed, but assuming migration is handled
            return res.status(500).json({ message: 'System setup error: registration_otps table missing' });
        }
        console.error('Request Registration OTP error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

// Verify Registration OTP
router.post('/verify-registration-otp', [
    body('email').isEmail().normalizeEmail(),
    body('otp').isLength({ min: 6, max: 6 })
], async (req, res) => {
    try {
        const { email, otp } = req.body;

        const [records] = await db.execute(
            'SELECT id FROM registration_otps WHERE email = ? AND otp_code = ? AND expires_at > NOW()',
            [email, otp]
        );

        if (records.length === 0) {
            return res.status(401).json({ message: 'Invalid or expired verification code' });
        }

        // Generate a temporary verification token
        const verificationToken = crypto.randomBytes(32).toString('hex');
        await db.execute(
            'UPDATE registration_otps SET verification_token = ?, verified = 1 WHERE email = ?',
            [verificationToken, email]
        );

        res.json({ message: 'Email verified successfully', verificationToken });
    } catch (error) {
        console.error('Verify Registration OTP error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

/**
 * POST /api/auth/register
 * Register a new user with 'PENDING' status.
 * Requires a valid email verification token.
 */
router.post('/register', [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 6 }),
    body('full_name').trim().notEmpty(),
    body('mobile_number').optional().trim().isMobilePhone().withMessage('Invalid mobile number'),
    body('role').isIn(['MANAGER', 'USER'])
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email, password, full_name, mobile_number, role, verificationToken } = req.body;

        // Verify verification token
        const [tokenCheck] = await db.execute(
            'SELECT id FROM registration_otps WHERE email = ? AND verification_token = ? AND verified = 1',
            [email, verificationToken]
        );

        if (tokenCheck.length === 0) {
            return res.status(403).json({ message: 'Email not verified. Please verify your email first.' });
        }

        // Realtime Email Validation (Security double check)
        const emailCheck = await isRealtimeEmail(email);
        if (!emailCheck.isValid) {
            return res.status(400).json({ message: emailCheck.message });
        }

        // Check if user already exists
        const [existingUsers] = await db.execute(
            'SELECT id FROM users WHERE email = ?',
            [email]
        );

        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'Email already registered' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert new user with PENDING status
        const [result] = await db.execute(
            'INSERT INTO users (email, password, full_name, mobile_number, role, status) VALUES (?, ?, ?, ?, ?, ?)',
            [email, hashedPassword, full_name, mobile_number || null, role, 'PENDING']
        );

        // Notify CEO of new registration
        const [ceos] = await db.execute('SELECT id, email, full_name FROM users WHERE role = "CEO"');
        for (const ceo of ceos) {
            await createNotification(
                ceo.id,
                'USER_REGISTERED',
                'New User Registration',
                `${full_name} has registered as a ${role} and is pending approval.`,
                result.insertId
            );

            // Send Email to CEO
            if (ceo.email) {
                await sendEmail(
                    ceo.email,
                    'New User Registration Pending Approval',
                    `Dear ${ceo.full_name},\n\nA new user ${full_name} has registered as a ${role} and is awaiting your approval.\n\nBest regards,\nOffice Expense Management System`
                );
            }
        }

        res.status(201).json({
            message: 'Registration successful. Please wait for CEO approval.',
            userId: result.insertId
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ message: 'Server error during registration' });
    }
});

/**
 * POST /api/auth/login
 * Standard login using email and password.
 * Returns JWT token and user profile if successful.
 */
router.post('/login', [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty()
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email, password, device_info = 'Unknown Device' } = req.body;

        // Find user
        const [users] = await db.execute(
            'SELECT id, email, password, role, status, full_name, mobile_number, profile_image FROM users WHERE email = ?',
            [email]
        );

        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        const user = users[0];

        // Check if user is approved (CEO is always approved)
        if (user.status !== 'APPROVED' && user.role !== 'CEO') {
            return res.status(403).json({ message: 'Account pending approval. Please wait for CEO approval.' });
        }

        // Verify password
        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Check if JWT_SECRET is configured
        if (!process.env.JWT_SECRET) {
            console.error('JWT_SECRET is not configured in environment variables');
            return res.status(500).json({ message: 'Server configuration error. JWT_SECRET not set.' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { userId: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        // Store session in DB
        await db.execute(
            'INSERT INTO user_sessions (user_id, token, device_info, active) VALUES (?, ?, ?, true)',
            [user.id, token, device_info]
        );

        res.json({
            token,
            user: {
                id: user.id,
                email: user.email,
                full_name: user.full_name,
                mobile_number: user.mobile_number,
                role: user.role,
                status: user.status,
                profile_image: user.profile_image
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        console.error('Error stack:', error.stack);
        res.status(500).json({
            message: 'Server error during login',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

/**
 * POST /api/auth/logout
 * Securly logs out the user by removing their current session from the database.
 * No middleware required here, as we want to allow logout even if the token is already expired.
 */
router.post('/logout', async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (token) {
            await db.execute('DELETE FROM user_sessions WHERE token = ?', [token]);
        }

        res.json({ message: 'Logged out successfully' });
    } catch (error) {
        console.error('Logout error:', error);
        res.status(500).json({ message: 'Server error during logout' });
    }
});

// Get current user info
router.get('/me', authenticateToken, async (req, res) => {
    try {
        const [users] = await db.execute(
            'SELECT id, email, full_name, mobile_number, role, status, profile_image, created_at FROM users WHERE id = ?',
            [req.user.id]
        );

        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        console.log('User fetched in /me:', users[0]);
        res.json({ user: users[0] });
    } catch (error) {
        console.error('Get user error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

// Update Profile
router.put('/profile', [
    authenticateToken,
    profileUpload.single('profile_image'), // Middleware for file upload
    body('email').isEmail().normalizeEmail(),
    body('full_name').trim().notEmpty(),
    body('mobile_number').optional().trim().isMobilePhone(),
    body('password').optional().isLength({ min: 6 })
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email, full_name, mobile_number, password } = req.body;
        const userId = req.user.id;

        // Realtime Email Validation
        const emailCheck = await isRealtimeEmail(email);
        if (!emailCheck.isValid) {
            return res.status(400).json({ message: emailCheck.message });
        }

        // Check if email is already taken by another user
        const [existingUsers] = await db.execute(
            'SELECT id FROM users WHERE email = ? AND id != ?',
            [email, userId]
        );

        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'Email already used by another account' });
        }

        let query = 'UPDATE users SET email = ?, full_name = ?, mobile_number = ?';
        let params = [email, full_name, mobile_number || null];

        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            query += ', password = ?';
            params.push(hashedPassword);
        }


        console.log('Update Profile Request Body:', req.body);
        console.log('Update Profile Request File:', req.file);

        if (req.file) {
            query += ', profile_image = ?';

            // Use Cloudinary path directly
            const dbPath = req.file.path;

            console.log('DB Path to save:', dbPath);
            params.push(dbPath);
        }

        query += ' WHERE id = ?';
        params.push(userId);

        console.log('Executing query:', query);
        console.log('With params:', params);

        await db.execute(query, params);

        // Get updated user to return
        const [updatedUsers] = await db.execute(
            'SELECT id, email, full_name, mobile_number, role, status, profile_image FROM users WHERE id = ?',
            [userId]
        );

        res.json({
            message: 'Profile updated successfully',
            user: updatedUsers[0]
        });

        // Broadcast via Socket.io
        try {
            const io = getIO();
            io.emit('userUpdated');
        } catch (err) { }
    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({
            message: 'Server error during profile update',
            error: error.message
        });
    }
});

// Delete Profile Image
router.delete('/profile-image', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        // Get current user to find the image path
        const [users] = await db.execute('SELECT profile_image FROM users WHERE id = ?', [userId]);

        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = users[0];

        if (user.profile_image) {
            // Construct the full path to the file
            // Assuming the path stored in DB is relative like '/uploads/profiles/filename.jpg'
            // We need to resolve this to the file system path.
            // Based on earlier code: uploadPath = 'uploads/profiles/'
            // And middleware usage in server.js likely maps /uploads to the uploads folder.

            // Remove leading slash if present to get relative path for fs.unlink
            let relativePath = user.profile_image;
            if (relativePath.startsWith('/')) {
                relativePath = relativePath.substring(1);
            }

            const filePath = path.join(__dirname, '../', relativePath);

            // Delete the file if it exists and is local
            if (fs.existsSync(filePath) && !user.profile_image.startsWith('http')) {
                fs.unlinkSync(filePath);
            }

            // Update database to remove the image reference
            await db.execute('UPDATE users SET profile_image = NULL WHERE id = ?', [userId]);
        }

        // Return updated user object (without profile image)
        const [updatedUsers] = await db.execute(
            'SELECT id, email, full_name, mobile_number, role, status, profile_image FROM users WHERE id = ?',
            [userId]
        );

        res.json({
            message: 'Profile photo removed successfully',
            user: updatedUsers[0]
        });

        // Broadcast via Socket.io
        try {
            const io = getIO();
            io.emit('userUpdated');
        } catch (err) { }

    } catch (error) {
        console.error('Delete profile image error:', error);
        res.status(500).json({ message: 'Server error during profile image deletion' });
    }
});

// Forgot Password
router.post('/forgot-password', async (req, res) => {
    try {
        const { email } = req.body;

        // Realtime Email Validation
        const emailCheck = await isRealtimeEmail(email);
        if (!emailCheck.isValid) {
            return res.status(400).json({ message: emailCheck.message });
        }

        // Check if user exists
        const [users] = await db.execute('SELECT id, full_name FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found with this email' });
        }

        const user = users[0];

        // Generate token
        const token = crypto.randomBytes(20).toString('hex');
        const tokenExpiry = new Date(Date.now() + 3600000); // 1 hour

        // Save token to DB
        await db.execute(
            'UPDATE users SET reset_password_token = ?, reset_password_expires = ? WHERE id = ?',
            [token, tokenExpiry, user.id]
        );

        // Send email
        // IMPORTANT: Update this URL to match your frontend URL in production
        const resetUrl = `http://localhost:3000/reset-password/${token}`;

        await sendEmail(
            email,
            'Password Reset Request',
            `You are receiving this because you (or someone else) have requested the reset of the password for your account.\n\n` +
            `Please click on the following link, or paste this into your browser to complete the process:\n\n` +
            `${resetUrl}\n\n` +
            `If you did not request this, please ignore this email and your password will remain unchanged.\n`
        );

        res.json({ message: 'Password reset link sent to email' });
    } catch (error) {
        console.error('Forgot password error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

// Reset Password
router.post('/reset-password/:token', [
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { token } = req.params;
        const { password } = req.body;

        // Find user with valid token
        const [users] = await db.execute(
            'SELECT id, email FROM users WHERE reset_password_token = ? AND reset_password_expires > NOW()',
            [token]
        );

        if (users.length === 0) {
            return res.status(400).json({ message: 'Password reset token is invalid or has expired' });
        }

        const user = users[0];

        // Hash new password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Update password and clear token
        await db.execute(
            'UPDATE users SET password = ?, reset_password_token = NULL, reset_password_expires = NULL WHERE id = ?',
            [hashedPassword, user.id]
        );

        res.json({ message: 'Password has been changed successfully' });
    } catch (error) {
        console.error('Reset password error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

// Request Login OTP
router.post('/request-login-otp', [
    body('email').isEmail().normalizeEmail()
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email } = req.body;

        // Realtime Email Validation
        const emailCheck = await isRealtimeEmail(email);
        if (!emailCheck.isValid) {
            return res.status(400).json({ message: emailCheck.message });
        }

        // Check if user exists
        const [users] = await db.execute('SELECT id, full_name, status, role FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found with this email' });
        }

        const user = users[0];

        // Check status (unless CEO)
        if (user.status !== 'APPROVED' && user.role !== 'CEO') {
            return res.status(403).json({ message: 'Account pending approval.' });
        }

        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

        // Save OTP to DB
        await db.execute(
            'UPDATE users SET otp_code = ?, otp_expires_at = ? WHERE id = ?',
            [otp, otpExpires, user.id]
        );

        // Send Email
        await sendEmail(
            email,
            'Your Login OTP',
            `Dear ${user.full_name},\n\nYour OTP for login is: ${otp}\n\nIt is valid for 10 minutes.\n\nIf you did not request this, please ignore this email.\n`
        );

        res.json({ message: 'OTP sent to your email' });
    } catch (error) {
        console.error('Request OTP error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

// Login with OTP
router.post('/login-otp', [
    body('email').isEmail().normalizeEmail(),
    body('otp').isLength({ min: 6, max: 6 }).isNumeric()
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email, otp, device_info = 'Unknown Device' } = req.body;

        // Find user with valid OTP
        const [users] = await db.execute(
            'SELECT id, email, full_name, mobile_number, role, status, profile_image FROM users WHERE email = ? AND otp_code = ? AND otp_expires_at > NOW()',
            [email, otp]
        );

        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid or expired OTP' });
        }

        const user = users[0];

        // Check status (extra safety, though request-otp checks it too)
        if (user.status !== 'APPROVED' && user.role !== 'CEO') {
            return res.status(403).json({ message: 'Account pending approval.' });
        }

        // Clear OTP
        await db.execute(
            'UPDATE users SET otp_code = NULL, otp_expires_at = NULL WHERE id = ?',
            [user.id]
        );

        // Generate JWT token
        if (!process.env.JWT_SECRET) {
            console.error('JWT_SECRET is not configured');
            return res.status(500).json({ message: 'Server configuration error' });
        }

        const token = jwt.sign(
            { userId: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        // Store session in DB
        await db.execute(
            'INSERT INTO user_sessions (user_id, token, device_info, active) VALUES (?, ?, ?, true)',
            [user.id, token, device_info]
        );

        res.json({
            token,
            user: {
                id: user.id,
                email: user.email,
                full_name: user.full_name,
                mobile_number: user.mobile_number,
                role: user.role,
                status: user.status,
                profile_image: user.profile_image
            }
        });

    } catch (error) {
        console.error('Login OTP error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

module.exports = router;

/**
 * GET /api/auth/sessions
 * Returns a list of all active sessions for the currently logged-in user.
 */
router.get('/sessions', authenticateToken, async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        const currentToken = authHeader && authHeader.split(' ')[1];

        const [sessions] = await db.execute(
            'SELECT id, device_info, token, created_at, last_active, active FROM user_sessions WHERE user_id = ? AND active = true ORDER BY last_active DESC',
            [req.user.id]
        );

        const formattedSessions = sessions.map(session => ({
            id: session.id,
            device_info: session.device_info,
            created_at: session.created_at,
            last_active: session.last_active,
            active: session.active,
            is_current: session.token === currentToken
        }));

        res.json({ sessions: formattedSessions });
    } catch (error) {
        console.error('Fetch sessions error:', error);
        res.status(500).json({ message: 'Server error fetching active sessions' });
    }
});

/**
 * DELETE /api/auth/sessions/revoke-all-others
 * Revokes all sessions for the user except the current one.
 */
router.delete('/sessions/revoke-all-others', authenticateToken, async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        const currentToken = authHeader && authHeader.split(' ')[1];

        // Delete all sessions for the user that do NOT match the current token
        const [result] = await db.execute(
            'DELETE FROM user_sessions WHERE user_id = ? AND token != ?',
            [req.user.id, currentToken]
        );

        if (result.affectedRows === 0) {
            return res.status(200).json({ message: 'No other active sessions found to revoke.' });
        }

        res.json({ message: `Successfully revoked ${result.affectedRows} other session(s).`, revokedCount: result.affectedRows });
    } catch (error) {
        console.error('Revoke all other sessions error:', error);
        res.status(500).json({ message: 'Server error revoking sessions' });
    }
});

/**
 * DELETE /api/auth/sessions/:sessionId
 * Revokes a specific session remotely.
 */
router.delete('/sessions/:sessionId', authenticateToken, async (req, res) => {
    try {
        const { sessionId } = req.params;

        // Ensure the session belongs to the requesting user before deleting
        const [result] = await db.execute(
            'DELETE FROM user_sessions WHERE id = ? AND user_id = ?',
            [sessionId, req.user.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Session not found or unavailable' });
        }

        res.json({ message: 'Session revoked successfully!' });
    } catch (error) {
        console.error('Revoke session error:', error);
        res.status(500).json({ message: 'Server error revoking session' });
    }
});

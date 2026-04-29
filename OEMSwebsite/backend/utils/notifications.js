const db = require('../config/database');
const { getIO } = require('./socket');

/**
 * Create a system notification for a user
 * @param {number} userId - ID of the user to notify
 * @param {string} type - Type of notification
 * @param {string} title - Short title for the notification
 * @param {string} message - Detailed notification message
 * @param {number} relatedId - ID of the related entity (expense, fund, etc.)
 */
const createNotification = async (userId, type, title, message, relatedId = null) => {
    try {
        await db.execute(
            'INSERT INTO notifications (user_id, type, title, message, related_id) VALUES (?, ?, ?, ?, ?)',
            [userId, type, title, message, relatedId]
        );
        // Emit real-time notification via socket
        try {
            const io = getIO();
            io.to(`user_${userId}`).emit('notificationReceived', { type, title, message });
        } catch (socketError) {
            // Socket IO might not be initialized yet or some other issue, log it but don't fail notification
            console.error('Socket notification emit failed:', socketError.message);
        }
    } catch (error) {
        console.error('Error creating notification:', error);
    }
};

module.exports = { createNotification };

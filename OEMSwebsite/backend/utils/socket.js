const { Server } = require('socket.io');

let io;

module.exports = {
    init: (httpServer) => {
        io = new Server(httpServer, {
            cors: {
                origin: (origin, callback) => {
                    // Allow all origins dynamically (credentials-compatible)
                    callback(null, true);
                },
                methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
                credentials: true
            },
            allowEIO3: true, // Support older clients if any
            pingTimeout: 60000,
            pingInterval: 25000
        });

        io.on('connection', (socket) => {
            console.log('New client connected via WebSockets:', socket.id);

            // Clients can join rooms based on their user ID to receive targeted updates
            socket.on('joinUserRoom', (userId) => {
                socket.join(`user_${userId}`);
                console.log(`Socket ${socket.id} joined room user_${userId}`);
            });

            // Role-based rooms (e.g. for CEOs to see all expenses)
            socket.on('joinRoleRoom', (role) => {
                socket.join(`role_${role}`);
                console.log(`Socket ${socket.id} joined room role_${role}`);
            });

            // Live currency/settings change broadcast
            socket.on('changeCurrency', (data) => {
                console.log(`Currency changed to ${data.currency} by socket ${socket.id}`);
                // Broadcast to ALL connected clients (including sender)
                io.emit('settingsUpdated', { currency: data.currency });
            });

            socket.on('disconnect', () => {
                console.log('Client disconnected from WebSockets:', socket.id);
            });
        });

        return io;
    },
    getIO: () => {
        if (!io) {
            throw new Error('Socket.io not initialized!');
        }
        return io;
    }
};

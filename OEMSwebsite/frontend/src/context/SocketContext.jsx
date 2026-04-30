import React, { createContext, useContext, useEffect, useState } from 'react';
import { io } from 'socket.io-client';
import { useAuth } from './AuthContext';

const SocketContext = createContext();

export const useSocket = () => useContext(SocketContext);

export const SocketProvider = ({ children }) => {
    const { user, refreshUserProfile } = useAuth();
    const [socket, setSocket] = useState(null);

    useEffect(() => {
        if (user) {
            // Vercel serverless does not support WebSockets.
            // Only connect in local development.
            const isDev = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

            if (!isDev) {
                // In production, skip socket connection entirely
                setSocket(null);
                return;
            }

            const socketInstance = io('http://127.0.0.1:5000', {
                reconnection: true,
                reconnectionAttempts: 5
            });

            socketInstance.on('connect', () => {
                console.log('React connected to WebSockets');
                socketInstance.emit('joinUserRoom', user.id);
                socketInstance.emit('joinRoleRoom', user.role);
            });

            // Handle global user updates (e.g., name/photo changes from mobile)
            socketInstance.on('userUpdated', refreshUserProfile);

            setSocket(socketInstance);

            return () => {
                socketInstance.off('userUpdated', refreshUserProfile);
                socketInstance.disconnect();
            };
        } else {
            setSocket(null);
        }
    }, [user]);

    return (
        <SocketContext.Provider value={socket}>
            {children}
        </SocketContext.Provider>
    );
};


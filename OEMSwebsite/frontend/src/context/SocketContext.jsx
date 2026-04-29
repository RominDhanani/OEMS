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
            // Connect to socket when user is logged in
            // Handle localhost vs 127.0.0.1 specifically for IPv4 listeners
            let hostname = window.location.hostname;
            if (hostname === 'localhost') hostname = '127.0.0.1';

            const socketInstance = io(`${window.location.protocol}//${hostname}:5000`, {
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

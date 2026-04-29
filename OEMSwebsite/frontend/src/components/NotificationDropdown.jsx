import React, { useState, useEffect, useRef } from 'react';
import { FaBell, FaCheck, FaCheckDouble, FaCircle, FaInfoCircle, FaCheckCircle, FaExclamationCircle, FaUserPlus, FaWallet, FaHistory } from 'react-icons/fa';
import { getNotifications, markNotificationAsRead, markAllNotificationsAsRead } from '../services/api';

const NotificationDropdown = () => {
    const [isOpen, setIsOpen] = useState(false);
    const [notifications, setNotifications] = useState([]);
    const [unreadCount, setUnreadCount] = useState(0);
    const [loading, setLoading] = useState(false);
    const dropdownRef = useRef(null);

    const fetchNotifications = async () => {
        try {
            const response = await getNotifications();
            const notifs = response.data.notifications;
            setNotifications(notifs);
            setUnreadCount(notifs.filter(n => !n.is_read).length);
        } catch (error) {
            console.error('Error fetching notifications:', error);
        }
    };

    useEffect(() => {
        fetchNotifications();
        // Poll for new notifications every 20 seconds
        const interval = setInterval(fetchNotifications, 20000);
        return () => clearInterval(interval);
    }, []);

    useEffect(() => {
        const handleClickOutside = (event) => {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
                setIsOpen(false);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const handleToggle = () => setIsOpen(!isOpen);

    const handleMarkAsRead = async (id) => {
        try {
            await markNotificationAsRead(id);
            setNotifications(notifications.map(n =>
                n.id === id ? { ...n, is_read: true } : n
            ));
            setUnreadCount(prev => Math.max(0, prev - 1));
        } catch (error) {
            console.error('Error marking as read:', error);
        }
    };

    const handleMarkAllRead = async () => {
        try {
            await markAllNotificationsAsRead();
            setNotifications(notifications.map(n => ({ ...n, is_read: true })));
            setUnreadCount(0);
        } catch (error) {
            console.error('Error marking all as read:', error);
        }
    };

    const getIcon = (type) => {
        switch (type) {
            case 'EXPENSE_APPROVED': return <FaCheckCircle className="notif-icon success" />;
            case 'EXPENSE_REJECTED': return <FaExclamationCircle className="notif-icon danger" />;
            case 'EXPENSE_PENDING': return <FaInfoCircle className="notif-icon warning" />;
            case 'FUND_ALLOCATED': return <FaWallet className="notif-icon info" />;
            case 'FUND_REQUESTED': return <FaHistory className="notif-icon primary" />;
            case 'FUND_REQUEST_APPROVED': return <FaCheckCircle className="notif-icon success" />;
            case 'FUND_REQUEST_REJECTED': return <FaExclamationCircle className="notif-icon danger" />;
            case 'EXPANSION_REQUESTED': return <FaHistory className="notif-icon primary" />;
            case 'EXPANSION_APPROVED': return <FaCheckCircle className="notif-icon success" />;
            case 'EXPANSION_REJECTED': return <FaExclamationCircle className="notif-icon danger" />;
            case 'USER_REGISTERED': return <FaUserPlus className="notif-icon primary" />;
            case 'ACCOUNT_STATUS': return <FaCheck className="notif-icon info" />;
            case 'MANAGER_ASSIGNED': return <FaUserPlus className="notif-icon info" />;
            case 'USER_ASSIGNED': return <FaUserPlus className="notif-icon info" />;
            default: return <FaBell className="notif-icon secondary" />;
        }
    };

    const formatTime = (dateString) => {
        const date = new Date(dateString);
        const now = new Date();
        const diffInSeconds = Math.floor((now - date) / 1000);

        if (diffInSeconds < 60) return 'Just now';
        if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
        if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
        return date.toLocaleDateString();
    };

    return (
        <div className="notification-container" ref={dropdownRef}>
            <button className="notification-bell" onClick={handleToggle} title="Notifications">
                <FaBell />
                {unreadCount > 0 && <span className="notification-badge">{unreadCount}</span>}
            </button>

            {isOpen && (
                <div className="notification-dropdown">
                    <div className="notif-header">
                        <h3>Notifications</h3>
                        {unreadCount > 0 && (
                            <button onClick={handleMarkAllRead} className="mark-all-btn">
                                <FaCheckDouble /> Mark all read
                            </button>
                        )}
                    </div>

                    <div className="notif-list">
                        {notifications.length === 0 ? (
                            <div className="notif-empty">No notifications yet</div>
                        ) : (
                            notifications.map((notif) => (
                                <div
                                    key={notif.id}
                                    className={`notif-item ${!notif.is_read ? 'unread' : ''}`}
                                >
                                    <div className="notif-icon-container">
                                        {getIcon(notif.type)}
                                    </div>
                                    <div className="notif-content">
                                        <div className="notif-title-row">
                                            <span className="notif-title">{notif.title}</span>
                                            <span className="notif-time">{formatTime(notif.created_at)}</span>
                                        </div>
                                        <p className="notif-message">{notif.message}</p>
                                        {!notif.is_read && (
                                            <button
                                                onClick={() => handleMarkAsRead(notif.id)}
                                                className="mark-read-btn"
                                                title="Mark as read"
                                            >
                                                <FaCircle />
                                            </button>
                                        )}
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            )}
        </div>
    );
};

export default NotificationDropdown;

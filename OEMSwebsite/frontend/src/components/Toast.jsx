import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { FaCheckCircle, FaExclamationCircle, FaInfoCircle, FaTimes } from 'react-icons/fa';

const Toast = ({ message, type = 'info', onClose, duration = 5000 }) => {
    const [progress, setProgress] = useState(100);
    const [isExiting, setIsExiting] = useState(false);

    useEffect(() => {
        if (!duration) return;

        const startTime = Date.now();
        const interval = setInterval(() => {
            const elapsed = Date.now() - startTime;
            const remaining = Math.max(0, duration - elapsed);
            setProgress((remaining / duration) * 100);

            if (remaining <= 0) {
                handleClose();
            }
        }, 10);

        return () => clearInterval(interval);
    }, [duration]);

    const handleClose = () => {
        setIsExiting(true);
        setTimeout(onClose, 300); // Match animation duration
    };

    if (!message) return null;

    const getIcon = () => {
        switch (type) {
            case 'success': return <FaCheckCircle className="toast-icon-svg" />;
            case 'error': return <FaExclamationCircle className="toast-icon-svg" />;
            default: return <FaInfoCircle className="toast-icon-svg" />;
        }
    };

    return createPortal(
        <div className={`toast-container ${isExiting ? 'exit' : ''}`}>
            <div className={`toast toast-${type}`}>
                <div className="toast-content">
                    <div className="toast-icon">{getIcon()}</div>
                    <div className="toast-message-container">
                        <span className="toast-type-label">{type.toUpperCase()}</span>
                        <div className="toast-message">{message}</div>
                    </div>
                    <button className="toast-close" onClick={handleClose}>
                        <FaTimes />
                    </button>
                </div>
                <div
                    className="toast-progress"
                    style={{ width: `${progress}%` }}
                />
            </div>
        </div>,
        document.body
    );
};

export default Toast;

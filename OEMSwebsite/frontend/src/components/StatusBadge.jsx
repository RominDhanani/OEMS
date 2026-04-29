import React from 'react';
import {
    FaCheckCircle,
    FaTimesCircle,
    FaClock,
    FaHourglassHalf,
    FaFileAlt,
    FaMoneyBillWave,
    FaHandHoldingUsd,
    FaExchangeAlt,
    FaExpandArrowsAlt,
    FaUserCheck,
    FaUserTimes,
    FaUserTie,
    FaUser,
    FaCrown,
    FaCheckDouble,
    FaCog,
    FaPowerOff,
    FaLink,
} from 'react-icons/fa';

const STATUS_CONFIG = {
    // Approval Flow
    PENDING_APPROVAL: { label: 'Pending Approval', bg: '#FEF3C7', color: '#92400E', border: '#FCD34D', icon: FaClock },
    APPROVED: { label: 'Approved', bg: '#D1FAE5', color: '#065F46', border: '#6EE7B7', icon: FaCheckCircle },
    REJECTED: { label: 'Rejected', bg: '#FEE2E2', color: '#991B1B', border: '#FCA5A5', icon: FaTimesCircle },

    // Expense Lifecycle
    PENDING: { label: 'Pending', bg: '#FEF9C3', color: '#854D0E', border: '#FDE68A', icon: FaHourglassHalf },
    RECEIPT_APPROVED: { label: 'Receipt Approved', bg: '#CFFAFE', color: '#155E75', border: '#67E8F9', icon: FaFileAlt },
    COMPLETED: { label: 'Completed', bg: '#D1FAE5', color: '#065F46', border: '#6EE7B7', icon: FaCheckDouble },
    PROCESSING: { label: 'Processing', bg: '#E0E7FF', color: '#3730A3', border: '#A5B4FC', icon: FaCog },

    // Fund Status
    ALLOCATED: { label: 'Allocated', bg: '#DBEAFE', color: '#1E40AF', border: '#93C5FD', icon: FaMoneyBillWave },
    FUND_ALLOCATED: { label: 'Fund Allocated', bg: '#DBEAFE', color: '#1E40AF', border: '#93C5FD', icon: FaHandHoldingUsd },
    RECEIVED: { label: 'Received', bg: '#D1FAE5', color: '#065F46', border: '#6EE7B7', icon: FaExchangeAlt },

    // Expansion
    EXPANSION_REQUESTED: { label: 'Expansion Requested', bg: '#E0E7FF', color: '#3730A3', border: '#A5B4FC', icon: FaExpandArrowsAlt },

    // User/Role Status
    ACTIVE: { label: 'Active', bg: '#D1FAE5', color: '#065F46', border: '#6EE7B7', icon: FaCheckCircle },
    INACTIVE: { label: 'Inactive', bg: '#F1F5F9', color: '#475569', border: '#CBD5E1', icon: FaPowerOff },
    ASSIGNED: { label: 'Assigned', bg: '#DBEAFE', color: '#1E40AF', border: '#93C5FD', icon: FaLink },
    UNASSIGNED: { label: 'Unassigned', bg: '#FEF2F2', color: '#991B1B', border: '#FECACA', icon: FaUserTimes },

    // Roles
    MANAGER: { label: 'Manager', bg: '#F3E8FF', color: '#6B21A8', border: '#D8B4FE', icon: FaUserTie },
    USER: { label: 'User', bg: '#E0F2FE', color: '#075985', border: '#7DD3FC', icon: FaUser },
    CEO: { label: 'CEO', bg: '#FFF7ED', color: '#9A3412', border: '#FDBA74', icon: FaCrown },
};

const StatusBadge = ({ status, style }) => {
    const key = (status || 'PROCESSING').toUpperCase().replace(/\s+/g, '_');
    const config = STATUS_CONFIG[key] || {
        label: (status || 'Processing').replace(/_/g, ' '),
        bg: '#F1F5F9',
        color: '#475569',
        border: '#CBD5E1',
        icon: FaClock,
    };

    const IconComponent = config.icon;
    const displayText = config.label || status.replace(/_/g, ' ');

    return (
        <span
            style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '5px',
                padding: '4px 10px 4px 8px',
                borderRadius: '9999px',
                fontSize: '0.72rem',
                fontWeight: 600,
                letterSpacing: '0.02em',
                lineHeight: 1,
                whiteSpace: 'nowrap',
                background: config.bg,
                color: config.color,
                border: `1px solid ${config.border}`,
                fontFamily: 'var(--font-display, "Inter", sans-serif)',
                transition: 'all 0.2s ease',
                ...style,
            }}
        >
            <IconComponent style={{ fontSize: '0.7rem', flexShrink: 0 }} />
            {displayText}
        </span>
    );
};

export default StatusBadge;

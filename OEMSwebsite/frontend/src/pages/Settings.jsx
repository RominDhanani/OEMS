import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Layout from '../components/Layout';
import { useAuth } from '../context/AuthContext';
import { useSettings } from '../context/SettingsContext';
import {
    FaMoon, FaSun, FaGlobe, FaCoins, FaPalette, FaTachometerAlt, FaUsers, FaClock,
    FaListUl, FaWallet, FaHandHoldingUsd, FaHistory, FaHourglassHalf, FaChartBar,
    FaChartLine, FaArrowDown, FaFileInvoiceDollar, FaUsersCog, FaPlusCircle, FaCog,
    FaChartPie, FaUserCheck, FaCheckCircle, FaClipboardCheck, FaFileAlt,
    FaLeaf, FaWater, FaCloudSun, FaStar, FaArrowLeft, FaLanguage, FaCheck
} from 'react-icons/fa';
import Toast from '../components/Toast';

const Settings = () => {
    const { user } = useAuth();
    const navigate = useNavigate();
    const {
        theme, setTheme, themes,
        currency, setCurrency
    } = useSettings();

    const isCEO = user?.role === 'CEO';
    const isManager = user?.role === 'MANAGER';

    const handleBack = () => {
        navigate(-1);
    };

    const currencies = [
        { code: 'INR', name: 'Indian Rupee (₹)', symbol: '₹', flag: '🇮🇳' },
        { code: 'USD', name: 'US Dollar ($)', symbol: '$', flag: '🇺🇸' },
        { code: 'EUR', name: 'Euro (€)', symbol: '€', flag: '🇪🇺' },
        { code: 'GBP', name: 'British Pound (£)', symbol: '£', flag: '🇬🇧' },
        { code: 'JPY', name: 'Japanese Yen (¥)', symbol: '¥', flag: '🇯🇵' },
        { code: 'CAD', name: 'Canadian Dollar (C$)', symbol: 'C$', flag: '🇨🇦' },
        { code: 'AUD', name: 'Australian Dollar (A$)', symbol: 'A$', flag: '🇦🇺' },
        { code: 'AED', name: 'UAE Dirham (د.إ)', symbol: 'د.إ', flag: '🇦🇪' },
        { code: 'SAR', name: 'Saudi Riyal (SR)', symbol: 'SR', flag: '🇸🇦' },
        { code: 'CNY', name: 'Chinese Yuan (¥)', symbol: '¥', flag: '🇨🇳' }
    ];

    const getMenuItems = () => {
        if (isCEO) {
            return [
                { id: 'dashboard', label: 'Dashboard', icon: <FaTachometerAlt /> },
                { id: 'allocation', label: 'Allocation & Usage', icon: <FaChartPie /> },
                {
                    id: 'expenses_root',
                    label: 'Expenses',
                    icon: <FaFileInvoiceDollar />,
                    subItems: [
                        { id: 'pending_approvals', label: 'Pending Approvals', icon: <FaHourglassHalf /> },
                        { id: 'all_expenses', label: 'All Expenses', icon: <FaUsersCog /> }
                    ]
                },
                {
                    id: 'users_root',
                    label: 'User Approvals',
                    icon: <FaUserCheck />,
                    subItems: [
                        { id: 'pending_users', label: 'Pending Approvals', icon: <FaUserCheck /> },
                        { id: 'all_users', label: 'User Assignment', icon: <FaUsers /> },
                        { id: 'registration_history', label: 'Registration History', icon: <FaHistory /> }
                    ]
                },
                {
                    id: 'funds_root',
                    label: 'Fund Allocation',
                    icon: <FaWallet />,
                    subItems: [
                        { id: 'allocate_fund', label: 'Allocate Fund', icon: <FaHandHoldingUsd /> },
                        { id: 'fund_history', label: 'Allocation History', icon: <FaHistory /> }
                    ]
                },
                {
                    id: 'expansion_root',
                    label: 'Expansion Fund',
                    icon: <FaChartBar />,
                    subItems: [
                        { id: 'review_expansion', label: 'Review Requests', icon: <FaHourglassHalf /> },
                        { id: 'expansion_history', label: 'History & Logs', icon: <FaHistory /> }
                    ]
                },
                { id: 'reports', label: 'Finance Reports', icon: <FaChartLine /> },
                { id: 'settings', label: 'Settings', icon: <FaCog /> }
            ];
        } else if (isManager) {
            return [
                { id: 'dashboard', label: 'Dashboard', icon: <FaTachometerAlt /> },
                {
                    id: 'expenses_root',
                    label: 'Expenses',
                    icon: <FaFileInvoiceDollar />,
                    subItems: [
                        { id: 'add_expense', label: 'Add Expense', icon: <FaPlusCircle /> },
                        { id: 'my_expenses', label: 'My Expenses', icon: <FaListUl /> },
                        { id: 'pending_approvals', label: 'Pending Approval', icon: <FaCheckCircle /> },
                        { id: 'team_expenses', label: 'All Team Expenses', icon: <FaUsersCog /> }
                    ]
                },
                {
                    id: 'funds_root',
                    label: 'Operational Fund',
                    icon: <FaWallet />,
                    subItems: [
                        { id: 'allocate_fund', label: 'Allocate Fund', icon: <FaHandHoldingUsd /> },
                        { id: 'received_funds', label: 'Received Funds', icon: <FaArrowDown /> },
                        { id: 'fund_history', label: 'Allocated History', icon: <FaHistory /> },
                        { id: 'fund_requests', label: 'Fund Requests', icon: <FaClipboardCheck /> }
                    ]
                },
                {
                    id: 'expansion_root',
                    label: 'Expansion Fund',
                    icon: <FaChartBar />,
                    subItems: [
                        { id: 'request_expansion', label: 'Request Expansion', icon: <FaPlusCircle /> },
                        { id: 'expansion_history', label: 'Request History', icon: <FaHistory /> }
                    ]
                },
                { id: 'reports', label: 'Reports', icon: <FaFileAlt /> },
                { id: 'settings', label: 'Settings', icon: <FaCog /> }
            ];
        } else {
            return [
                { id: 'dashboard', label: 'Dashboard', icon: <FaTachometerAlt /> },
                {
                    id: 'expenses_root',
                    label: 'Expenses',
                    icon: <FaFileInvoiceDollar />,
                    subItems: [
                        { id: 'add_expense', label: 'Add Expense', icon: <FaPlusCircle /> },
                        { id: 'my_expenses', label: 'My Expenses', icon: <FaListUl /> }
                    ]
                },
                { id: 'received_funds', label: 'Fund Received', icon: <FaArrowDown /> },
                { id: 'reports', label: 'Reports', icon: <FaFileAlt /> },
                { id: 'settings', label: 'Settings', icon: <FaCog /> }
            ];
        }
    };

    const handleMenuItemClick = (id) => {
        if (id === 'settings') return;
        navigate(`/dashboard?tab=${id}`);
    };

    return (
        <Layout
            title="Settings"
            menuItems={getMenuItems()}
            activeItem="settings"
            onMenuItemClick={handleMenuItemClick}
        >
            <div className="page-content">
                <div className="container-fluid" style={{ maxWidth: '1000px', margin: '0 auto' }}>
                    {/* Header with Back Button */}
                    <div className="settings-header fade-in-up">
                        <button
                            onClick={handleBack}
                            className="back-button"
                            title="Go Back"
                        >
                            <FaArrowLeft />
                        </button>
                        <div className="header-text">
                            <h2>System Settings</h2>

                        </div>
                    </div>

                    <div className="settings-grid">
                        {/* Appearance Section */}
                        <div className="card glass settings-card fade-in-up" style={{ animationDelay: '0.1s' }}>
                            <div className="card-header-styled">
                                <div className="icon-box primary">
                                    <FaPalette />
                                </div>
                                <div>
                                    <h3>Appearance</h3>
                                    <p>Customize the look and feel of your dashboard</p>
                                </div>
                            </div>

                            <div className="card-body">
                                <div className="theme-selector-grid">
                                    {themes.map(t => {
                                        let Icon;
                                        switch (t.id) {
                                            case 'light': Icon = FaSun; break;
                                            case 'dark': Icon = FaMoon; break;
                                            case 'ocean': Icon = FaWater; break;
                                            case 'forest': Icon = FaLeaf; break;
                                            case 'sunset': Icon = FaCloudSun; break;
                                            case 'midnight': Icon = FaStar; break;
                                            default: Icon = FaSun;
                                        }

                                        return (
                                            <button
                                                key={t.id}
                                                onClick={() => setTheme(t.id)}
                                                className={`theme-card ${theme === t.id ? 'active' : ''}`}
                                            >
                                                <div className="theme-preview" data-theme-preview={t.id}>
                                                    <div className="preview-nav"></div>
                                                    <div className="preview-content">
                                                        <div className="preview-line"></div>
                                                        <div className="preview-line"></div>
                                                    </div>
                                                    {theme === t.id && (
                                                        <div className="theme-check-overlay">
                                                            <FaCheckCircle />
                                                        </div>
                                                    )}
                                                </div>
                                                <div className="theme-info">
                                                    <Icon className="theme-icon-small" />
                                                    <span>{t.name}</span>
                                                </div>
                                            </button>
                                        );
                                    })}
                                </div>
                            </div>
                        </div>

                        {/* Localization Section - CEO Only */}
                        {isCEO && (
                            <div className="card glass settings-card fade-in-up" style={{ animationDelay: '0.2s' }}>
                                <div className="card-header-styled">
                                    <div className="icon-box success">
                                        <FaGlobe />
                                    </div>
                                    <div>
                                        <h3>Localization</h3>
                                        <p>Set your region and currency preferences</p>
                                    </div>
                                </div>

                                <div className="card-body">
                                    <div className="form-group custom-select-wrapper">
                                        <label className="input-label">
                                            <FaCoins /> Preferred Currency
                                        </label>
                                        <div className="currency-grid">
                                            {currencies.map(curr => (
                                                <button
                                                    key={curr.code}
                                                    onClick={() => setCurrency(curr.code)}
                                                    className={`currency-option ${currency === curr.code ? 'active' : ''}`}
                                                >
                                                    <span className="currency-flag">{curr.flag}</span>
                                                    <span className="currency-code">{curr.code}</span>
                                                    <span className="currency-symbol">{curr.symbol}</span>
                                                    {currency === curr.code && <FaCheck className="check-icon" />}
                                                </button>
                                            ))}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </Layout>
    );
};

export default Settings;

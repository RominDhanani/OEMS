import React, { useState, useEffect } from 'react';
import { FaWallet, FaBriefcase, FaSun, FaMoon, FaLeaf, FaWater, FaCloudSun, FaStar } from 'react-icons/fa';
import { useSettings } from '../context/SettingsContext';
import '../index.css';

const PublicLayout = ({ children }) => {
    const { theme, toggleTheme, themes } = useSettings();
    const [scrolled, setScrolled] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            if (window.scrollY > 20) {
                setScrolled(true);
            } else {
                setScrolled(false);
            }
        };

        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    // Find current theme object to get icon
    const currentTheme = themes?.find(t => t.id === theme) || themes?.[0];

    // Map theme IDs to specific icons (fallback if not in theme object or if we want specific React Icons here)
    const getThemeIcon = () => {
        switch (theme) {
            case 'light': return <FaSun />;
            case 'dark': return <FaMoon />;
            case 'ocean': return <FaWater />;
            case 'forest': return <FaLeaf />;
            case 'sunset': return <FaCloudSun />;
            case 'midnight': return <FaStar />;
            default: return <FaSun />;
        }
    };

    return (
        <div className="auth-layout">
            {/* Public Navbar */}
            <nav className={`auth-navbar ${scrolled ? 'scrolled' : ''}`}>
                <div className="app-brand-new">
                    <div className="brand-icon-box">
                        <FaBriefcase className="brand-logo-symbol" />
                    </div>
                    <div className="brand-text-col">
                        <h1 className="brand-title">OFFICE EXPENSE</h1>
                        <span className="brand-subtitle">MANAGEMENT</span>
                    </div>
                </div>

                <div className="auth-nav-actions">
                    <button
                        onClick={toggleTheme}
                        className="theme-toggle-btn"
                        aria-label="Cycle theme"
                        title={`Current Theme: ${currentTheme?.name || 'Light'}`}
                    >
                        {getThemeIcon()}
                    </button>
                </div>
            </nav>

            {/* Main Content Area */}
            <div className="auth-content">
                {children}
            </div>
        </div>
    );
};


export default PublicLayout;

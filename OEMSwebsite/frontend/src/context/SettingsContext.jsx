import React, { createContext, useState, useContext, useEffect } from 'react';
import { updatePdfConfig } from '../utils/pdfGenerator';
import { useAuth } from './AuthContext';
import { useSocket } from './SocketContext';

const SettingsContext = createContext();

export const useSettings = () => {
    const context = useContext(SettingsContext);
    if (!context) {
        throw new Error('useSettings must be used within a SettingsProvider');
    }
    return context;
};

const CURRENCY_CONFIG = {
    'INR': { symbol: '₹', locale: 'en-IN' },
    'USD': { symbol: '$', locale: 'en-US' },
    'EUR': { symbol: '€', locale: 'de-DE' },
    'GBP': { symbol: '£', locale: 'en-GB' },
    'JPY': { symbol: '¥', locale: 'ja-JP' },
    'CAD': { symbol: 'C$', locale: 'en-CA' },
    'AUD': { symbol: 'A$', locale: 'en-AU' },
    'AED': { symbol: 'د.إ', locale: 'ar-AE' },
    'SAR': { symbol: 'SR', locale: 'ar-SA' },
    'CNY': { symbol: '¥', locale: 'zh-CN' }
};

// Fallback rates if API fails
const FALLBACK_RATES = {
    'INR': 1,
    'USD': 0.012,
    'EUR': 0.011,
    'GBP': 0.0095,
    'JPY': 1.80,
    'CAD': 0.016,
    'AUD': 0.018,
    'AED': 0.044,
    'SAR': 0.045,
    'CNY': 0.086
};

export const SettingsProvider = ({ children }) => {
    const { user } = useAuth();
    const socket = useSocket();

    // Helper to get theme key
    const getThemeKey = () => user ? `theme_${user.id}` : 'theme';

    const [theme, setTheme] = useState(() => localStorage.getItem(getThemeKey()) || 'light');
    const [currency, setCurrencyState] = useState(localStorage.getItem('currency') || 'INR');
    const [rates, setRates] = useState(FALLBACK_RATES);
    const [isLoadingRates, setIsLoadingRates] = useState(true);

    // Wrapper that also emits socket event for live sync
    const setCurrency = (newCurrency) => {
        setCurrencyState(newCurrency);
        // Broadcast to all connected clients via socket
        if (socket) {
            socket.emit('changeCurrency', { currency: newCurrency });
        }
    };

    // Listen for live currency changes from other users (e.g., CEO changed currency)
    useEffect(() => {
        if (socket) {
            const handleSettingsUpdate = (data) => {
                if (data && data.currency && data.currency !== currency) {
                    console.log('Live currency update received:', data.currency);
                    setCurrencyState(data.currency);
                    localStorage.setItem('currency', data.currency);
                }
            };
            socket.on('settingsUpdated', handleSettingsUpdate);
            return () => socket.off('settingsUpdated', handleSettingsUpdate);
        }
    }, [socket, currency]);

    // Fetch live rates from INR base
    useEffect(() => {
        const fetchRates = async () => {
            try {
                const response = await fetch('https://open.er-api.com/v6/latest/INR');
                const data = await response.json();
                if (data && data.rates) {
                    setRates(data.rates);
                    console.log('Live rates loaded successfully');
                }
            } catch (error) {
                console.error('Failed to fetch live rates, using fallback:', error);
                setRates(FALLBACK_RATES);
            } finally {
                setIsLoadingRates(false);
            }
        };

        fetchRates();
    }, []);

    // Synchronize theme when user changes (login/logout)
    useEffect(() => {
        const storedTheme = localStorage.getItem(getThemeKey());
        if (storedTheme) {
            setTheme(storedTheme);
        } else {
            setTheme('light');
        }
    }, [user?.id]);

    useEffect(() => {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem(getThemeKey(), theme);
    }, [theme, user?.id]);

    useEffect(() => {
        localStorage.setItem('currency', currency);
        const config = CURRENCY_CONFIG[currency] || CURRENCY_CONFIG['INR'];
        const rate = rates[currency] || FALLBACK_RATES[currency] || 1;
        updatePdfConfig({
            symbol: config.symbol,
            locale: config.locale,
            rate: rate
        });
    }, [currency, rates]);

    const themes = [
        { id: 'light', name: 'Light', icon: '☀️' },
        { id: 'dark', name: 'Dark', icon: '🌙' },
        { id: 'ocean', name: 'Ocean', icon: '🌊' },
        { id: 'forest', name: 'Forest', icon: '🌲' },
        { id: 'sunset', name: 'Sunset', icon: '🌅' },
        { id: 'midnight', name: 'Midnight', icon: '🌑' }
    ];

    const toggleTheme = () => {
        setTheme(prev => {
            const currentIndex = themes.findIndex(t => t.id === prev);
            const nextIndex = (currentIndex + 1) % themes.length;
            return themes[nextIndex].id;
        });
    };

    const getCurrencySymbol = () => {
        return CURRENCY_CONFIG[currency]?.symbol || '₹';
    };

    const formatCurrencyValue = (amount) => {
        if (amount === null || amount === undefined || isNaN(amount)) return '-';

        const config = CURRENCY_CONFIG[currency] || CURRENCY_CONFIG['INR'];
        const rate = rates[currency] || FALLBACK_RATES[currency] || 1;

        // Convert from INR base to target currency using live rate
        const convertedAmount = parseFloat(amount) * rate;

        return config.symbol + convertedAmount.toLocaleString(config.locale, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    };

    return (
        <SettingsContext.Provider value={{
            theme, setTheme, toggleTheme, themes,
            currency, setCurrency,
            rates, isLoadingRates,
            getCurrencySymbol,
            formatCurrencyValue
        }}>
            {children}
        </SettingsContext.Provider>
    );
};

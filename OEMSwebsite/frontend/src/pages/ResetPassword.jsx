import React, { useState } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import PublicLayout from '../components/PublicLayout';
import { FaLock, FaEye, FaEyeSlash, FaCheck, FaTimes } from 'react-icons/fa';
import Toast from '../components/Toast';
import '../index.css';

const ResetPassword = () => {
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [message, setMessage] = useState('');
    const [errors, setErrors] = useState({});
    const [loading, setLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);
    const [isShaking, setIsShaking] = useState(false);

    const { token } = useParams();
    const navigate = useNavigate();

    const triggerShake = () => {
        setIsShaking(true);
        setTimeout(() => setIsShaking(false), 400);
    };

    const getPasswordStrength = (pass) => {
        if (!pass) return { score: 0, label: '', color: '' };
        let score = 0;
        if (pass.length >= 8) score++;
        if (/[A-Z]/.test(pass) && /[a-z]/.test(pass)) score++;
        if (/\d/.test(pass)) score++;
        if (/[^A-Za-z0-9]/.test(pass)) score++;

        if (score <= 1) return { score, label: 'Weak', color: 'weak' };
        if (score <= 3) return { score, label: 'Medium', color: 'medium' };
        return { score, label: 'Strong', color: 'strong' };
    };

    const strength = getPasswordStrength(password);

    const validate = () => {
        const newErrors = {};

        if (!password) {
            newErrors.password = 'Password is required';
        } else if (password.length < 8) {
            newErrors.password = 'Password must be at least 8 characters';
        } else if (!/[A-Z]/.test(password)) {
            newErrors.password = 'Include an uppercase letter';
        } else if (!/\d/.test(password)) {
            newErrors.password = 'Include at least one number';
        }

        if (password !== confirmPassword) {
            newErrors.confirmPassword = 'Passwords do not match';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setErrors({});
        setMessage('');

        if (!validate()) {
            triggerShake();
            return;
        }

        setLoading(true);
        try {
            const response = await fetch(`https://oems-backend.vercel.app/api/auth/reset-password/${token}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ password }),
            });

            const data = await response.json();

            if (response.ok) {
                setMessage(data.message);
                setTimeout(() => {
                    navigate('/login');
                }, 2000);
            } else {
                setErrors({ form: data.message || 'Failed to reset password' });
                triggerShake();
            }
        } catch (err) {
            console.error('Reset password failed:', err);
            setErrors({ form: 'Network error. Please try again.' });
            triggerShake();
        } finally {
            setLoading(false);
        }
    };

    return (
        <PublicLayout>
            {errors.form && <Toast message={errors.form} type="error" onClose={() => setErrors({ ...errors, form: '' })} />}
            {message && <Toast message={message} type="success" onClose={() => setMessage('')} />}

            <div className={`auth-card ${isShaking ? 'shake' : ''}`}>
                <h2 className="auth-title">Reset Password</h2>
                <p className="auth-subtitle" style={{ textAlign: 'center', marginBottom: '20px', color: 'var(--text-muted)' }}>
                    Please enter your new password below.
                </p>

                <form onSubmit={handleSubmit} noValidate>
                    <div className={`form-group ${errors.password ? 'shake' : ''}`}>
                        <label htmlFor="password">New Password</label>
                        <div className={`input-group ${errors.password ? 'is-invalid' : ''}`}>
                            <span className="input-icon">
                                <FaLock />
                            </span>
                            <input
                                type={showPassword ? 'text' : 'password'}
                                id="password"
                                name="password"
                                value={password}
                                onChange={(e) => {
                                    setPassword(e.target.value);
                                    if (errors.password) setErrors({ ...errors, password: '' });
                                }}
                                placeholder="Enter new password"
                                className={`has-icon ${errors.password ? 'is-invalid' : ''}`}
                                required
                            />
                            <button
                                type="button"
                                className="password-toggle"
                                onClick={() => setShowPassword(!showPassword)}
                                aria-label={showPassword ? 'Hide password' : 'Show password'}
                            >
                                {showPassword ? <FaEyeSlash /> : <FaEye />}
                            </button>
                        </div>
                        {password && (
                            <div className="password-strength-container animate-slide-in">
                                <div className="password-strength-bar">
                                    <div className={`password-strength-fill ${strength.color}`}></div>
                                </div>
                                <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '4px' }}>
                                    <span style={{ fontSize: '0.75rem', fontWeight: 600 }}>Strength: {strength.label}</span>
                                </div>
                                <ul className="password-hint-list">
                                    <li className={`password-hint-item ${password.length >= 8 ? 'valid' : ''}`}>
                                        {password.length >= 8 ? <FaCheck size={10} /> : <FaTimes size={10} />}
                                        At least 8 characters
                                    </li>
                                    <li className={`password-hint-item ${(/[A-Z]/.test(password) && /[a-z]/.test(password)) ? 'valid' : ''}`}>
                                        {(/[A-Z]/.test(password) && /[a-z]/.test(password)) ? <FaCheck size={10} /> : <FaTimes size={10} />}
                                        Uppercase & lowercase letters
                                    </li>
                                    <li className={`password-hint-item ${/\d/.test(password) ? 'valid' : ''}`}>
                                        {/\d/.test(password) ? <FaCheck size={10} /> : <FaTimes size={10} />}
                                        At least one number
                                    </li>
                                </ul>
                            </div>
                        )}
                        {errors.password && <span className="invalid-feedback">{errors.password}</span>}
                    </div>

                    <div className={`form-group ${errors.confirmPassword ? 'shake' : ''}`}>
                        <label htmlFor="confirmPassword">Confirm Password</label>
                        <div className={`input-group ${errors.confirmPassword ? 'is-invalid' : ''}`}>
                            <span className="input-icon">
                                <FaLock />
                            </span>
                            <input
                                type={showPassword ? 'text' : 'password'}
                                id="confirmPassword"
                                name="confirmPassword"
                                value={confirmPassword}
                                onChange={(e) => {
                                    setConfirmPassword(e.target.value);
                                    if (errors.confirmPassword) setErrors({ ...errors, confirmPassword: '' });
                                }}
                                placeholder="Confirm new password"
                                className={`has-icon ${errors.confirmPassword ? 'is-invalid' : ''}`}
                                required
                            />
                        </div>
                        {errors.confirmPassword && <span className="invalid-feedback">{errors.confirmPassword}</span>}
                    </div>

                    <button
                        type="submit"
                        className="btn btn-primary"
                        style={{ width: '100%', marginTop: '1rem', padding: '0.75rem' }}
                        disabled={loading}
                    >
                        {loading ? (
                            <>
                                <span className="btn-spinner"></span>
                                Resetting...
                            </>
                        ) : 'Reset Password'}
                    </button>
                </form>

                <p className="auth-footer">
                    <Link to="/login">Back to Login</Link>
                </p>
            </div>
        </PublicLayout>
    );
};


export default ResetPassword;


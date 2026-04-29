import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import PublicLayout from '../components/PublicLayout';
import { FaEnvelope } from 'react-icons/fa';
import Toast from '../components/Toast';
import '../index.css';

const ForgotPassword = () => {
    const [email, setEmail] = useState('');
    const [message, setMessage] = useState('');
    const [errors, setErrors] = useState({});
    const [loading, setLoading] = useState(false);
    const [isShaking, setIsShaking] = useState(false);

    const triggerShake = () => {
        setIsShaking(true);
        setTimeout(() => setIsShaking(false), 400);
    };

    const validate = () => {
        const newErrors = {};
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!email) {
            newErrors.email = 'Email is required';
        } else if (!emailRegex.test(email)) {
            newErrors.email = 'Please enter a valid email address';
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
            const response = await fetch('http://localhost:5000/api/auth/forgot-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email }),
            });

            const data = await response.json();

            if (response.ok) {
                setMessage(data.message);
                setEmail('');
            } else {
                setErrors({ email: data.message || 'Failed to send reset email' });
                triggerShake();
            }
        } catch (err) {
            console.error('Action failed:', err);
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
                <h2 className="auth-title">Forgot Password</h2>
                <p className="auth-subtitle" style={{ textAlign: 'center', marginBottom: '20px', color: 'var(--text-muted)' }}>
                    Enter your email address and we'll send you a link to reset your password.
                </p>

                <form onSubmit={handleSubmit} noValidate>
                    <div className={`form-group ${errors.email ? 'shake' : ''}`}>
                        <label htmlFor="email">Email</label>
                        <div className={`input-group ${errors.email ? 'is-invalid' : ''}`}>
                            <span className="input-icon">
                                <FaEnvelope />
                            </span>
                            <input
                                type="email"
                                id="email"
                                name="email"
                                value={email}
                                onChange={(e) => {
                                    setEmail(e.target.value);
                                    if (errors.email) setErrors({ ...errors, email: '' });
                                }}
                                placeholder="Enter your email"
                                className={`has-icon ${errors.email ? 'is-invalid' : ''}`}
                                required
                            />
                        </div>
                        {errors.email && <span className="invalid-feedback">{errors.email}</span>}
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
                                Sending...
                            </>
                        ) : 'Send Reset Link'}
                    </button>
                </form>

                <p className="auth-footer">
                    Remember your password?
                    <Link to="/login">Back to Login</Link>
                </p>
            </div>
        </PublicLayout>
    );
};


export default ForgotPassword;

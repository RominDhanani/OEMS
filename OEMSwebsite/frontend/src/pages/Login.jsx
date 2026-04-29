import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import PublicLayout from '../components/PublicLayout';

import { FaEnvelope, FaLock, FaEye, FaEyeSlash } from 'react-icons/fa';
import Toast from '../components/Toast';
import '../index.css';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isShaking, setIsShaking] = useState(false);

  const navigate = useNavigate();

  // 'password' or 'otp'
  const [loginMethod, setLoginMethod] = useState('password');
  const [otpSent, setOtpSent] = useState(false);
  const [otp, setOtp] = useState('');
  const { login, requestLoginOtp, loginWithOtp, user, logout } = useAuth();
  const [sessionCleared, setSessionCleared] = useState(false);

  React.useEffect(() => {
    if (user) {
      logout();
      setSessionCleared(true);
    }
  }, []);

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

    if (loginMethod === 'password') {
      if (!password) {
        newErrors.password = 'Password is required';
      }
    } else if (otpSent) {
      if (!otp) {
        newErrors.otp = 'OTP is required';
      } else if (otp.length !== 6) {
        newErrors.otp = 'OTP must be 6 digits';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrors({});

    if (!validate()) {
      triggerShake();
      return;
    }

    setLoading(true);

    try {
      if (loginMethod === 'password') {
        const result = await login(email, password);
        if (result.success) {
          navigate('/dashboard');
        } else {
          setErrors({ form: result.message });
          triggerShake();
        }
      } else {
        if (!otpSent) {
          const result = await requestLoginOtp(email);
          if (result.success) {
            setOtpSent(true);
          } else {
            setErrors({ email: result.message });
            triggerShake();
          }
        } else {
          const result = await loginWithOtp(email, otp);
          if (result.success) {
            navigate('/dashboard');
          } else {
            setErrors({ otp: result.message });
            triggerShake();
          }
        }
      }
    } catch (err) {
      setErrors({ form: 'An unexpected error occurred. Please try again.' });
      triggerShake();
    } finally {
      setLoading(false);
    }
  };

  const handleResendOtp = async () => {
    if (!email) return;
    setLoading(true);
    const result = await requestLoginOtp(email);
    if (!result.success) {
      setErrors({ email: result.message });
    }
    setLoading(false);
  };

  return (
    <PublicLayout>
      {errors.form && <Toast message={errors.form} type="error" onClose={() => setErrors({ ...errors, form: '' })} />}
      {sessionCleared && <Toast message="Your session has been securely closed." type="success" onClose={() => setSessionCleared(false)} />}
      <div className={`auth-card ${isShaking ? 'shake' : ''}`}>
        <h2 className="auth-title">Login</h2>

        <div className="login-method-toggle">
          <button
            type="button"
            className={`login-toggle-btn ${loginMethod === 'password' ? 'active' : ''}`}
            onClick={() => { setLoginMethod('password'); setOtpSent(false); setErrors({}); }}
          >
            Password
          </button>
          <button
            type="button"
            className={`login-toggle-btn ${loginMethod === 'otp' ? 'active' : ''}`}
            onClick={() => { setLoginMethod('otp'); setErrors({}); }}
          >
            OTP Login
          </button>
        </div>

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
                autoComplete="email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  if (errors.email) setErrors({ ...errors, email: '' });
                }}
                placeholder="Enter your email"
                className={`has-icon ${errors.email ? 'is-invalid' : ''}`}
                disabled={otpSent && loginMethod === 'otp'}
                required
              />
            </div>
            {errors.email && <span className="invalid-feedback">{errors.email}</span>}
            {loginMethod === 'otp' && otpSent && (
              <div style={{ textAlign: 'right', marginTop: '5px' }}>
                <button
                  type="button"
                  onClick={() => { setOtpSent(false); setOtp(''); setErrors({}); }}
                  style={{ background: 'none', border: 'none', color: 'var(--primary-600)', cursor: 'pointer', fontSize: '0.9rem' }}
                >
                  Change Email
                </button>
              </div>
            )}
          </div>

          {loginMethod === 'password' && (
            <div className={`form-group ${errors.password ? 'shake' : ''}`}>
              <label htmlFor="password">Password</label>
              <div className={`input-group ${errors.password ? 'is-invalid' : ''}`}>
                <span className="input-icon">
                  <FaLock />
                </span>
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="password"
                  name="password"
                  autoComplete="current-password"
                  value={password}
                  onChange={(e) => {
                    setPassword(e.target.value);
                    if (errors.password) setErrors({ ...errors, password: '' });
                  }}
                  placeholder="Enter your password"
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
              {errors.password && <span className="invalid-feedback">{errors.password}</span>}
              <div style={{ textAlign: 'right', marginTop: '5px' }}>
                <a href="/forgot-password" style={{ color: 'var(--text-muted)', fontSize: '0.9rem', textDecoration: 'none' }}>Forgot Password?</a>
              </div>
            </div>
          )}

          {loginMethod === 'otp' && otpSent && (
            <div className={`form-group ${errors.otp ? 'shake' : ''}`}>
              <label htmlFor="otp">One-Time Password (OTP)</label>
              <div className={`input-group ${errors.otp ? 'is-invalid' : ''}`}>
                <span className="input-icon">
                  <FaLock />
                </span>
                <input
                  type="text"
                  id="otp"
                  name="otp"
                  autoComplete="one-time-code"
                  value={otp}
                  onChange={(e) => {
                    const val = e.target.value.replace(/\D/g, '').slice(0, 6);
                    setOtp(val);
                    if (errors.otp) setErrors({ ...errors, otp: '' });
                  }}
                  placeholder="Enter 6-digit OTP"
                  className={`has-icon ${errors.otp ? 'is-invalid' : ''}`}
                  maxLength={6}
                  required
                />
              </div>
              {errors.otp && <span className="invalid-feedback">{errors.otp}</span>}
              <div style={{ textAlign: 'right', marginTop: '5px' }}>
                <button
                  type="button"
                  onClick={handleResendOtp}
                  disabled={loading}
                  style={{ background: 'none', border: 'none', color: 'var(--primary-600)', cursor: 'pointer', fontSize: '0.9rem' }}
                >
                  Resend OTP
                </button>
              </div>
            </div>
          )}

          <button
            type="submit"
            className="btn btn-primary"
            style={{ width: '100%', marginTop: '1rem', padding: '0.75rem' }}
            disabled={loading}
          >
            {loading ? (
              <>
                <span className="btn-spinner"></span>
                {loginMethod === 'password' ? 'Logging in...' : (otpSent ? 'Verifying...' : 'Sending OTP...')}
              </>
            ) : (
              loginMethod === 'password' ? 'Login' : (otpSent ? 'Verify & Login' : 'Send OTP')
            )}
          </button>
        </form>
        <p className="auth-footer">
          Don't have an account?
          <a href="/register">Register here</a>
        </p>
      </div>
    </PublicLayout>
  );
};

export default Login;

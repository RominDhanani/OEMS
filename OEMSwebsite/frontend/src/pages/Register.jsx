import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import PublicLayout from '../components/PublicLayout';

import { FaUser, FaEnvelope, FaLock, FaEye, FaEyeSlash, FaIdBadge, FaPhone, FaKey, FaCheck, FaTimes } from 'react-icons/fa';
import Toast from '../components/Toast';
import '../index.css';

const Register = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    full_name: '',
    mobile_number: '',
    role: 'USER'
  });
  const [otp, setOtp] = useState('');
  const [verificationToken, setVerificationToken] = useState('');

  // State for inline verification flows
  const [otpSent, setOtpSent] = useState(false);
  const [emailVerified, setEmailVerified] = useState(false);

  const [errors, setErrors] = useState({});
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  const [verifying, setVerifying] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isShaking, setIsShaking] = useState(false);

  const { register, requestRegistrationOtp, verifyRegistrationOtp } = useAuth();
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

  const strength = getPasswordStrength(formData.password);

  const validateField = (name, value) => {
    let error = '';
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const mobileRegex = /^[0-9]{10}$/;

    switch (name) {
      case 'full_name':
        if (!value.trim()) error = 'Full name is required';
        else if (value.trim().length < 3) error = 'Name must be at least 3 characters';
        break;
      case 'mobile_number':
        if (!value) error = 'Mobile number is required';
        else if (!mobileRegex.test(value)) error = 'Enter a valid 10-digit number';
        break;
      case 'email':
        if (!value) error = 'Email is required';
        else if (!emailRegex.test(value)) error = 'Enter a valid email address';
        break;
      case 'password':
        if (!value) error = 'Password is required';
        else if (value.length < 8) error = 'Password must be at least 8 characters';
        else if (!/[A-Z]/.test(value)) error = 'Include an uppercase letter';
        else if (!/\d/.test(value)) error = 'Include at least one number';
        break;
      default:
        break;
    }
    setErrors(prev => ({ ...prev, [name]: error }));
    return !error;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const handleSendOtp = async () => {
    setErrors(prev => ({ ...prev, email: '' }));
    setSuccess('');

    if (!validateField('email', formData.email)) {
      triggerShake();
      return;
    }

    setVerifying(true);
    const result = await requestRegistrationOtp(formData.email);
    setVerifying(false);

    if (result.success) {
      setSuccess('Verification code sent to your email.');
      setOtpSent(true);
      setOtp('');
    } else {
      setErrors(prev => ({ ...prev, email: result.message }));
      triggerShake();
    }
  };

  const handleVerifyOtp = async () => {
    setErrors(prev => ({ ...prev, otp: '' }));
    setSuccess('');

    if (otp.length !== 6) {
      setErrors(prev => ({ ...prev, otp: 'Enter 6-digit code' }));
      triggerShake();
      return;
    }

    setVerifying(true);
    const result = await verifyRegistrationOtp(formData.email, otp);
    setVerifying(false);

    if (result.success) {
      setSuccess('Email verified successfully!');
      setVerificationToken(result.verificationToken);
      setEmailVerified(true);
      setOtpSent(false);
    } else {
      setErrors(prev => ({ ...prev, otp: result.message }));
      triggerShake();
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    setSuccess('');

    let isValid = true;
    ['full_name', 'mobile_number', 'email', 'password'].forEach(field => {
      if (!validateField(field, formData[field])) isValid = false;
    });

    if (!isValid) {
      triggerShake();
      return;
    }

    if (!emailVerified) {
      setErrors(prev => ({ ...prev, email: 'Please verify your email first' }));
      triggerShake();
      return;
    }

    setLoading(true);
    const result = await register({ ...formData, verificationToken });

    if (result.success) {
      setSuccess('Registration successful! Please wait for CEO approval.');
      setTimeout(() => navigate('/login'), 3000);
    } else {
      setErrors({ form: result.message });
      triggerShake();
    }
    setLoading(false);
  };

  return (
    <PublicLayout>
      {errors.form && <Toast message={errors.form} type="error" onClose={() => setErrors({ ...errors, form: '' })} />}
      {success && <Toast message={success} type="success" onClose={() => setSuccess('')} />}
      <div className={`auth-card ${isShaking ? 'shake' : ''}`} style={{ maxWidth: '600px' }}>
        <h2 className="auth-title">Register</h2>

        <form onSubmit={handleSubmit} noValidate>
          <div className="form-grid-row">
            <div className={`form-group ${errors.full_name ? 'shake' : ''}`}>
              <label htmlFor="full_name">Full Name</label>
              <div className={`input-group ${errors.full_name ? 'is-invalid' : ''}`}>
                <span className="input-icon"><FaUser /></span>
                <input
                  type="text"
                  id="full_name"
                  name="full_name"
                  autoComplete="name"
                  value={formData.full_name}
                  onChange={handleChange}
                  onBlur={() => validateField('full_name', formData.full_name)}
                  placeholder="Your Name"
                  className={`has-icon ${errors.full_name ? 'is-invalid' : ''}`}
                  required
                />
              </div>
              {errors.full_name && <span className="invalid-feedback">{errors.full_name}</span>}
            </div>

            <div className={`form-group ${errors.mobile_number ? 'shake' : ''}`}>
              <label htmlFor="mobile_number">Mobile Number</label>
              <div className={`input-group ${errors.mobile_number ? 'is-invalid' : ''}`}>
                <span className="input-icon"><FaPhone /></span>
                <input
                  type="tel"
                  id="mobile_number"
                  name="mobile_number"
                  autoComplete="tel"
                  value={formData.mobile_number}
                  onChange={handleChange}
                  onBlur={() => validateField('mobile_number', formData.mobile_number)}
                  placeholder="10 Digits"
                  className={`has-icon ${errors.mobile_number ? 'is-invalid' : ''}`}
                  required
                />
              </div>
              {errors.mobile_number && <span className="invalid-feedback">{errors.mobile_number}</span>}
            </div>
          </div>

          <div className={`form-group ${errors.email ? 'shake' : ''}`}>
            <label htmlFor="email">
              Email Address 
              {emailVerified && <span style={{ color: 'var(--success-500)', marginLeft: '10px', fontSize: '0.8rem' }}><FaCheck style={{ marginRight: '4px' }} /> Verified</span>}
            </label>
            <div className={`input-group ${errors.email ? 'is-invalid' : ''}`}>
              <span className="input-icon"><FaEnvelope /></span>
              <input
                type="email"
                id="email"
                name="email"
                autoComplete="email"
                value={formData.email}
                onChange={handleChange}
                onBlur={() => !emailVerified && !otpSent && validateField('email', formData.email)}
                placeholder="name@company.com"
                className={`has-icon ${errors.email ? 'is-invalid' : ''}`}
                disabled={emailVerified || otpSent}
                required
              />
              {!emailVerified && !otpSent && (
                <button
                  type="button"
                  onClick={handleSendOtp}
                  disabled={verifying || !formData.email}
                  className="inline-action-btn"
                >
                  {verifying ? <span className="btn-spinner" style={{ width: '0.8rem', height: '0.8rem' }}></span> : 'Send OTP'}
                </button>
              )}
              {otpSent && !emailVerified && (
                <button type="button" onClick={() => { setOtpSent(false); setOtp(''); setErrors({}); }} className="inline-action-btn secondary">Change</button>
              )}
            </div>
            {errors.email && <span className="invalid-feedback">{errors.email}</span>}
          </div>

          {otpSent && !emailVerified && (
            <div className={`form-group animate-slide-in ${errors.otp ? 'shake' : ''}`}>
              <label htmlFor="otp">Verification Code</label>
              <div className={`input-group ${errors.otp ? 'is-invalid' : ''}`}>
                <span className="input-icon"><FaKey /></span>
                <input
                  type="text"
                  id="otp"
                  value={otp}
                  onChange={(e) => {
                    setOtp(e.target.value.replace(/\D/g, '').slice(0, 6));
                    if (errors.otp) setErrors({ ...errors, otp: '' });
                  }}
                  placeholder="Enter 6-digit code"
                  className={`has-icon ${errors.otp ? 'is-invalid' : ''}`}
                  maxLength={6}
                />
                <button
                  type="button"
                  onClick={handleVerifyOtp}
                  disabled={verifying || otp.length !== 6}
                  className="inline-action-btn"
                >
                  {verifying ? <span className="btn-spinner" style={{ width: '0.8rem', height: '0.8rem' }}></span> : 'Verify'}
                </button>
              </div>
              {errors.otp && <span className="invalid-feedback">{errors.otp}</span>}
              <div style={{ textAlign: 'right', marginTop: '5px' }}>
                <button type="button" onClick={handleSendOtp} style={{ background: 'none', border: 'none', color: 'var(--primary-600)', fontSize: '0.85rem', cursor: 'pointer' }}>Resend Code</button>
              </div>
            </div>
          )}

          <div className="form-group">
            <label htmlFor="role">Role</label>
            <div className="input-group">
              <span className="input-icon"><FaIdBadge /></span>
              <select
                id="role"
                name="role"
                value={formData.role}
                onChange={handleChange}
                className="has-icon"
                required
              >
                <option value="USER">General User</option>
                <option value="MANAGER">Manager</option>
              </select>
            </div>
          </div>

          <div className={`form-group ${errors.password ? 'shake' : ''}`}>
            <label htmlFor="password">Password</label>
            <div className={`input-group ${errors.password ? 'is-invalid' : ''}`}>
              <span className="input-icon"><FaLock /></span>
              <input
                type={showPassword ? 'text' : 'password'}
                id="password"
                name="password"
                autoComplete="new-password"
                value={formData.password}
                onChange={handleChange}
                onBlur={() => validateField('password', formData.password)}
                placeholder="Mixed case + numbers"
                className={`has-icon ${errors.password ? 'is-invalid' : ''}`}
                required
              />
              <button type="button" className="password-toggle" onClick={() => setShowPassword(!showPassword)}>
                {showPassword ? <FaEyeSlash /> : <FaEye />}
              </button>
            </div>
            
            {formData.password && (
              <div className="password-strength-container animate-slide-in">
                <div className="password-strength-bar">
                  <div className={`password-strength-fill ${strength.color}`}></div>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '4px' }}>
                  <span style={{ fontSize: '0.75rem', fontWeight: 600 }}>Strength: {strength.label}</span>
                </div>
                <ul className="password-hint-list">
                  <li className={`password-hint-item ${formData.password.length >= 8 ? 'valid' : ''}`}>
                    {formData.password.length >= 8 ? <FaCheck size={10} /> : <FaTimes size={10} />}
                    At least 8 characters
                  </li>
                  <li className={`password-hint-item ${(/[A-Z]/.test(formData.password) && /[a-z]/.test(formData.password)) ? 'valid' : ''}`}>
                    {(/[A-Z]/.test(formData.password) && /[a-z]/.test(formData.password)) ? <FaCheck size={10} /> : <FaTimes size={10} />}
                    Uppercase & lowercase letters
                  </li>
                  <li className={`password-hint-item ${/\d/.test(formData.password) ? 'valid' : ''}`}>
                    {/\d/.test(formData.password) ? <FaCheck size={10} /> : <FaTimes size={10} />}
                    At least one number
                  </li>
                </ul>
              </div>
            )}
            {errors.password && <span className="invalid-feedback">{errors.password}</span>}
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            style={{ width: '100%', marginTop: '1.5rem', padding: '12px' }}
            disabled={loading || !emailVerified}
          >
            {loading ? (
              <>
                <span className="btn-spinner"></span>
                Creating Account...
              </>
            ) : 'Register'}
          </button>
        </form>

        <p className="auth-footer">Already have an account? <Link to="/login">Login here</Link></p>
      </div>
    </PublicLayout>
  );
};


export default Register;

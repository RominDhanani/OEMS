import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { updateProfile, deleteProfileImage, getSessions, revokeSession, revokeAllOtherSessions } from '../services/api';
import { FaUser, FaCamera, FaEnvelope, FaPhone, FaLock, FaSave, FaIdCard, FaTrash, FaShieldAlt, FaDesktop, FaMobileAlt, FaSignOutAlt, FaExclamationCircle } from 'react-icons/fa';
import Toast from './Toast';

const ProfileSection = () => {
    const { user, updateUser } = useAuth();
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        mobile_number: '',
        password: '',
        confirm_password: ''
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    const [profileImage, setProfileImage] = useState(null);
    const [previewImage, setPreviewImage] = useState(null);

    // Validation & Animation States
    const [formErrors, setFormErrors] = useState({});
    const [isShaking, setIsShaking] = useState(false);

    const triggerShake = () => {
        setIsShaking(true);
        setTimeout(() => setIsShaking(false), 500);
    };

    const validateForm = () => {
        const errors = {};
        if (!formData.full_name?.trim()) errors.full_name = 'Full name is required';
        
        // Basic email regex
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!formData.email?.trim()) {
            errors.email = 'Email is required';
        } else if (!emailRegex.test(formData.email)) {
            errors.email = 'Please enter a valid email address';
        }

        if (formData.password) {
            if (formData.password.length < 6) {
                errors.password = 'Password must be at least 6 characters';
            }
            if (formData.password !== formData.confirm_password) {
                errors.confirm_password = 'Passwords do not match';
            }
        }

        if (!formData.mobile_number?.trim()) {
            errors.mobile_number = 'Mobile number is required';
        } else if (!/^\d{10}$/.test(formData.mobile_number.replace(/\D/g, ''))) {
            errors.mobile_number = 'Please enter a valid 10-digit mobile number';
        }

        setFormErrors(errors);
        return Object.keys(errors).length === 0;
    };

    useEffect(() => {
        if (user) {
            setFormData(prev => ({
                ...prev,
                full_name: user.full_name || '',
                email: user.email || '',
                mobile_number: user.mobile_number || ''
            }));
            if (user.profile_image) {
                setPreviewImage(user.profile_image.startsWith('http') ? user.profile_image : `https://oems-backend.vercel.app${user.profile_image.startsWith('/') ? '' : '/'}${user.profile_image.replace(/\\/g, '/')}`);
            }
        }
    }, [user]);

    const handleChange = (e) => {
        const name = e.target.name.replace('_profile', '').replace('_new', '');
        setFormData({ ...formData, [name]: e.target.value });
    };

    const handleImageChange = async (e) => {
        const file = e.target.files[0];
        if (file) {
            setProfileImage(file);
            setPreviewImage(URL.createObjectURL(file));

            const data = new FormData();
            data.append('profile_image', file);
            data.append('full_name', user.full_name);
            data.append('email', user.email);
            if (user.mobile_number) data.append('mobile_number', user.mobile_number);

            setLoading(true);
            try {
                const response = await updateProfile(data);
                setSuccess('Profile photo updated');
                if (response.data.user) updateUser(response.data.user);
            } catch (err) {
                setError('Failed to upload photo');
            }
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setFormErrors({});
        setSuccess('');

        if (!validateForm()) {
            triggerShake();
            return;
        }

        setLoading(true);
        try {
            const data = new FormData();
            data.append('full_name', formData.full_name);
            data.append('email', formData.email);
            if (formData.mobile_number) data.append('mobile_number', formData.mobile_number);
            if (formData.password) data.append('password', formData.password);
            if (profileImage) data.append('profile_image', profileImage);

            const response = await updateProfile(data);
            setSuccess(response.data.message || 'Profile updated successfully');
            setFormData(prev => ({ ...prev, password: '', confirm_password: '' }));
            setFormErrors({});
            if (response.data.user) updateUser(response.data.user);
        } catch (err) {
            setFormErrors({ form: err.response?.data?.message || 'Failed to update profile' });
            triggerShake();
        }
        setLoading(true); // Keep loading a bit longer for visual comfort
        setTimeout(() => setLoading(false), 500);
    };

    const handleDeleteImage = async () => {
        if (!window.confirm("Delete profile photo?")) return;
        setLoading(true);
        try {
            const response = await deleteProfileImage();
            setSuccess(response.data.message);
            setProfileImage(null); setPreviewImage(null);
            if (response.data.user) updateUser(response.data.user);
        } catch (err) {
            setError('Failed to delete image');
        }
        setLoading(false);
    };

    const isDirty = user && (
        formData.full_name !== (user.full_name || '') ||
        formData.email !== (user.email || '') ||
        formData.mobile_number !== (user.mobile_number || '') ||
        formData.password !== '' ||
        profileImage !== null
    );

    return (
        <div className="profile-container">
            {success && <Toast message={success} type="success" onClose={() => setSuccess('')} />}

            <div className="card">
                <div className="profile-hero-section">
                    <div className="profile-image-wrapper">
                        <div className="profile-image-container">
                            {previewImage ? (
                                <img src={previewImage} alt="Profile" />
                            ) : (
                                <FaUser className="placeholder-icon" />
                            )}
                        </div>
                        <div className="profile-image-actions">
                            <label htmlFor="p-up" className="action-btn upload" title="Update Photo">
                                <FaCamera />
                            </label>
                            {user?.profile_image && (
                                <button onClick={handleDeleteImage} className="action-btn delete" title="Remove Photo">
                                    <FaTrash />
                                </button>
                            )}
                        </div>
                        <input id="p-up" type="file" accept="image/*" hidden onChange={handleImageChange} />
                    </div>
                    <div className="profile-info-text">
                        <h2>{user?.full_name}</h2>
                        <span className="role-badge">{user?.role || 'User'}</span>
                    </div>
                </div>

                <form onSubmit={handleSubmit} autoComplete="off" noValidate className={isShaking ? 'shake' : ''}>
                    {/* Visual & Behavioral Honeypot to absorb browser auto-fill */}
                    <input type="text" name="email" style={{ display: 'none' }} tabIndex="-1" autoComplete="none" />
                    <input type="password" name="password" style={{ display: 'none' }} tabIndex="-1" autoComplete="none" />
                    
                    {formErrors.form && (
                        <div className="alert alert-danger fade-in" style={{ marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                            <FaExclamationCircle /> {formErrors.form}
                        </div>
                    )}
                    <div className="form-grid responsive-grid">
                        <div className={`form-group ${formErrors.full_name ? 'shake' : ''}`}>
                            <label htmlFor="full_name"><FaIdCard /> Full Name</label>
                            <input 
                                type="text" 
                                id="full_name"
                                name="full_name" 
                                className={formErrors.full_name ? 'is-invalid' : ''}
                                value={formData.full_name} 
                                onChange={handleChange} 
                                required 
                            />
                            {formErrors.full_name && <span className="invalid-feedback">{formErrors.full_name}</span>}
                        </div>
                        <div className={`form-group ${formErrors.email ? 'shake' : ''}`}>
                            <label htmlFor="email_profile"><FaEnvelope /> Email</label>
                            <input 
                                type="email" 
                                id="email_profile"
                                name="email_profile" 
                                className={formErrors.email ? 'is-invalid' : ''}
                                value={formData.email} 
                                onChange={handleChange} 
                                required 
                                autoComplete="off" 
                            />
                            {formErrors.email && <span className="invalid-feedback">{formErrors.email}</span>}
                        </div>
                        <div className={`form-group ${formErrors.mobile_number ? 'shake' : ''}`}>
                            <label htmlFor="mobile_number"><FaPhone /> Mobile</label>
                            <input 
                                type="tel" 
                                id="mobile_number"
                                name="mobile_number" 
                                className={formErrors.mobile_number ? 'is-invalid' : ''}
                                value={formData.mobile_number} 
                                onChange={handleChange} 
                                autoComplete="off" 
                            />
                            {formErrors.mobile_number && <span className="invalid-feedback">{formErrors.mobile_number}</span>}
                        </div>
                    </div>

                    <div className="section-title-premium themed">
                        <FaLock className="theme-icon" />
                        <h3>Security Settings</h3>
                    </div>
                    <div className="form-grid responsive-grid">
                        <div className={`form-group ${formErrors.password ? 'shake' : ''}`}>
                            <label htmlFor="password_new">New Password</label>
                            <input
                                type="password"
                                id="password_new"
                                name="password_new"
                                className={formErrors.password ? 'is-invalid' : ''}
                                value={formData.password}
                                onChange={handleChange}
                                placeholder="Leave blank to keep current"
                                autoComplete="new-password"
                            />
                            {formErrors.password && <span className="invalid-feedback">{formErrors.password}</span>}
                        </div>
                        <div className={`form-group ${formErrors.confirm_password ? 'shake' : ''}`}>
                            <label htmlFor="confirm_password_new">Confirm Password</label>
                            <input
                                type="password"
                                id="confirm_password_new"
                                name="confirm_password_new"
                                className={formErrors.confirm_password ? 'is-invalid' : ''}
                                value={formData.confirm_password}
                                onChange={handleChange}
                                disabled={!formData.password}
                                autoComplete="new-password"
                            />
                            {formErrors.confirm_password && <span className="invalid-feedback">{formErrors.confirm_password}</span>}
                        </div>
                    </div>

                    <div className="form-actions-sticky">
                        <button type="submit" className="btn btn-primary btn-save-profile" disabled={loading || !isDirty}>
                            {loading ? (
                                <><span className="spinner"></span> Processing...</>
                            ) : (
                                <><FaSave /> Save Changes</>
                            )}
                        </button>
                    </div>
                </form>
            </div >

            <div className="profile-card sessions-section fade-in-up">
                <div className="profile-header-premium">
                    <div className="header-icon">
                        <FaShieldAlt />
                    </div>
                    <div className="header-content">
                        <h2>Active Sessions</h2>
                        <p>Managing the security of your logged-in devices</p>
                    </div>
                </div>

                <div className="profile-body">
                    <ActiveSessionsList />
                </div>
            </div>
        </div >
    );
};

const ActiveSessionsList = () => {
    const [sessions, setSessions] = useState([]);
    const [loading, setLoading] = useState(true);
    const [revokingId, setRevokingId] = useState(null);
    const [revokingAll, setRevokingAll] = useState(false);

    const fetchSessions = async () => {
        try {
            setLoading(true);
            const response = await getSessions();
            setSessions(response.data.sessions || []);
        } catch (err) {
            console.error('Failed to fetch sessions:', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSessions();
    }, []);

    const handleRevoke = async (sessionId) => {
        if (!window.confirm('Are you sure you want to log out from this device?')) {
            return;
        }

        try {
            setRevokingId(sessionId);
            await revokeSession(sessionId);
            setSessions(sessions.filter(s => s.id !== sessionId));
        } catch (err) {
            console.error('Failed to revoke session:', err);
        } finally {
            setRevokingId(null);
        }
    };

    const handleRevokeAll = async () => {
        if (!window.confirm('Are you sure you want to log out of all other devices? This will leave your current session active.')) {
            return;
        }

        try {
            setRevokingAll(true);
            await revokeAllOtherSessions();
            // Refetch or simply filter locally removing all except current
            setSessions(sessions.filter(s => s.is_current));
        } catch (err) {
            console.error('Failed to revoke all other sessions:', err);
        } finally {
            setRevokingAll(false);
        }
    };

    const getDeviceDetails = (deviceInfo) => {
        const info = (deviceInfo || '').toLowerCase();
        let name = deviceInfo || 'Unknown Device';
        let isMobile = false;

        if (info.includes('iphone') || info.includes('android') || info.includes('mobile')) {
            isMobile = true;
            if (info.includes('iphone')) name = 'iPhone';
            else if (info.includes('android')) name = 'Android Phone';
        } else if (info.includes('ipad') || info.includes('tablet')) {
            isMobile = true;
            name = 'Tablet';
        } else if (info.includes('mac')) {
            name = 'Mac';
        } else if (info.includes('windows')) {
            name = 'Windows PC';
        } else if (info.includes('linux')) {
            name = 'Linux';
        }

        return { name, isMobile };
    };

    // Calculate how many "other" sessions exist
    const otherSessionsCount = sessions.filter(s => !s.is_current).length;

    if (loading) return <div className="loading-sessions">Loading active sessions...</div>;

    return (
        <div className="sessions-list-enhanced">
            {otherSessionsCount > 0 && (
                <div className="sessions-list-header">
                    <p className="sessions-sub-text">You are currently logged in on {sessions.length} device{sessions.length > 1 ? 's' : ''}.</p>
                    <button
                        className={`btn-revoke-all ${revokingAll ? 'revoking' : ''}`}
                        onClick={handleRevokeAll}
                        disabled={revokingAll}
                    >
                        {revokingAll ? <span className="spinner"></span> : <FaSignOutAlt />}
                        Log out of all other devices
                    </button>
                </div>
            )}

            {sessions.length === 0 ? (
                <p className="no-sessions">No active sessions found.</p>
            ) : (
                <div className="sessions-grid-styled">
                    {sessions.map(session => {
                        const isCurrent = session.is_current;
                        const deviceDetails = getDeviceDetails(session.device_info);

                        return (
                            <div key={session.id} className={`session-card-premium ${isCurrent ? 'current' : ''}`}>
                                <div className="session-icon-indicator">
                                    {deviceDetails.isMobile ? <FaMobileAlt /> : <FaDesktop />}
                                </div>
                                <div className="session-main-content">
                                    <div className="session-details-top">
                                        <h4 className="device-name">{deviceDetails.name}</h4>
                                        {isCurrent && <span className="premium-badge-inline">Current</span>}
                                    </div>
                                    <p className="session-meta">
                                        {session.device_info !== deviceDetails.name && (
                                            <span className="raw-device">{session.device_info} • </span>
                                        )}
                                        <span className="session-time">
                                            {isCurrent ? 'Active now' : `Last active: ${new Date(session.last_active).toLocaleString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}`}
                                        </span>
                                    </p>
                                </div>
                                {!isCurrent && (
                                    <div className="session-actions">
                                        <button
                                            className="btn-revoke-premium"
                                            onClick={() => handleRevoke(session.id)}
                                            disabled={revokingId === session.id}
                                            title="Log out of this device"
                                        >
                                            {revokingId === session.id ? <span className="spinner-small"></span> : 'Log Out'}
                                        </button>
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            )}
        </div>
    );
};

export default ProfileSection;


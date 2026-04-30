import React, { useState, useEffect } from 'react';
import {
    FaMoneyBillWave,
    FaMoneyCheckAlt,
    FaMobileAlt,
    FaCamera,
    FaCloudUploadAlt,
    FaArrowRight,
    FaCheckCircle,
    FaTimes
} from 'react-icons/fa';
import { useSettings } from '../context/SettingsContext';

/**
 * AllocationForm Component
 * Handles detailed fund allocation with Cash, Cheque, and UPI modes.
 */
const AllocationForm = ({
    managers,
    initialData,
    onSubmit,
    onCancel,
    loading
}) => {
    const { getCurrencySymbol } = useSettings();
    const currencySymbol = getCurrencySymbol();
    const [method, setMethod] = useState('CASH');
    const [formData, setFormData] = useState({
        to_user_id: '',
        amount: '',
        description: '',
        // Cheque fields
        cheque_number: '',
        bank_name: '',
        cheque_date: '',
        account_holder_name: '',
        cheque_image: null,
        // UPI fields
        upi_id: '',
        transaction_id: ''
    });
    const [errors, setErrors] = useState({});
    const [isShaking, setIsShaking] = useState(false);
    const [previewUrl, setPreviewUrl] = useState(null);

    useEffect(() => {
        if (initialData) {
            // Reset to defaults first to ensure no stale data persists (e.g. cheque details)
            const defaultState = {
                to_user_id: '',
                amount: '',
                description: '',
                cheque_number: '',
                bank_name: '',
                cheque_date: '',
                account_holder_name: '',
                cheque_image: null,
                upi_id: '',
                transaction_id: '',
                payment_mode: 'CASH'
            };

            setFormData({
                ...defaultState,
                ...initialData,
                payment_mode: initialData.payment_mode || 'CASH'
            });

            // Set preview URL for existing image
            if (initialData.cheque_image_path) {
                // Assuming backend serves uploads at root or /uploads, adjust if needed
                setPreviewUrl(`https://oems-backend.vercel.app/${initialData.cheque_image_path}`);
            } else {
                setPreviewUrl(null);
            }

            if (initialData.payment_mode) {
                setMethod(initialData.payment_mode);
            } else {
                setMethod('CASH');
            }
        }
    }, [initialData]);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
        if (errors[name]) setErrors(prev => ({ ...prev, [name]: '' }));
    };

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setFormData(prev => ({ ...prev, cheque_image: file }));
            setPreviewUrl(URL.createObjectURL(file));
            if (errors.cheque_image) setErrors(prev => ({ ...prev, cheque_image: '' }));
        }
    };

    const triggerShake = () => {
        setIsShaking(true);
        setTimeout(() => setIsShaking(false), 400);
    };

    const validateForm = () => {
        const newErrors = {};
        if (!formData.to_user_id) newErrors.to_user_id = 'Please select a manager';
        if (!formData.amount) newErrors.amount = 'Amount is required';
        else if (isNaN(formData.amount) || Number(formData.amount) <= 0) {
            newErrors.amount = 'Must be a positive number';
        }

        if (method === 'CHEQUE') {
            if (!formData.cheque_number) newErrors.cheque_number = 'Required';
            if (!formData.bank_name) newErrors.bank_name = 'Required';
            if (!formData.cheque_date) newErrors.cheque_date = 'Required';
            if (!formData.account_holder_name) newErrors.account_holder_name = 'Required';
        } else if (method === 'UPI') {
            if (!formData.upi_id) newErrors.upi_id = 'Required';
            else if (!formData.upi_id.includes('@')) newErrors.upi_id = 'Invalid UPI ID';
            if (!formData.transaction_id) newErrors.transaction_id = 'Required';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        setErrors({});

        if (!validateForm()) {
            triggerShake();
            return;
        }

        // Prepare FormData for submission
        const data = new FormData();
        data.append('to_user_id', formData.to_user_id);
        data.append('amount', formData.amount);
        data.append('description', formData.description || '');
        data.append('payment_mode', method);

        if (initialData?.expansion_id) {
            data.append('expansion_id', initialData.expansion_id);
        }

        if (method === 'CHEQUE') {
            data.append('cheque_number', formData.cheque_number);
            data.append('bank_name', formData.bank_name);
            data.append('cheque_date', formData.cheque_date);
            data.append('account_holder_name', formData.account_holder_name);
            if (formData.cheque_image) {
                data.append('cheque_image', formData.cheque_image);
            } else if (initialData?.cheque_image_path) {
                // Pass existing path if no new file uploaded
                data.append('existing_cheque_image_path', initialData.cheque_image_path);
            }
        } else if (method === 'UPI') {
            data.append('upi_id', formData.upi_id);
            data.append('transaction_id', formData.transaction_id);
        }

        onSubmit(data);
    };

    return (
        <div className={`allocation-form-container card ${isShaking ? 'shake' : ''}`} style={{ padding: '0', overflow: 'hidden', border: 'none', boxShadow: 'none' }}>


            <div className="allocation-grid">
                {/* Sidebar - Methods */}
                <div className="method-sidebar">
                    <button
                        type="button"
                        className={`method-btn ${method === 'CASH' ? 'active' : ''}`}
                        onClick={() => setMethod('CASH')}
                    >
                        <FaMoneyBillWave size={18} />
                        <div className="method-info">
                            <div className="method-title">Cash</div>
                            <div className="method-desc">Note exchange</div>
                        </div>
                        {method === 'CASH' && <FaCheckCircle className="check-icon" />}
                    </button>

                    <button
                        type="button"
                        className={`method-btn ${method === 'CHEQUE' ? 'active' : ''}`}
                        onClick={() => setMethod('CHEQUE')}
                    >
                        <FaMoneyCheckAlt size={18} />
                        <div className="method-info">
                            <div className="method-title">Cheque</div>
                            <div className="method-desc">Bank transfer</div>
                        </div>
                        {method === 'CHEQUE' && <FaCheckCircle className="check-icon" />}
                    </button>

                    <button
                        type="button"
                        className={`method-btn ${method === 'UPI' ? 'active' : ''}`}
                        onClick={() => setMethod('UPI')}
                    >
                        <FaMobileAlt size={18} />
                        <div className="method-info">
                            <div className="method-title">UPI</div>
                            <div className="method-desc">Digital payment</div>
                        </div>
                        {method === 'UPI' && <FaCheckCircle className="check-icon" />}
                    </button>
                </div>

                {/* content - Form */}
                <form onSubmit={handleSubmit} className="allocation-form p-4 md:p-8">

                    {/* Common Fields */}
                    {/* Common Fields */}
                    <div className="form-grid-row" style={{ marginBottom: '1.5rem' }}>
                        <div className={`form-group ${errors.to_user_id ? 'shake' : ''}`}>
                            <label htmlFor="to_user_id">To Manager *</label>
                            <select
                                id="to_user_id"
                                name="to_user_id"
                                value={formData.to_user_id}
                                onChange={handleInputChange}
                                required
                                className={`form-control ${errors.to_user_id ? 'is-invalid' : ''}`}
                            >
                                <option value="">Select Manager</option>
                                {managers.map(m => (
                                    <option key={m.id} value={m.id}>{m.full_name}</option>
                                ))}
                            </select>
                            {errors.to_user_id && <span className="invalid-feedback">{errors.to_user_id}</span>}
                        </div>
                        <div className={`form-group ${errors.amount ? 'shake' : ''}`}>
                            <label htmlFor="amount">Amount ({currencySymbol}) *</label>
                            <input
                                type="number"
                                id="amount"
                                step="0.01"
                                name="amount"
                                value={formData.amount}
                                onChange={handleInputChange}
                                required
                                className={`form-control ${errors.amount ? 'is-invalid' : ''}`}
                                placeholder="0.00"
                            />
                            {errors.amount && <span className="invalid-feedback">{errors.amount}</span>}
                        </div>
                    </div>

                    <div className="form-group" style={{ marginBottom: '1.5rem' }}>
                        <label>Description / Note</label>
                        <textarea
                            name="description"
                            value={formData.description}
                            onChange={handleInputChange}
                            className="form-control"
                            rows={2}
                            placeholder="E.g. Allocation for office supplies..."
                        />
                    </div>

                    <hr style={{ margin: '1.5rem 0', borderColor: 'var(--border-color)', opacity: 0.5 }} />

                    {/* Specific Fields */}
                    {method === 'CASH' && (
                        <div className="animate-fade-in">
                            <div className="alert alert-info" style={{ display: 'flex', gap: '0.75rem', alignItems: 'flex-start' }}>
                                <FaCheckCircle size={16} style={{ marginTop: '0.2rem' }} />
                                <div>
                                    <strong>Ready to Allocate</strong>
                                    <p style={{ margin: '0.25rem 0 0', fontSize: '0.9rem' }}>
                                        Ensure you have handed over the physical cash of <strong>{currencySymbol}{formData.amount || '0'}</strong> to the manager.
                                        This record will verify the transaction.
                                    </p>
                                </div>
                            </div>
                        </div>
                    )}

                    {method === 'CHEQUE' && (
                        <div className="animate-fade-in" style={{ display: 'grid', gap: '1.5rem' }}>
                            <div className="form-grid-row">
                                <div className={`form-group ${errors.cheque_number ? 'shake' : ''}`}>
                                    <label htmlFor="cheque_number">Cheque Number *</label>
                                    <input
                                        type="text"
                                        id="cheque_number"
                                        name="cheque_number"
                                        value={formData.cheque_number}
                                        onChange={handleInputChange}
                                        required
                                        className={`form-control ${errors.cheque_number ? 'is-invalid' : ''}`}
                                        placeholder="######"
                                    />
                                    {errors.cheque_number && <span className="invalid-feedback">{errors.cheque_number}</span>}
                                </div>
                                <div className={`form-group ${errors.bank_name ? 'shake' : ''}`}>
                                    <label htmlFor="bank_name">Bank Name *</label>
                                    <input
                                        type="text"
                                        id="bank_name"
                                        name="bank_name"
                                        value={formData.bank_name}
                                        onChange={handleInputChange}
                                        required
                                        className={`form-control ${errors.bank_name ? 'is-invalid' : ''}`}
                                        placeholder="E.g. HDFC Bank"
                                    />
                                    {errors.bank_name && <span className="invalid-feedback">{errors.bank_name}</span>}
                                </div>
                                <div className={`form-group ${errors.cheque_date ? 'shake' : ''}`}>
                                    <label htmlFor="cheque_date">Cheque Date *</label>
                                    <input
                                        type="date"
                                        id="cheque_date"
                                        name="cheque_date"
                                        value={formData.cheque_date}
                                        onChange={handleInputChange}
                                        required
                                        className={`form-control ${errors.cheque_date ? 'is-invalid' : ''}`}
                                    />
                                    {errors.cheque_date && <span className="invalid-feedback">{errors.cheque_date}</span>}
                                </div>
                                <div className={`form-group ${errors.account_holder_name ? 'shake' : ''}`}>
                                    <label htmlFor="account_holder_name">Account Holder Name *</label>
                                    <input
                                        type="text"
                                        id="account_holder_name"
                                        name="account_holder_name"
                                        value={formData.account_holder_name}
                                        onChange={handleInputChange}
                                        required
                                        className={`form-control ${errors.account_holder_name ? 'is-invalid' : ''}`}
                                    />
                                    {errors.account_holder_name && <span className="invalid-feedback">{errors.account_holder_name}</span>}
                                </div>
                            </div>

                            <div className="form-group">
                                <label>Upload Cheque Photo</label>
                                <div
                                    className="file-upload-zone"
                                    onClick={() => document.getElementById('cheque_upload').click()}
                                    style={{
                                        border: '2px dashed var(--secondary-300)',
                                        borderRadius: '8px',
                                        padding: '2rem',
                                        textAlign: 'center',
                                        cursor: 'pointer',
                                        transition: 'all 0.2s ease',
                                        background: 'var(--secondary-50)',
                                        position: 'relative'
                                    }}
                                    onMouseOver={(e) => {
                                        e.currentTarget.style.borderColor = 'var(--primary-500)';
                                        e.currentTarget.style.background = 'var(--primary-50)';
                                    }}
                                    onMouseOut={(e) => {
                                        e.currentTarget.style.borderColor = 'var(--secondary-300)';
                                        e.currentTarget.style.background = 'var(--secondary-50)';
                                    }}
                                >
                                    <input
                                        type="file"
                                        id="cheque_upload"
                                        accept="image/*"
                                        onChange={handleFileChange}
                                        style={{ display: 'none' }}
                                    />
                                    {previewUrl ? (
                                        <div style={{ position: 'relative', display: 'inline-block' }}>
                                            <img
                                                src={previewUrl}
                                                alt="Cheque Preview"
                                                style={{ maxHeight: '180px', borderRadius: '8px', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)' }}
                                            />
                                            <button
                                                type="button"
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    setFormData(prev => ({ ...prev, cheque_image: null }));
                                                    setPreviewUrl(null);
                                                }}
                                                style={{
                                                    position: 'absolute',
                                                    top: '-12px',
                                                    right: '-12px',
                                                    background: '#ef4444',
                                                    color: 'white',
                                                    border: '2px solid white',
                                                    borderRadius: '50%',
                                                    width: '28px',
                                                    height: '28px',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    cursor: 'pointer',
                                                    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                                                }}
                                                title="Remove Image"
                                            >
                                                <FaTimes size={14} />
                                            </button>
                                        </div>
                                    ) : (
                                        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0.75rem' }}>
                                            <div style={{
                                                width: '48px',
                                                height: '48px',
                                                borderRadius: '50%',
                                                background: 'var(--primary-100)',
                                                display: 'flex',
                                                alignItems: 'center',
                                                justifyContent: 'center',
                                                color: 'var(--primary-600)'
                                            }}>
                                                <FaCloudUploadAlt size={24} />
                                            </div>
                                            <div>
                                                <p style={{ margin: '0', fontWeight: '500', color: 'var(--text-main)' }}>Click to upload cheque image</p>
                                                <p style={{ margin: '0.25rem 0 0', fontSize: '0.85rem', color: 'var(--text-muted)' }}>SVG, PNG, JPG or GIF (max. 5MB)</p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                    )}

                    {method === 'UPI' && (
                        <div className="animate-fade-in" style={{ display: 'grid', gap: '1.5rem' }}>
                            <div className="form-grid-row">
                                <div className={`form-group ${errors.upi_id ? 'shake' : ''}`}>
                                    <label htmlFor="upi_id">UPI ID *</label>
                                    <input
                                        type="text"
                                        id="upi_id"
                                        name="upi_id"
                                        value={formData.upi_id}
                                        onChange={handleInputChange}
                                        required
                                        className={`form-control ${errors.upi_id ? 'is-invalid' : ''}`}
                                        placeholder="username@bank"
                                    />
                                    {errors.upi_id && <span className="invalid-feedback">{errors.upi_id}</span>}
                                </div>
                                <div className={`form-group ${errors.transaction_id ? 'shake' : ''}`}>
                                    <label htmlFor="transaction_id">Transaction ID *</label>
                                    <input
                                        type="text"
                                        id="transaction_id"
                                        name="transaction_id"
                                        value={formData.transaction_id}
                                        onChange={handleInputChange}
                                        required
                                        className={`form-control ${errors.transaction_id ? 'is-invalid' : ''}`}
                                        placeholder="Unique Transaction Ref"
                                    />
                                    {errors.transaction_id && <span className="invalid-feedback">{errors.transaction_id}</span>}
                                </div>
                            </div>
                            <div className="alert alert-info">
                                Verify the transaction ID from your UPI app before submitting.
                            </div>
                        </div>
                    )}

                    <div className="form-actions">
                        <button
                            type="button"
                            className="btn btn-secondary w-full sm:w-auto"
                            onClick={onCancel}
                            disabled={loading}
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            className="btn btn-primary w-full sm:w-auto flex items-center justify-center gap-2"
                            disabled={loading}
                        >
                            {loading ? (
                                <>
                                    <span className="btn-spinner"></span>
                                    Processing...
                                </>
                            ) : (
                                <>
                                    Allocate Fund <FaArrowRight />
                                </>
                            )}
                        </button>
                    </div>

                </form>
            </div>
        </div>
    );
};



export default AllocationForm;


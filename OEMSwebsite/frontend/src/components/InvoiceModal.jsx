import React from 'react';
import { FaDownload, FaTimes, FaTimesCircle, FaFileInvoiceDollar, FaBuilding, FaUser, FaCalendarAlt, FaTag, FaExchangeAlt, FaMoneyCheckAlt, FaInfoCircle, FaBriefcase, FaAlignLeft, FaPaperclip } from 'react-icons/fa';
import StatusBadge from './StatusBadge';
import DocumentList from './DocumentList';
import { getExpenseById } from '../services/api';
import { FaSpinner } from 'react-icons/fa';
import { useSettings } from '../context/SettingsContext';

const InvoiceModal = ({ data, type = 'EXPENSE', onClose, onDownload }) => {
    if (!data) return null;

    // Normalize data based on type
    const item = { ...data };

    // Inject Cheque Image for Funds if exists
    if (type === 'FUND' && item.cheque_image_path) {
        const docs = item.documents ? [...item.documents] : [];

        if (!docs.some(d => d.id === 'cheque_img')) {
            docs.push({
                id: 'cheque_img',
                document_path: item.cheque_image_path,
                original_filename: 'Cheque Image'
            });
        }
        item.documents = docs;
    }

    // Helper to detect linked expense in description
    const getLinkedExpenseInfo = (desc) => {
        if (!desc) return null;
        // Updated regex to catch "(ID: 32)" and "Expense #32"
        const match = desc.match(/(?:Allocation for Expense|Expense|ID:?)\s*[#]?\s*(\d+)(?:\s*-\s*(.*))?/i);
        if (match) {
            return { id: match[1], title: match[2] || 'View Details' };
        }
        return null;
    };

    const linkedExpense = (type === 'FUND' || type === 'TRANSACTION' || type === 'EXPANSION')
        ? getLinkedExpenseInfo(item.description || item.justification)
        : null;

    const [linkedDocuments, setLinkedDocuments] = React.useState([]);
    const [loadingLinkedDocs, setLoadingLinkedDocs] = React.useState(false);
    const [docsLoaded, setDocsLoaded] = React.useState(false);
    const [highlight, setHighlight] = React.useState(false);

    // Trigger flash animation on status or amount change (Real-time sync)
    React.useEffect(() => {
        if (item.id) {
            setHighlight(true);
            const timer = setTimeout(() => setHighlight(false), 800);
            return () => clearTimeout(timer);
        }
    }, [item.status, item.amount]);

    // Auto-load linked documents
    React.useEffect(() => {
        if (linkedExpense) {
            handleLoadLinkedDocuments();
        }
    }, [linkedExpense ? linkedExpense.id : null]);

    const handleLoadLinkedDocuments = async () => {
        if (!linkedExpense) return;
        setLoadingLinkedDocs(true);
        try {
            const res = await getExpenseById(linkedExpense.id);
            if (res.data.documents && res.data.documents.length > 0) {
                setLinkedDocuments(res.data.documents);
            }
            // Even if no docs, we mark as loaded so we don't try again
            setDocsLoaded(true);
        } catch (err) {
            console.error('Failed to load linked expense docs', err);
        }
        setLoadingLinkedDocs(false);
    };

    const { formatCurrencyValue } = useSettings();

    const formatCurrency = (amount) => formatCurrencyValue(amount);

    const formatDate = (dateString, includeTime = false) => {
        if (!dateString) return '-';
        const options = {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        };
        if (includeTime) {
            options.hour = '2-digit';
            options.minute = '2-digit';
        }
        return new Date(dateString).toLocaleDateString('en-GB', options);
    };

    // Configuration based on type
    const config = {
        EXPENSE: {
            title: 'Expense Invoice',
            idPrefix: 'EXP-',
            color: '#1e3a8a', // Deep Blue
            accent: '#3b82f6',
            icon: <FaFileInvoiceDollar />,
            dateField: 'expense_date',
            amountField: 'amount',
            userLabel: 'Submitted By',
            userField: 'full_name', // or user_name
            deptField: 'department'
        },
        FUND: {
            title: 'Fund Transaction',
            idPrefix: 'TRX-',
            color: '#065f46', // Deep Emerald
            accent: '#10b981',
            icon: <FaExchangeAlt />,
            dateField: 'created_at',
            amountField: 'amount',
            userLabel: item.to_user_id ? 'Allocated To' : 'Received From',
            userField: item.to_user_id ? 'to_user_name' : 'from_user_name',
            deptField: null // Funds might not have dept readily available
        },
        EXPANSION: {
            title: 'Expansion Request',
            idPrefix: 'REQ-',
            color: '#92400e', // Deep Amber
            accent: '#f59e0b',
            icon: <FaMoneyCheckAlt />,
            dateField: 'requested_at',
            amountField: 'requested_amount',
            userLabel: 'Requested By',
            userField: 'manager_name',
            deptField: null
        }
    };

    const currentConfig = config[type] || config.EXPENSE;
    const themeColor = currentConfig.color;

    // Resolve dynamic fields with roles
    const userRole = item.user_role || item.role || item.manager_role || (item.to_user_id ? item.to_role : item.from_role);
    const rawName = item[currentConfig.userField] || item.user_name || item.manager_name || 'User';
    const userName = userRole ? `${rawName} (${userRole})` : rawName;
    const amount = item[currentConfig.amountField] || item.amount;
    const date = item[currentConfig.dateField];

    // Styles for ERP Look - Responsive Fonts
    const labelStyle = {
        fontSize: 'clamp(0.6rem, 1.5vw, 0.7rem)', // Responsive label
        color: 'var(--text-muted)', // Use variable
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        fontWeight: '600',
        marginBottom: '0.2rem',
        fontFamily: 'var(--font-display)' // Ensure consistent font
    };

    const valueStyle = {
        fontSize: 'clamp(0.75rem, 2vw, 0.9rem)', // Responsive value
        color: 'var(--text-main)', // Use variable
        fontWeight: '500',
        lineHeight: '1.4',
        wordBreak: 'break-word' // Prevent overflow on small screens
    };

    const sectionTitleStyle = {
        fontSize: '0.75rem',
        fontWeight: '700',
        color: 'var(--text-main)',
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        borderBottom: '1px solid var(--border-light)',
        paddingBottom: '0.5rem',
        marginBottom: '1rem',
        display: 'flex',
        alignItems: 'center',
        gap: '0.5rem'
    };

    return (
        <div className="modal-overlay" onClick={onClose} style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'var(--glass-bg)', // Use variable for overlay
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 2000,
            backdropFilter: 'blur(4px)'
        }}>
            <div className="modal-content" onClick={e => e.stopPropagation()} style={{
                background: 'var(--bg-card)',
                width: '95%', // Responsive width
                maxWidth: '750px', // Slightly narrower for document feel
                borderRadius: '8px', // Sharper corners
                boxShadow: 'var(--shadow-xl)',
                overflow: 'hidden',
                display: 'flex',
                flexDirection: 'column',
                maxHeight: '90vh',
                border: '1px solid var(--border-light)',
                animation: 'fade-in-up 0.3s ease-out'
            }}>
                {/* Header - Compact & Premium */}
                <div style={{
                    background: 'var(--bg-card)',
                    padding: '1rem 1.5rem',
                    borderBottom: '1px solid var(--border-light)',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <div style={{
                            width: '36px',
                            height: '36px',
                            borderRadius: '6px',
                            background: themeColor,
                            color: 'white',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '1rem',
                            boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                        }}>
                            {currentConfig.icon}
                        </div>
                        <div>
                            <h2 style={{
                                margin: 0,
                                fontSize: 'clamp(0.9rem, 2.5vw, 1.1rem)', // Responsive Title
                                fontWeight: '700',
                                color: 'var(--text-main)',
                                letterSpacing: '-0.01em',
                                textTransform: 'uppercase'
                            }}>
                                {currentConfig.title}
                            </h2>
                            <div style={{
                                fontSize: '0.75rem',
                                color: 'var(--text-muted)',
                                fontWeight: '500',
                                fontFamily: 'monospace'
                            }}>
                                #{currentConfig.idPrefix}{String(item.id).padStart(4, '0')}
                            </div>
                        </div>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                                    <StatusBadge status={item.status} />
                        <button onClick={onClose} style={{
                            background: 'none', border: 'none', color: '#94a3b8', cursor: 'pointer', fontSize: '1.2rem', padding: '0.25rem'
                        }}>
                            <FaTimesCircle />
                        </button>
                    </div>
                </div>

                {/* Body - High Density Grid */}
                <div style={{ padding: '1.5rem', overflowY: 'auto', flex: 1, background: 'var(--secondary-50)' }}>

                    {/* Rejection Reason Alert */}
                    {item.status === 'REJECTED' && (
                        <div style={{
                            background: '#fee2e2',
                            border: '1px solid #ef4444',
                            borderRadius: '6px',
                            padding: '1rem',
                            marginBottom: '1rem',
                            display: 'flex',
                            alignItems: 'start',
                            gap: '0.75rem',
                            color: '#991b1b'
                        }}>
                            <FaTimesCircle style={{ marginTop: '0.2rem', flexShrink: 0 }} />
                            <div>
                                <div style={{ fontSize: '0.75rem', fontWeight: '700', textTransform: 'uppercase', marginBottom: '0.2rem' }}>Rejection Reason</div>
                                <div style={{ fontSize: '0.85rem', lineHeight: '1.4' }}>{item.rejection_reason || 'No reason provided.'}</div>
                            </div>
                        </div>
                    )}

                    {/* Primary Info Card */}
                    {/* Primary Info Card */}
                    <div style={{
                        background: 'var(--bg-card)',
                        border: '1px solid var(--border-light)',
                        borderRadius: '6px',
                        padding: '1.25rem',
                        marginBottom: '1rem',
                        display: 'grid',
                        gridTemplateColumns: 'repeat(auto-fit, minmax(120px, 1fr))', // Auto-wrapping columns
                        gap: '1.5rem',
                        alignItems: 'start'
                    }}>
                        <div style={{ gridColumn: 'span 2', minWidth: '200px' }}> {/* Force wider span if possible */}
                            <div style={labelStyle}>{currentConfig.userLabel}</div>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', ...valueStyle }}>
                                <div style={{ width: '24px', height: '24px', borderRadius: '50%', background: 'var(--secondary-100)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)', fontSize: '0.7rem' }}>
                                    <FaUser />
                                </div>
                                {userName}
                            </div>
                            {currentConfig.deptField && item[currentConfig.deptField] && (
                                <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.2rem', paddingLeft: '2rem' }}>
                                    {item[currentConfig.deptField]}
                                </div>
                            )}
                        </div>

                        <div>
                            <div style={labelStyle}>Date</div>
                            <div style={valueStyle}>{formatDate(date, true)}</div>
                        </div>

                        <div style={{ textAlign: 'left' }}> {/* Align left on mobile usually looks better when wrapped */}
                            <div style={labelStyle}>Total Amount</div>
                            <div className={highlight ? 'animate-pulse-highlight' : ''} style={{ fontSize: 'clamp(13px, 0.7058vw + 9px, 1rem)', fontWeight: '700', color: 'var(--primary-500)', fontFamily: 'var(--font-display)', lineHeight: 1 }}>
                                {formatCurrency(amount)}
                            </div>
                        </div>
                    </div>

                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem' }}>

                        {/* Details Column */}
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                            {/* Generic Details */}
                            <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border-light)', borderRadius: '6px', padding: '1.25rem' }}>
                                <div style={sectionTitleStyle}><FaAlignLeft size={10} /> Details</div>

                                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: '1.25rem' }}>
                                    {type === 'EXPENSE' && (
                                        <>
                                            <div style={{ gridColumn: '1 / -1' }}> {/* Span full width */}
                                                <div style={labelStyle}>Subject / Title</div>
                                                <div style={valueStyle}>{item.title}</div>
                                            </div>
                                            <div>
                                                <div style={labelStyle}>Category</div>
                                                <div style={valueStyle}>
                                                    <span style={{ background: 'var(--secondary-100)', padding: '2px 8px', borderRadius: '4px', fontSize: '0.8rem', color: 'var(--text-main)' }}>
                                                        {item.category}
                                                    </span>
                                                </div>
                                            </div>
                                            <div>
                                                <div style={labelStyle}>Expense ID</div>
                                                <div style={{ ...valueStyle, fontFamily: 'monospace' }}>EXP-{item.id}</div>
                                            </div>
                                            <div>
                                                <div style={labelStyle}>Status</div>
                                                <div style={valueStyle}>
                                                                                <StatusBadge status={item.status} />
                                                </div>
                                            </div>
                                        </>
                                    )}

                                    {type === 'FUND' && (
                                        <>
                                            <div>
                                                <div style={labelStyle}>Payment Mode</div>
                                                <div style={valueStyle}>{item.payment_mode || 'Cash'}</div>
                                            </div>
                                            {item.payment_mode === 'CHEQUE' && (
                                                <>
                                                    <div><div style={labelStyle}>Cheque No</div><div style={valueStyle}>{item.cheque_number || '-'}</div></div>
                                                    <div><div style={labelStyle}>Bank Name</div><div style={valueStyle}>{item.bank_name || '-'}</div></div>
                                                    <div><div style={labelStyle}>Cheque Date</div><div style={valueStyle}>{formatDate(item.cheque_date)}</div></div>
                                                </>
                                            )}
                                            {item.payment_mode === 'UPI' && (
                                                <>
                                                    <div><div style={labelStyle}>UPI ID</div><div style={valueStyle}>{item.upi_id || '-'}</div></div>
                                                    <div><div style={labelStyle}>Transaction ID</div><div style={valueStyle}>{item.transaction_id || '-'}</div></div>
                                                </>
                                            )}
                                            <div>
                                                <div style={labelStyle}>Status</div>
                                                <div style={valueStyle}>
                                                                                <StatusBadge status={item.status} />
                                                </div>
                                            </div>
                                        </>
                                    )}

                                    {type === 'EXPANSION' && (
                                        <>
                                            <div>
                                                <div style={labelStyle}>Approved Amount</div>
                                                <div style={{ ...valueStyle, color: 'var(--success-600)', fontWeight: '600' }}>
                                                    {item.approved_amount ? formatCurrency(item.approved_amount) : 'Pending'}
                                                </div>
                                            </div>
                                            <div>
                                                <div style={labelStyle}>Status</div>
                                                <div style={valueStyle}>
                                                                                <StatusBadge status={item.status} />
                                                </div>
                                            </div>
                                        </>
                                    )}
                                </div>

                                <div style={{ marginTop: '1.25rem', paddingTop: '1rem', borderTop: '1px dashed var(--border-light)' }}>
                                    <div style={labelStyle}>{type === 'EXPANSION' ? 'Justification' : 'Description'}</div>
                                    <div style={{ fontSize: '0.85rem', color: 'var(--text-main)', lineHeight: '1.6', background: 'var(--secondary-50)', padding: '0.75rem', borderRadius: '4px', border: '1px solid var(--border-light)', wordBreak: 'break-word' }}>
                                        {item.description || item.justification || <span style={{ color: 'var(--text-muted)', fontStyle: 'italic' }}>No specific details provided.</span>}
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Side Column: Attachments & Meta */}
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>

                            {/* Linked Expense / Info Box */}
                            {linkedExpense && (
                                <div style={{ background: 'var(--primary-50)', border: '1px solid var(--primary-200)', borderRadius: '6px', padding: '1rem' }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
                                        <FaInfoCircle size={12} color="var(--primary-500)" />
                                        <span style={{ fontSize: '0.75rem', fontWeight: '700', color: 'var(--primary-700)', textTransform: 'uppercase' }}>Related Expense</span>
                                    </div>
                                    <div style={{
                                        fontSize: '0.75rem',
                                        color: 'var(--primary-600)',
                                        marginBottom: '0.5rem',
                                        fontWeight: '600',
                                        background: 'var(--primary-100)',
                                        padding: '4px 8px',
                                        borderRadius: '4px',
                                        display: 'inline-block'
                                    }}>
                                        ALLOCATED FOR REQ #{linkedExpense.id}
                                    </div>

                                    {loadingLinkedDocs ? (
                                        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.5rem', fontStyle: 'italic' }}>
                                            <FaSpinner className="spin" size={12} /> Retrieving voucher...
                                        </div>
                                    ) : (
                                        <div style={{ marginTop: '0.5rem' }}>
                                            <div style={{ fontSize: '0.7rem', fontWeight: '700', color: 'var(--text-main)', marginBottom: '0.25rem', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                                                Linked Voucher
                                            </div>
                                            {linkedDocuments.length > 0 ? (
                                                <DocumentList documents={linkedDocuments} />
                                            ) : (
                                                <div style={{ fontSize: '0.75rem', color: '#94a3b8', fontStyle: 'italic' }}>- No voucher attached -</div>
                                            )}
                                        </div>
                                    )}
                                </div>
                            )}

                            {/* Attachments */}
                            <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border-light)', borderRadius: '6px', padding: '1.25rem', flex: 1 }}>
                                <div style={sectionTitleStyle}><FaPaperclip size={10} /> Attachments ({item.documents ? item.documents.length : 0})</div>
                                {item.documents && item.documents.length > 0 ? (
                                    <DocumentList documents={item.documents} />
                                ) : (
                                    <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontStyle: 'italic', textAlign: 'center', padding: '1rem' }}>
                                        No documents attached.
                                    </div>
                                )}
                            </div>

                            {/* Approval Stamp */}
                            {item.approved_by_name && type === 'EXPENSE' && (
                                <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border-light)', borderRadius: '6px', padding: '1rem' }}>
                                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.5rem' }}>Approved By</div>
                                    <div style={{ fontSize: '0.85rem', fontWeight: '600', color: 'var(--text-main)' }}>{item.approved_by_name}</div>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{item.approved_by_role}</div>
                                </div>
                            )}
                        </div>
                    </div>
                </div>

                {/* Footer Actions */}
                <div style={{
                    padding: '1rem 1.5rem',
                    background: 'var(--bg-card)',
                    borderTop: '1px solid var(--border-light)',
                    display: 'flex',
                    justifyContent: 'flex-end',
                    gap: '0.75rem',
                    alignItems: 'center'
                }}>
                    <button
                        onClick={onClose}
                        style={{
                            background: 'var(--bg-card)',
                            border: '1px solid var(--secondary-300)',
                            color: 'var(--text-main)',
                            padding: '0.5rem 1rem',
                            borderRadius: '6px',
                            fontWeight: '600',
                            fontSize: '0.85rem',
                            cursor: 'pointer'
                        }}
                    >
                        Close
                    </button>
                    <button
                        onClick={() => onDownload(item)}
                        style={{
                            background: themeColor,
                            border: 'none',
                            color: 'white',
                            padding: '0.5rem 1rem',
                            borderRadius: '6px',
                            fontWeight: '600',
                            fontSize: '0.85rem',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '0.5rem',
                            cursor: 'pointer',
                            boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                        }}
                    >
                        <FaDownload size={12} /> {type === 'EXPENSE' ? 'Download PDF' : 'Download'}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default InvoiceModal;

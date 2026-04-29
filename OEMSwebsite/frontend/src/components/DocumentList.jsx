import React from 'react';
import { FaFileAlt, FaEye, FaDownload } from 'react-icons/fa';
import { handleViewDocument, handleDownloadDocument } from '../utils/documentHandlers';

const DocumentList = ({ documents = [] }) => {
    if (!documents || documents.length === 0) return null;

    return (
        <div className="document-list">
            <div className="document-grid">
                {documents.map((doc, index) => (
                    <div key={doc.id || index} className="document-item" style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        padding: '0.5rem',
                        background: 'var(--bg-card)',
                        border: '1px solid var(--border-light)',
                        borderRadius: '4px',
                        transition: 'all 0.2s',
                    }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', overflow: 'hidden', flex: 1, minWidth: 0 }}>
                            <div className="doc-icon" style={{
                                width: '28px',
                                height: '28px',
                                background: 'var(--secondary-100)',
                                color: 'var(--text-muted)',
                                borderRadius: '4px',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                flexShrink: 0,
                                border: '1px solid var(--border-light)'
                            }}>
                                <FaFileAlt size={12} />
                            </div>
                            <div style={{ overflow: 'hidden', flex: 1, minWidth: 0 }}>
                                <div style={{ fontWeight: '600', fontSize: '0.75rem', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', color: 'var(--text-main)' }}>
                                    {doc.original_filename || `Document ${index + 1}`}
                                </div>
                                <div style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>
                                    Voucher
                                </div>
                            </div>
                        </div>
                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                            <button
                                onClick={() => handleViewDocument(doc.document_path)}
                                className="btn-icon"
                                title="View"
                                style={{
                                    background: 'var(--bg-card)',
                                    border: '1px solid var(--secondary-200)',
                                    color: 'var(--secondary-600)',
                                    padding: '6px',
                                    borderRadius: '6px',
                                    cursor: 'pointer',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center'
                                }}
                            >
                                <FaEye size={14} />
                            </button>
                            <button
                                onClick={() => handleDownloadDocument(doc.document_path, doc.original_filename)}
                                className="btn-icon"
                                title="Download"
                                style={{
                                    background: 'var(--primary-50)',
                                    border: '1px solid var(--primary-200)',
                                    color: 'var(--primary-600)',
                                    padding: '6px',
                                    borderRadius: '6px',
                                    cursor: 'pointer',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center'
                                }}
                            >
                                <FaDownload size={14} />
                            </button>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default DocumentList;

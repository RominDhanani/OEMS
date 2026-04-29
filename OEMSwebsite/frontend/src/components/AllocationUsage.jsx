import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { getAllocationUsage } from '../services/api';
import StatusBadge from './StatusBadge';
import { FaMoneyBillWave, FaUserTie, FaUsers, FaChartPie, FaWallet, FaEye, FaDownload, FaTimesCircle } from 'react-icons/fa';
import { generateProfessionalPDF, generateManagerReportPDF } from '../utils/pdfGenerator';
import { useTableFilters } from '../hooks/useTableFilters';
import TableControls from '../components/TableControls';
import TablePagination from '../components/TablePagination';
import { useSettings } from '../context/SettingsContext';

const AllocationUsage = () => {
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [expandedManagers, setExpandedManagers] = useState({});
    const [viewManager, setViewManager] = useState(null);

    const {
        searchTerm,
        setSearchTerm,
        currentPage,
        setCurrentPage,
        itemsPerPage,
        setItemsPerPage,
        currentItems,
        totalPages,
        filteredData
    } = useTableFilters(data, ['manager_name', 'total_received', 'manager_balance']);

    const { formatCurrencyValue } = useSettings();

    const exportAllocationData = (data, title) => {
        const columns = [
            { header: 'Manager', key: 'manager_name' },
            { header: 'Role', key: 'role', format: () => 'MANAGER' },
            { header: 'Allocated Fund', key: 'total_received', format: (v) => formatCurrency(v) },
            { header: 'Own Usage', key: 'manager_own_usage', format: (v) => formatCurrency(v) },
            { header: 'Balance', key: 'manager_balance', format: (v) => formatCurrency(v) },
            { header: 'Team Size', key: 'team_usage_breakdown', format: (v) => v.length + ' Members' }
        ];

        generateProfessionalPDF(title, columns, data);
    };

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            const response = await getAllocationUsage();
            setData(response.data.report);
            setLoading(false);
        } catch (err) {
            setError('Failed to load allocation usage data');
            setLoading(false);
        }
    };

    const toggleManager = (managerId) => {
        setExpandedManagers(prev => ({
            ...prev,
            [managerId]: !prev[managerId]
        }));
    };

    const handleViewManager = (manager) => {
        setViewManager(manager);
    };

    const closeManagerModal = () => {
        setViewManager(null);
    };

    const handleDownloadManagerReport = (manager) => {
        generateManagerReportPDF(manager);
    };

    if (loading) return <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>Loading allocation data...</div>;
    if (error) return <div className="text-red-500">{error}</div>;

    // Calculate Grand Totals
    const grandTotalReceived = data.reduce((sum, item) => sum + item.total_received, 0);
    const grandTotalManagerUsage = data.reduce((sum, item) => sum + item.manager_own_usage, 0);
    const grandTotalTeamAllocated = data.reduce((sum, item) => sum + item.total_allocated_to_team, 0);
    const grandTotalTeamUsage = data.reduce((sum, item) => {
        const teamUsage = item.team_usage_breakdown.reduce((s, u) => s + u.used_fund, 0);
        return sum + teamUsage;
    }, 0);
    const grandTotalBalance = data.reduce((sum, item) => {
        const teamUsage = item.team_usage_breakdown.reduce((s, u) => s + u.used_fund, 0);
        const effectiveDeduction = Math.max(item.total_allocated_to_team, teamUsage);
        return sum + (item.total_received - item.manager_own_usage - effectiveDeduction);
    }, 0);


    const formatCurrency = (amount) => formatCurrencyValue(amount);

    return (
        <div className="allocation-usage-container">
            {/* Stats Grid */}
            <div className="dashboard-grid" style={{ marginBottom: '30px' }}>
                <div className="card stat-card info">
                    <div className="stat-icon-wrapper"><FaMoneyBillWave /></div>
                    <div>
                        <span className="stat-label">Total Outflow (CEO)</span>
                        <span className="stat-value">{formatCurrency(grandTotalReceived)}</span>
                    </div>
                </div>
                <div className="card stat-card warning">
                    <div className="stat-icon-wrapper"><FaUserTie /></div>
                    <div>
                        <span className="stat-label">Manager Own Usage</span>
                        <span className="stat-value">{formatCurrency(grandTotalManagerUsage)}</span>
                    </div>
                </div>
                <div className="card stat-card primary">
                    <div className="stat-icon-wrapper"><FaUsers /></div>
                    <div>
                        <span className="stat-label">Allocated to Teams</span>
                        <span className="stat-value">{formatCurrency(grandTotalTeamAllocated)}</span>
                    </div>
                </div>
                <div className="card stat-card danger">
                    <div className="stat-icon-wrapper"><FaChartPie /></div>
                    <div>
                        <span className="stat-label">Total Team Usage</span>
                        <span className="stat-value">{formatCurrency(grandTotalTeamUsage)}</span>
                    </div>
                </div>
                <div className="card stat-card success">
                    <div className="stat-icon-wrapper"><FaWallet /></div>
                    <div>
                        <span className="stat-label">Unused Balance (Managers)</span>
                        <span className="stat-value">{formatCurrency(grandTotalBalance)}</span>
                    </div>
                </div>
            </div>


            <TableControls
                searchTerm={searchTerm}
                setSearchTerm={setSearchTerm}
                onDownload={() => exportAllocationData(filteredData, 'Allocation Usage Report')}
                placeholder="Search Manager, Amount..."
            />

            <div className="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Manager / User</th>
                            <th>Role</th>
                            <th>Allocated Fund</th>
                            <th>Used Fund</th>
                            <th>Balance</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {currentItems.map(manager => (
                            <React.Fragment key={manager.manager_id}>
                                {/* Manager Row */}
                                <tr className="manager-row" style={{ backgroundColor: 'var(--secondary-50)' }}>
                                    <td style={{ fontWeight: '600', color: 'var(--secondary-900)' }}>
                                        {manager.manager_name}
                                    </td>
                                    <td>
                                        <StatusBadge status='MANAGER' />
                                    </td>
                                    <td style={{ fontWeight: '600' }}>{formatCurrency(manager.total_received)}</td>
                                    <td>{formatCurrency(manager.manager_own_usage)}</td>
                                    <td style={{ color: 'var(--success-600)', fontWeight: '600' }}>
                                        {formatCurrency(manager.manager_balance)}
                                    </td>
                                    <td>
                                        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                                            <button
                                                className="btn btn-primary"
                                                onClick={() => toggleManager(manager.manager_id)}
                                                style={{ padding: '8px 16px', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '6px' }}
                                                title={expandedManagers[manager.manager_id] ? 'Collapse Team' : 'Expand Team'}
                                            >
                                                {expandedManagers[manager.manager_id] ? 'Hide' : 'Show'}
                                            </button>
                                            <button
                                                className="btn btn-secondary"
                                                onClick={() => handleViewManager(manager)}
                                                style={{
                                                    width: '35px',
                                                    height: '35px',
                                                    borderRadius: '50%',
                                                    padding: 0,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    boxShadow: '0 2px 5px rgba(0,0,0,0.1)'
                                                }}
                                                title="View Full Details"
                                            >
                                                <FaEye />
                                            </button>
                                            <button
                                                className="btn btn-primary"
                                                onClick={() => handleDownloadManagerReport(manager)}
                                                style={{
                                                    width: '35px',
                                                    height: '35px',
                                                    borderRadius: '50%',
                                                    padding: 0,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    boxShadow: '0 4px 6px rgba(79, 70, 229, 0.3)'
                                                }}
                                                title="Download Report"
                                            >
                                                <FaDownload />
                                            </button>
                                        </div>
                                    </td>
                                </tr>

                                {/* User Rows (Nested) */}
                                {expandedManagers[manager.manager_id] && manager.team_usage_breakdown.map(user => (
                                    <tr key={user.id} className="user-row">
                                        <td style={{ paddingLeft: '40px', color: 'var(--secondary-600)' }}>
                                            ↳ {user.name}
                                        </td>
                                        <td>
                                            <StatusBadge status='USER' />
                                        </td>
                                        <td>{formatCurrency(user.allocated_fund)}</td>
                                        <td>{formatCurrency(user.used_fund)}</td>
                                        <td>{formatCurrency(user.balance)}</td>
                                        <td>-</td>
                                    </tr>
                                ))}
                                {expandedManagers[manager.manager_id] && manager.team_usage_breakdown.length === 0 && (
                                    <tr>
                                        <td colSpan="6" style={{ paddingLeft: '40px', color: 'var(--secondary-400)', fontStyle: 'italic' }}>
                                            No team members assigned
                                        </td>
                                    </tr>
                                )}
                            </React.Fragment>
                        ))}
                        {currentItems.length === 0 && (
                            <tr>
                                <td colSpan="6" style={{ textAlign: 'center', color: 'var(--secondary-500)' }}>
                                    No allocations found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
            <TablePagination
                currentPage={currentPage}
                setCurrentPage={setCurrentPage}
                totalPages={totalPages}
                itemsPerPage={itemsPerPage}
                setItemsPerPage={setItemsPerPage}
            />

            {/* View Manager Modal */}
            {viewManager && createPortal(
                <div className="modal-overlay" onClick={closeManagerModal} style={{
                    position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
                    background: 'var(--glass-bg)', backdropFilter: 'blur(4px)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 9999
                }}>
                    <div className="modal-content" onClick={e => e.stopPropagation()} style={{
                        background: 'var(--bg-card)',
                        width: '95%', // Responsive width
                        maxWidth: '750px',
                        borderRadius: '8px',
                        boxShadow: 'var(--shadow-xl)',
                        overflow: 'hidden',
                        display: 'flex',
                        flexDirection: 'column',
                        maxHeight: '90vh',
                        border: '1px solid var(--border-light)',
                        animation: 'fade-in-up 0.3s ease-out'
                    }}>
                        {/* Header */}
                        <div style={{
                            background: 'var(--bg-card)', padding: '1rem 1.5rem', borderBottom: '1px solid var(--border-light)',
                            display: 'flex', justifyContent: 'space-between', alignItems: 'center'
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                <div style={{
                                    width: '36px', height: '36px', borderRadius: '6px',
                                    background: '#065f46', color: 'white', display: 'flex',
                                    alignItems: 'center', justifyContent: 'center', fontSize: '1rem',
                                    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                                }}>
                                    <FaWallet />
                                </div>
                                <div>
                                    <h2 style={{ margin: 0, fontSize: '1.1rem', fontWeight: '700', color: 'var(--text-main)', letterSpacing: '-0.01em', textTransform: 'uppercase' }}>
                                        Allocation Details
                                    </h2>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', fontWeight: '500' }}>
                                        Manager Fund Overview
                                    </div>
                                </div>
                            </div>
                            <button onClick={closeManagerModal} style={{ background: 'none', border: 'none', color: '#94a3b8', cursor: 'pointer', fontSize: '1.1rem' }}>
                                <FaTimesCircle />
                            </button>
                        </div>

                        {/* Body */}
                        <div style={{ padding: '1.5rem', overflowY: 'auto', flex: 1, background: 'var(--secondary-50)' }}>

                            {/* Primary Info Card */}
                            <div style={{
                                background: 'var(--bg-card)', border: '1px solid var(--border-light)', borderRadius: '6px',
                                padding: '1.25rem', marginBottom: '1rem', display: 'grid',
                                gridTemplateColumns: 'repeat(4, 1fr)', gap: '1.5rem'
                            }}>
                                <div style={{ gridColumn: 'span 2' }}>
                                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>Manager</div>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.9rem', color: 'var(--text-main)', fontWeight: '500' }}>
                                        <div style={{ width: '24px', height: '24px', borderRadius: '50%', background: 'var(--secondary-100)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)', fontSize: '0.7rem' }}>
                                            <FaUserTie />
                                        </div>
                                        {viewManager.manager_name}
                                    </div>
                                </div>
                                <div>
                                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>Allocated Fund</div>
                                    <div style={{ fontSize: 'clamp(13px, 0.7058vw + 9px, 1rem)', color: 'var(--text-main)', fontWeight: '500' }}>{formatCurrency(viewManager.total_received)}</div>
                                </div>
                                <div style={{ textAlign: 'right' }}>
                                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>Current Balance</div>
                                    <div style={{ fontSize: 'clamp(13px, 0.7058vw + 9px, 1rem)', fontWeight: '700', color: 'var(--success-600)' }}>{formatCurrency(viewManager.manager_balance)}</div>
                                </div>
                            </div>

                            {/* Secondary Info */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '1.5rem' }}>
                                <div style={{ background: 'var(--bg-card)', padding: '1rem', border: '1px solid var(--border-light)', borderRadius: '6px' }}>
                                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600' }}>Own Usage</div>
                                    <div style={{ fontSize: '1.1rem', fontWeight: '600', color: 'var(--text-main)', marginTop: '0.25rem' }}>{formatCurrency(viewManager.manager_own_usage)}</div>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>Funds used directly</div>
                                </div>
                                <div style={{ background: 'var(--bg-card)', padding: '1rem', border: '1px solid var(--border-light)', borderRadius: '6px' }}>
                                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600' }}>Team Allocation</div>
                                    <div style={{ fontSize: '1.1rem', fontWeight: '600', color: 'var(--text-main)', marginTop: '0.25rem' }}>{formatCurrency(viewManager.total_allocated_to_team)}</div>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>Distributed to members</div>
                                </div>
                            </div>

                            {/* Team Breakdown Table */}
                            <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border-light)', borderRadius: '6px', overflow: 'hidden' }}>
                                <div style={{ padding: '0.75rem 1rem', borderBottom: '1px solid var(--border-light)', background: 'var(--secondary-50)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                    <FaUsers size={12} color="var(--text-muted)" />
                                    <span style={{ fontSize: '0.75rem', fontWeight: '700', color: 'var(--text-main)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Team Breakdown</span>
                                </div>
                                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                                    <thead>
                                        <tr style={{ background: 'var(--bg-card)', borderBottom: '1px solid var(--border-light)' }}>
                                            <th style={{ padding: '0.75rem 1rem', textAlign: 'left', fontSize: '0.7rem', fontWeight: '600', color: 'var(--text-muted)', textTransform: 'uppercase' }}>User</th>
                                            <th style={{ padding: '0.75rem 1rem', textAlign: 'right', fontSize: '0.7rem', fontWeight: '600', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Allocated</th>
                                            <th style={{ padding: '0.75rem 1rem', textAlign: 'right', fontSize: '0.7rem', fontWeight: '600', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Used</th>
                                            <th style={{ padding: '0.75rem 1rem', textAlign: 'right', fontSize: '0.7rem', fontWeight: '600', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Balance</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {viewManager.team_usage_breakdown.map((user, index) => (
                                            <tr key={user.id} style={{ borderBottom: '1px solid var(--border-light)' }}>
                                                <td style={{ padding: '0.5rem 1rem', fontSize: '0.85rem', color: 'var(--text-main)', fontWeight: '500' }}>{user.name}</td>
                                                <td style={{ padding: '0.5rem 1rem', textAlign: 'right', fontSize: '0.85rem', color: 'var(--text-muted)' }}>{formatCurrency(user.allocated_fund)}</td>
                                                <td style={{ padding: '0.5rem 1rem', textAlign: 'right', fontSize: '0.85rem', color: 'var(--text-muted)' }}>{formatCurrency(user.used_fund)}</td>
                                                <td style={{ padding: '0.5rem 1rem', textAlign: 'right', fontSize: '0.85rem', color: 'var(--success-600)', fontWeight: '600' }}>{formatCurrency(user.balance)}</td>
                                            </tr>
                                        ))}
                                        {viewManager.team_usage_breakdown.length === 0 && (
                                            <tr><td colSpan="4" style={{ padding: '1.5rem', textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)', fontStyle: 'italic' }}>No team members assigned</td></tr>
                                        )}
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        {/* Footer */}
                        <div style={{ padding: '1rem 1.5rem', background: 'var(--bg-card)', borderTop: '1px solid var(--border-light)', display: 'flex', justifyContent: 'flex-end', gap: '1rem' }}>
                            <button
                                onClick={closeManagerModal}
                                style={{
                                    background: 'var(--bg-card)',
                                    border: '1px solid var(--border-light)',
                                    color: 'var(--text-muted)',
                                    padding: '0.5rem 1.5rem',
                                    borderRadius: '6px',
                                    fontWeight: '600',
                                    fontSize: '0.85rem',
                                    cursor: 'pointer',
                                    boxShadow: 'var(--shadow-sm)'
                                }}>
                                Close
                            </button>
                            <button
                                onClick={() => handleDownloadManagerReport(viewManager)}
                                style={{
                                    background: '#065f46',
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
                                }}>
                                <FaDownload size={12} /> Download Report
                            </button>
                        </div>
                    </div>
                </div>,
                document.body
            )}
        </div>
    );
};

export default AllocationUsage;

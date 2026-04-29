import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import StatusBadge from './StatusBadge';

import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';
import {
    getExpenseReports,
    getFundReports,
    getExpansionReports
} from '../services/api';
import { generateProfessionalPDF } from '../utils/pdfGenerator';
import { EXPENSE_CATEGORIES } from '../utils/constants';
import { FaFilePdf, FaFileExcel, FaDownload } from 'react-icons/fa';
import { useTableFilters } from '../hooks/useTableFilters';
import TableControls from '../components/TableControls';
import TablePagination from '../components/TablePagination';
import { useSettings } from '../context/SettingsContext';

const ReportsSection = ({ role }) => {
    const [searchParams, setSearchParams] = useSearchParams();
    const reportType = searchParams.get('reportType') || 'expenses';

    const setReportType = (type) => {
        const newParams = new URLSearchParams(searchParams);
        newParams.set('reportType', type);
        setSearchParams(newParams);
    };

    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [filters, setFilters] = useState({
        start_date: searchParams.get('start_date') || '',
        end_date: searchParams.get('end_date') || '',
        category: searchParams.get('category') || '',
        department: searchParams.get('department') || '',
        status: searchParams.get('status') || '',
        scope: searchParams.get('scope') || 'team' // 'team' (all accessible) or 'me' (own created)
    });

    const getSearchKeys = () => {
        switch (reportType) {
            case 'expenses': return ['title', 'category', 'status', 'amount'];
            case 'category': return ['category', 'total', 'count'];
            case 'funds': return ['from_user_name', 'to_user_name', 'amount', 'status'];
            case 'expansion': return ['manager_name', 'requested_amount', 'status'];
            default: return [];
        }
    };

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
    } = useTableFilters(data, getSearchKeys());

    useEffect(() => {
        // Initial load should show loader if data is empty, 
        // subsequent changes (filters/types) should be silent
        fetchReportData(data.length > 0);
    }, [reportType, filters]);

    const fetchReportData = async (silent = false) => {
        if (!silent) setLoading(true);
        try {
            let response;
            // Add filtering params including scope
            const params = { ...filters };

            // Requirement: Only show data if specific filters (category or date) are chosen
            // This applies primarily to 'expenses' and 'category' reports as per user request
            const hasActiveFilters = filters.category || filters.start_date || filters.end_date || filters.department;

            if ((reportType === 'expenses' || reportType === 'category') && !hasActiveFilters) {
                setData([]);
                setLoading(false);
                return;
            }

            if (reportType === 'expenses') {
                response = await getExpenseReports(params);
                setData(response.data.data || []);
            } else if (reportType === 'category') {
                response = await getExpenseReports({ ...params, type: 'category' });
                setData(response.data.data || []);
            } else if (reportType === 'funds') {
                response = await getFundReports(params);
                setData(response.data.funds || []);
            } else if (reportType === 'expansion') {
                response = await getExpansionReports(params);
                setData(response.data.funds || []);
            }
        } catch (error) {
            console.error('Error fetching report data:', error);
            setData([]);
        }
        setLoading(false);
    };

    const handleFilterChange = (e) => {
        const { name, value } = e.target;
        setFilters({ ...filters, [name]: value });

        const newParams = new URLSearchParams(searchParams);
        if (value) {
            newParams.set(name, value);
        } else {
            newParams.delete(name);
        }
        setSearchParams(newParams);
    };

    const { formatCurrencyValue } = useSettings();

    const formatCurrency = (amount) => formatCurrencyValue(amount);

    // Calculate total amounts (Gross, Rejected, Net)
    const calculateTotals = () => {
        const sourceData = filteredData.length > 0 ? filteredData : data;
        let gross = 0;
        let rejected = 0;

        if (sourceData.length === 0) return { gross: 0, rejected: 0, net: 0 };

        sourceData.forEach(item => {
            let val = 0;
            if (reportType === 'expenses') {
                val = parseFloat(item.amount) || 0;
                gross += val;
                if (item.status === 'REJECTED') {
                    rejected += val;
                }
            } else if (reportType === 'category') {
                val = parseFloat(item.total) || 0;
                gross += val;
                // Category summary might not have status, assuming pre-filtered or just gross
            } else if (reportType === 'funds') {
                val = parseFloat(item.amount) || 0;
                gross += val;
                if (item.status === 'REJECTED') rejected += val;
            } else if (reportType === 'expansion') {
                val = parseFloat(item.requested_amount) || 0;
                gross += val;
                if (item.status === 'REJECTED') rejected += val;
            }
        });

        return {
            gross,
            rejected,
            net: gross - rejected
        };
    };

    const exportPDF = () => {
        const exportData = filteredData.length > 0 ? filteredData : data;
        const { gross, rejected, net } = calculateTotals();

        let columns = [];
        if (reportType === 'expenses') {
            columns = [
                { header: 'ID', key: 'id' },
                { header: 'Date', key: 'expense_date', format: (v) => new Date(v).toLocaleDateString() },
                { header: 'Employee', key: 'full_name' },
                { header: 'Title', key: 'title' },
                { header: 'Category', key: 'category' },
                { header: 'Department', key: 'department', format: (v) => v || '-' },
                { header: 'Description', key: 'description', format: (v) => v || '-' },
                { header: 'Approved By', key: 'approved_by_name', format: (v) => v || '-' },
                { header: 'Status', key: 'status' },
                { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v) }
            ];
        } else if (reportType === 'category') {
            columns = [
                { header: 'Category', key: 'category' },
                { header: 'Count', key: 'count' },
                { header: 'Total Amount', key: 'total', format: (v) => formatCurrency(v) }
            ];
        } else if (reportType === 'funds') {
            columns = [
                { header: 'ID', key: 'id' },
                { header: 'Date', key: 'created_at', format: (v) => new Date(v).toLocaleDateString() },
                { header: 'From', key: 'from_user_name' },
                { header: 'To', key: 'to_user_name' },
                { header: 'Mode', key: 'payment_mode' },
                { header: 'Ref #', key: 'transaction_id', format: (v, item) => v || item.cheque_number || '-' },
                { header: 'Description', key: 'description', format: (v) => v || '-' },
                { header: 'Status', key: 'status' },
                { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v) }
            ];
        } else if (reportType === 'expansion') {
            columns = [
                { header: 'ID', key: 'id' },
                { header: 'Date', key: 'requested_at', format: (v) => new Date(v).toLocaleDateString() },
                { header: 'Manager', key: 'manager_name' },
                { header: 'Reviewer', key: 'reviewer_name', format: (v) => v || '-' },
                { header: 'Justification', key: 'justification', format: (v) => v || '-' },
                { header: 'Approved', key: 'approved_amount', format: (v) => v ? formatCurrency(v) : '-' },
                { header: 'Status', key: 'status' },
                { header: 'Requested', key: 'requested_amount', format: (v) => formatCurrency(v) }
            ];
        }

        // Prepare Summary Footer
        const footerRows = [];
        if (reportType === 'expenses') {
            const labelColSpan = columns.length - 1;
            footerRows.push([
                { content: 'Gross Total', colSpan: labelColSpan, styles: { halign: 'right' } },
                { content: formatCurrency(gross) }
            ]);
            footerRows.push([
                { content: 'Rejected Amount', colSpan: labelColSpan, styles: { halign: 'right', textColor: [220, 38, 38] } },
                { content: `- ${formatCurrency(rejected)}`, styles: { textColor: [220, 38, 38] } }
            ]);
            footerRows.push([
                { content: 'Net Total', colSpan: labelColSpan, styles: { halign: 'right', fillColor: [226, 232, 240] } },
                { content: formatCurrency(net), styles: { fillColor: [226, 232, 240] } }
            ]);
        } else {
            const labelColSpan = columns.length - 1;
            footerRows.push([
                { content: 'TOTAL', colSpan: labelColSpan, styles: { halign: 'right' } },
                { content: formatCurrency(gross) }
            ]);
        }

        generateProfessionalPDF(`${reportType} Report`, columns, exportData, { footerRows });
    };

    const exportExcel = () => {
        const exportData = filteredData.length > 0 ? filteredData : data;
        const { gross, rejected, net } = calculateTotals();

        let mappedData = [];
        if (reportType === 'expenses') {
            mappedData = exportData.map(item => ({
                'ID': item.id,
                'Date': new Date(item.expense_date).toLocaleDateString(),
                'Employee': item.full_name,
                'Email': item.email,
                'Title': item.title,
                'Category': item.category,
                'Department': item.department || '-',
                'Description': item.description || '-',
                'Status': item.status,
                'Approved By': item.approved_by_name || '-',
                'Amount': parseFloat(item.amount)
            }));
            // Add Totals
            mappedData.push({});
            mappedData.push({ 'Title': 'GROSS TOTAL', 'Amount': gross });
            mappedData.push({ 'Title': 'REJECTED AMOUNT', 'Amount': -rejected });
            mappedData.push({ 'Title': 'NET TOTAL', 'Amount': net });
        } else if (reportType === 'category') {
            mappedData = exportData.map(item => ({
                'Category': item.category,
                'Count': item.count,
                'Total Amount': parseFloat(item.total)
            }));
            mappedData.push({});
            mappedData.push({ 'Category': 'TOTAL', 'Total Amount': gross });
        } else if (reportType === 'funds') {
            mappedData = exportData.map(item => ({
                'ID': item.id,
                'Date': new Date(item.created_at).toLocaleDateString(),
                'From': item.from_user_name,
                'To': item.to_user_name,
                'Payment Mode': item.payment_mode || 'CASH',
                'Reference #': item.transaction_id || item.cheque_number || '-',
                'Description': item.description || '-',
                'Status': item.status,
                'Amount': parseFloat(item.amount)
            }));
            mappedData.push({});
            mappedData.push({ 'To': 'TOTAL', 'Amount': gross });
        } else if (reportType === 'expansion') {
            mappedData = exportData.map(item => ({
                'ID': item.id,
                'Date': new Date(item.requested_at).toLocaleDateString(),
                'Manager': item.manager_name,
                'Reviewer': item.reviewer_name || '-',
                'Justification': item.justification || '-',
                'Requested Amount': parseFloat(item.requested_amount),
                'Approved Amount': item.approved_amount ? parseFloat(item.approved_amount) : 0,
                'Status': item.status
            }));
            mappedData.push({});
            mappedData.push({ 'Manager': 'TOTAL REQUESTED', 'Requested Amount': gross });
        }

        const worksheet = XLSX.utils.json_to_sheet(mappedData);
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, "Report");
        const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
        const dataBlob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=UTF-8' });
        saveAs(dataBlob, `${reportType}_report_${new Date().toISOString()}.xlsx`);
    };

    // Modal State
    const [showModal, setShowModal] = useState(false);
    const [selectedCategory, setSelectedCategory] = useState('');
    const [detailedExpenses, setDetailedExpenses] = useState([]);
    const [modalLoading, setModalLoading] = useState(false);

    const handleViewCategory = async (category) => {
        setSelectedCategory(category);
        setShowModal(true);
        setModalLoading(true);
        try {
            // Re-use expense report logic but filtered for this category
            const params = { ...filters, type: 'expenses', category: category };
            // If MANAGER and scoped to 'me', ensure we pass that
            if (role === 'MANAGER' && filters.scope) {
                params.scope = filters.scope;
            }
            const response = await getExpenseReports(params);
            setDetailedExpenses(response.data.data || []);
        } catch (error) {
            console.error('Error fetching detailed category expenses:', error);
            setDetailedExpenses([]);
        }
        setModalLoading(false);
    };

    const closeCategoryModal = () => {
        setShowModal(false);
        setSelectedCategory('');
        setDetailedExpenses([]);
    };

    // Simple Inline Modal Component
    const Modal = () => {
        if (!showModal) return null;
        return (
            <div style={{
                position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
                backgroundColor: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000
            }}>
                <div style={{
                    backgroundColor: 'white', padding: '20px', borderRadius: '8px', maxWidth: '800px', width: '90%', maxHeight: '80vh', overflowY: 'auto'
                }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
                        <h3>Expenses for {selectedCategory}</h3>
                        <button onClick={closeCategoryModal} className="btn btn-danger" style={{ padding: '5px 10px' }}>Close</button>
                    </div>
                    {modalLoading ? <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--primary-600)' }}>Loading expenses...</div> : (
                        <div className="table-responsive">
                            <table className="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Date</th>
                                        <th>Title</th>
                                        <th>Amount</th>
                                        <th>User</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {detailedExpenses.map((expense, idx) => (
                                        <tr key={idx}>
                                            <td>{expense.id}</td>
                                            <td>{new Date(expense.expense_date).toLocaleDateString()}</td>
                                            <td>{expense.title}</td>
                                            <td><div style={{ fontSize: 'clamp(13px, 0.7058vw + 9px, 1rem)' }}>{formatCurrency(expense.amount)}</div></td>
                                            <td>{expense.full_name || expense.user_name || '-'}</td>
                                            <td>
                                                <StatusBadge status={expense.status} />
                                            </td>
                                        </tr>
                                    ))}
                                    {detailedExpenses.length === 0 && <tr><td colSpan="6">No expenses found.</td></tr>}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            </div>
        );
    };

    // Calculate total records based on report type
    const getTotalRecords = () => {
        if (reportType === 'category') {
            return data.reduce((sum, item) => sum + (parseInt(item.count) || 0), 0);
        }
        return data.length;
    };

    // Get totals for rendering
    const totals = calculateTotals();

    return (
        <div>


            <TableControls
                searchTerm={searchTerm}
                setSearchTerm={setSearchTerm}
                startDate={filters.start_date}
                setStartDate={(date) => handleFilterChange({ target: { name: 'start_date', value: date } })}
                endDate={filters.end_date}
                setEndDate={(date) => handleFilterChange({ target: { name: 'end_date', value: date } })}
                onDownload={exportPDF}
                showDownload={false}
                placeholder="Search..."
            >
                <div className="filter-group">
                    <label>REPORT TYPE</label>
                    <select
                        value={reportType}
                        onChange={(e) => setReportType(e.target.value)}
                        className="filter-input"
                    >
                        <option value="expenses">Expenses</option>
                        <option value="category">Category Summary</option>
                        <option value="funds">Operational Fund</option>
                        {(role === 'MANAGER' || role === 'CEO') && <option value="expansion">Expansion Fund</option>}
                    </select>
                </div>

                {role === 'MANAGER' && (
                    <div className="filter-group">
                        <label>SCOPE</label>
                        <select
                            name="scope"
                            value={filters.scope}
                            onChange={handleFilterChange}
                            className="filter-input"
                        >
                            <option value="team">My Team & Me</option>
                            <option value="me">My Records Only</option>
                        </select>
                    </div>
                )}

                {(reportType === 'expenses' || reportType === 'category') && (
                    <div className="filter-group">
                        <label>CATEGORY</label>
                        <select
                            name="category"
                            value={filters.category}
                            onChange={handleFilterChange}
                            className="filter-input"
                        >
                            <option value="">All Categories</option>
                            {EXPENSE_CATEGORIES.map(cat => (
                                <option key={cat} value={cat}>{cat}</option>
                            ))}
                        </select>
                    </div>
                )}

                {(reportType === 'expenses' || reportType === 'category') && (
                    <div className="filter-group">
                        <label>DEPARTMENT</label>
                        <select
                            name="department"
                            value={filters.department}
                            onChange={handleFilterChange}
                            className="filter-input"
                        >
                            <option value="">All Departments</option>
                            {['IT', 'HR', 'Marketing', 'Sales', 'Operations', 'Finance', 'Logistics'].map(dept => (
                                <option key={dept} value={dept}>{dept}</option>
                            ))}
                        </select>
                    </div>
                )}

            </TableControls>

            <div style={{ display: 'flex', gap: '10px', justifyContent: 'flex-end', marginBottom: '1rem' }}>
                <button
                    onClick={exportExcel}
                    className="btn btn-success"
                    title="Download Excel"
                    disabled={data.length === 0}
                    style={{ padding: '0.6rem 1.2rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}
                >
                    <FaFileExcel /> Export Excel
                </button>
                <button
                    onClick={exportPDF}
                    className="btn btn-primary"
                    title="Download PDF"
                    disabled={data.length === 0}
                    style={{ padding: '0.6rem 1.2rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}
                >
                    <FaFilePdf /> Export PDF
                </button>
            </div>

            <div className="report-preview">
                {loading ? (
                    <div style={{ textAlign: 'center', padding: '5rem', color: 'var(--text-muted)' }}>
                        <div className="btn-spinner" style={{ marginBottom: '1rem', width: '2rem', height: '2rem' }}></div>
                        <p>Fetching report data...</p>
                    </div>
                ) : data.length > 0 ? (
                    <>
                        {(filters.start_date || filters.end_date || filters.category) && (
                            <div className="report-stats-grid">
                                <div className="stat-card-premium">
                                    <span className="stat-label">GROSS TOTAL</span>
                                    <span className="stat-value">{formatCurrency(totals.gross)}</span>
                                    <div className="stat-indicator blue"></div>
                                </div>
                                <div className="stat-card-premium">
                                    <span className="stat-label">REJECTED</span>
                                    <span className="stat-value text-danger">-{formatCurrency(totals.rejected)}</span>
                                    <div className="stat-indicator red"></div>
                                </div>
                                <div className="stat-card-premium">
                                    <span className="stat-label">NET TOTAL</span>
                                    <span className="stat-value text-success">{formatCurrency(totals.net)}</span>
                                    <div className="stat-indicator green"></div>
                                </div>
                            </div>
                        )}
                        <p style={{ marginTop: '1rem', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
                            Total Records: {getTotalRecords()}
                        </p>
                        <div className="table-responsive">
                            <table>
                                <thead>
                                    <tr>
                                        {reportType === 'expenses' && (
                                            <>
                                                <th>ID</th>
                                                <th>Date</th>
                                                <th>Title</th>
                                                <th>Category</th>
                                                <th>Department</th>
                                                <th>Description</th>
                                                <th>Status</th>
                                                <th>Amount</th>
                                            </>
                                        )}
                                        {reportType === 'category' && (
                                            <>
                                                <th>Category</th>
                                                <th>Count</th>
                                                <th>Total Amount</th>
                                                <th>Actions</th>
                                            </>
                                        )}
                                        {reportType === 'funds' && (
                                            <>
                                                <th>ID</th>
                                                <th>Date</th>
                                                <th>From</th>
                                                <th>To</th>
                                                <th>Description</th>
                                                <th>Status</th>
                                                <th>Amount</th>
                                            </>
                                        )}
                                        {reportType === 'expansion' && (
                                            <>
                                                <th>ID</th>
                                                <th>Date</th>
                                                <th>Manager</th>
                                                <th>Description</th>
                                                <th>Approved</th>
                                                <th>Status</th>
                                                <th>Requested</th>
                                            </>
                                        )}
                                    </tr>
                                </thead>
                                <tbody>
                                    {currentItems.map((item, index) => (
                                        <tr key={index}>
                                            {reportType === 'expenses' && (
                                                <>
                                                    <td>{item.id}</td>
                                                    <td>{new Date(item.expense_date).toLocaleDateString()}</td>
                                                    <td>{item.title}</td>
                                                    <td>{item.category}</td>
                                                    <td>{item.department || '-'}</td>
                                                    <td style={{ maxWidth: '200px' }}>
                                                        <div style={{ overflowX: 'auto', whiteSpace: 'nowrap', maxWidth: '200px' }} className="custom-scrollbar">
                                                            {item.description || '-'}
                                                        </div>
                                                    </td>
                                                    <td>{item.status}</td>
                                                    <td>{formatCurrency(item.amount)}</td>
                                                </>
                                            )}
                                            {reportType === 'category' && (
                                                <>
                                                    <td>{item.category}</td>
                                                    <td>{item.count}</td>
                                                    <td>{formatCurrency(item.total)}</td>
                                                    <td>
                                                        <button
                                                            onClick={() => handleViewCategory(item.category)}
                                                            className="btn btn-info"
                                                            style={{ padding: '5px 10px', fontSize: '12px' }}
                                                        >
                                                            View
                                                        </button>
                                                    </td>
                                                </>
                                            )}
                                            {reportType === 'funds' && (
                                                <>
                                                    <td>{item.id}</td>
                                                    <td>{new Date(item.created_at).toLocaleDateString()}</td>
                                                    <td>{item.from_user_name}</td>
                                                    <td>{item.to_user_name}</td>
                                                    <td style={{ maxWidth: '200px' }}>
                                                        <div style={{ overflowX: 'auto', whiteSpace: 'nowrap', maxWidth: '200px' }} className="custom-scrollbar">
                                                            {item.description || '-'}
                                                        </div>
                                                    </td>
                                                    <td>{item.status}</td>
                                                    <td>{formatCurrency(item.amount)}</td>
                                                </>
                                            )}
                                            {reportType === 'expansion' && (
                                                <>
                                                    <td>{item.id}</td>
                                                    <td>{new Date(item.requested_at).toLocaleDateString()}</td>
                                                    <td>{item.manager_name}</td>
                                                    <td style={{ maxWidth: '200px' }}>
                                                        <div style={{ overflowX: 'auto', whiteSpace: 'nowrap', maxWidth: '200px' }} className="custom-scrollbar">
                                                            {item.justification || '-'}
                                                        </div>
                                                    </td>
                                                    <td>{item.approved_amount ? formatCurrency(item.approved_amount) : '-'}</td>
                                                    <td>{item.status}</td>
                                                    <td>{formatCurrency(item.requested_amount)}</td>
                                                </>
                                            )}
                                        </tr>
                                    ))}
                                    {/* Total Rows */}
                                    {reportType === 'expenses' ? (
                                        <>
                                            <tr style={{ borderTop: '2px solid var(--border-light)', backgroundColor: 'var(--secondary-50)' }}>
                                                <td colSpan="6"></td>
                                                <td style={{ fontWeight: '700', fontSize: '0.9rem', color: 'var(--text-main)', textAlign: 'right', paddingRight: '1rem' }}>Gross Total</td>
                                                <td style={{ fontWeight: '700', fontSize: '0.9rem', color: 'var(--text-main)' }}>{formatCurrency(totals.gross)}</td>
                                            </tr>
                                            <tr style={{ backgroundColor: 'var(--secondary-50)' }}>
                                                <td colSpan="6"></td>
                                                <td style={{ color: 'var(--danger-600)', fontSize: '0.9rem', fontWeight: '500', textAlign: 'right', paddingRight: '1rem' }}>Rejected Amount</td>
                                                <td style={{ color: 'var(--danger-600)', fontSize: '0.9rem', fontWeight: '500' }}>- {formatCurrency(totals.rejected)}</td>
                                            </tr>
                                            <tr style={{ borderTop: '1px solid var(--border-light)', backgroundColor: 'var(--primary-50)' }}>
                                                <td colSpan="6"></td>
                                                <td style={{ fontWeight: '800', fontSize: '1rem', color: 'var(--primary-700)', textAlign: 'right', paddingRight: '1rem' }}>Net Total</td>
                                                <td style={{ fontWeight: '800', fontSize: '1rem', color: 'var(--primary-700)' }}>{formatCurrency(totals.net)}</td>
                                            </tr>
                                        </>
                                    ) : (
                                        <tr style={{ fontWeight: 'bold', backgroundColor: 'var(--secondary-50)', color: 'var(--text-main)' }}>
                                            {reportType === 'category' && (
                                                <>
                                                    <td>Total</td>
                                                    <td></td>
                                                    <td>{formatCurrency(totals.gross)}</td>
                                                    <td></td>
                                                </>
                                            )}
                                            {reportType === 'funds' && (
                                                <>
                                                    <td colSpan="5"></td>
                                                    <td style={{ fontWeight: 'bold' }}>Total</td>
                                                    <td style={{ fontWeight: 'bold' }}>{formatCurrency(totals.gross)}</td>
                                                </>
                                            )}
                                            {reportType === 'expansion' && (
                                                <>
                                                    <td colSpan="5"></td>
                                                    <td style={{ fontWeight: 'bold' }}>Total</td>
                                                    <td style={{ fontWeight: 'bold' }}>{formatCurrency(totals.gross)}</td>
                                                </>
                                            )}
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
                    </>
                ) : (
                    <p>No data found for the selected filters.</p>
                )}
            </div>
                <style>{`
                    .report-stats-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                        gap: 1.5rem;
                        margin-bottom: 2rem;
                    }
                    .stat-card-premium {
                        background: var(--bg-card);
                        padding: 1.5rem;
                        border-radius: var(--radius-lg);
                        box-shadow: var(--shadow-md);
                        border: 1px solid var(--border-light);
                        display: flex;
                        flex-direction: column;
                        gap: 0.5rem;
                        position: relative;
                        overflow: hidden;
                        transition: transform 0.2s ease, box-shadow 0.2s ease;
                    }
                    .stat-card-premium:hover {
                        transform: translateY(-4px);
                        box-shadow: var(--shadow-lg);
                    }
                    .stat-label {
                        font-size: 0.75rem;
                        font-weight: 700;
                        color: var(--text-muted);
                        letter-spacing: 0.05em;
                    }
                    .stat-value {
                        font-size: 1.5rem;
                        font-weight: 800;
                        color: var(--text-main);
                        font-family: var(--font-display);
                    }
                    .stat-indicator {
                        position: absolute;
                        bottom: 0;
                        left: 0;
                        height: 4px;
                        width: 100%;
                    }
                    .stat-indicator.blue { background: var(--primary-500); }
                    .stat-indicator.red { background: var(--danger-500); }
                    .stat-indicator.green { background: var(--success-500); }
                    
                    @media (max-width: 768px) {
                        .report-stats-grid {
                            grid-template-columns: 1fr;
                        }
                    }
                `}</style>
                <Modal />
            </div>
        );
    };

export default ReportsSection;

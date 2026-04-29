import React, { useMemo } from 'react';
import {
    BarChart,
    Bar,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    Legend,
    PieChart,
    Pie,
    Cell,
    ResponsiveContainer
} from 'recharts';
import { FaFileInvoiceDollar, FaCheckCircle, FaExclamationCircle, FaTimesCircle } from 'react-icons/fa';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d'];

import { useSettings } from '../context/SettingsContext';

const DashboardCharts = ({ expenses = [], stats = {} }) => {
    const { formatCurrencyValue } = useSettings();

    // Calculate Summaries
    const summaries = useMemo(() => {
        let total = 0;
        let approved = 0;
        let pending = 0;
        let rejected = 0;

        expenses.forEach(exp => {
            const amount = parseFloat(exp.amount) || 0;
            const status = exp.status ? exp.status.toUpperCase() : 'UNKNOWN';

            // Total is the sum of ALL expenses regardless of status
            total += amount;

            if (status === 'REJECTED') {
                rejected += amount;
            } else if (
                status === 'PENDING' ||
                status === 'PENDING_APPROVAL' ||
                status === 'CREATED' ||
                status === 'EXPANSION_REQUESTED' ||
                status === 'UNKNOWN'
            ) {
                pending += amount;
            } else {
                // Everything else (RECEIPT_APPROVED, FUND_ALLOCATED, EXPANSION_ALLOCATED, COMPLETED, etc.)
                approved += amount;
            }
        });

        return { total, approved, pending, rejected };
    }, [expenses]);

    // Aggregate Expenses by Category
    const categoryData = useMemo(() => {
        const agg = {};
        expenses.forEach(exp => {
            const cat = exp.category || 'Uncategorized';
            agg[cat] = (agg[cat] || 0) + parseFloat(exp.amount || 0);
        });
        return Object.keys(agg).map(key => ({
            name: key,
            value: agg[key]
        }));
    }, [expenses]);

    // Aggregate Expenses by Month
    const monthlyData = useMemo(() => {
        const agg = {};
        expenses.forEach(exp => {
            const date = new Date(exp.expense_date);
            const monthYear = date.toLocaleString('default', { month: 'short', year: 'numeric' });
            agg[monthYear] = (agg[monthYear] || 0) + parseFloat(exp.amount || 0);
        });

        return Object.keys(agg).map(key => ({
            name: key,
            amount: agg[key]
        }));
    }, [expenses]);

    // Status Distribution
    const statusData = useMemo(() => {
        const agg = {};
        expenses.forEach(exp => {
            const status = exp.status || 'UNKNOWN';
            agg[status] = (agg[status] || 0) + 1;
        });
        return Object.keys(agg).map(key => ({
            name: key.replace('_', ' '),
            value: agg[key]
        }));
    }, [expenses]);

    if (expenses.length === 0) {
        return <div style={{ padding: '20px', textAlign: 'center', color: 'var(--secondary-500)' }}>No data available for charts</div>;
    }

    const formatCurrency = (amount) => formatCurrencyValue(amount);

    return (
        <div className="dashboard-charts-container">
            <h3 className="section-title">Usage Analytics & Financial Overview</h3>

            {/* Summary Cards */}
            <div className="summary-grid">
                <div className="card stat-card info">
                    <div className="stat-icon-wrapper"><FaFileInvoiceDollar /></div>
                    <div>
                        <span className="stat-label">Total Expenses</span>
                        <span className="stat-value">{formatCurrency(summaries.total)}</span>
                    </div>
                </div>
                <div className="card stat-card success">
                    <div className="stat-icon-wrapper"><FaCheckCircle /></div>
                    <div>
                        <span className="stat-label">Approved Amount</span>
                        <span className="stat-value">{formatCurrency(summaries.approved)}</span>
                    </div>
                </div>
                <div className="card stat-card warning">
                    <div className="stat-icon-wrapper"><FaExclamationCircle /></div>
                    <div>
                        <span className="stat-label">Pending Amount</span>
                        <span className="stat-value">{formatCurrency(summaries.pending)}</span>
                    </div>
                </div>
                <div className="card stat-card danger">
                    <div className="stat-icon-wrapper"><FaTimesCircle /></div>
                    <div>
                        <span className="stat-label">Rejected Amount</span>
                        <span className="stat-value">{formatCurrency(summaries.rejected)}</span>
                    </div>
                </div>
            </div>

            <div className="charts-grid">
                {/* Expenses by Category */}
                <div className="card chart-card">
                    <h4 className="chart-title">Expenses by Category</h4>
                    <ResponsiveContainer width="100%" height="100%">
                        <PieChart margin={{ bottom: 20 }}>
                            <Pie
                                data={categoryData}
                                cx="50%"
                                cy="45%"
                                labelLine={false}
                                label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}% `}
                                outerRadius="70%"
                                fill="#8884d8"
                                dataKey="value"
                            >
                                {categoryData.map((entry, index) => (
                                    <Cell key={`cell - ${index} `} fill={COLORS[index % COLORS.length]} />
                                ))}
                            </Pie>
                            <Tooltip formatter={(value) => formatCurrency(value)} />
                            <Legend />
                        </PieChart>
                    </ResponsiveContainer>
                </div>

                {/* Status Distribution */}
                <div className="card chart-card">
                    <h4 className="chart-title">Expense Status Distribution (Count)</h4>
                    <ResponsiveContainer width="100%" height="100%">
                        <PieChart margin={{ bottom: 20 }}>
                            <Pie
                                data={statusData}
                                cx="50%"
                                cy="45%"
                                innerRadius="40%"
                                outerRadius="70%"
                                fill="#82ca9d"
                                paddingAngle={5}
                                dataKey="value"
                                label
                            >
                                {statusData.map((entry, index) => (
                                    <Cell key={`cell - ${index} `} fill={COLORS[COLORS.length - 1 - (index % COLORS.length)]} />
                                ))}
                            </Pie>
                            <Tooltip />
                            <Legend />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </div>

            {/* Monthly Trend */}
            <div className="card chart-card trend-chart">
                <h4 className="chart-title">Monthly Expense Trend</h4>
                <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={monthlyData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="name" />
                        <YAxis />
                        <Tooltip formatter={(value) => formatCurrency(value)} />
                        <Legend />
                        <Bar dataKey="amount" fill="#8884d8" name="Total Amount" />
                    </BarChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
};

export default DashboardCharts;

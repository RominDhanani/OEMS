import React, { useState, useEffect, useRef } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import Layout from '../components/Layout';
import { useAuth } from '../context/AuthContext';
import { useSocket } from '../context/SocketContext';
import { useSettings } from '../context/SettingsContext';
import {
  createExpense,
  getExpenses,
  getOperationalFunds,
  getExpansionReports,
  getManagers,
  requestOperationalFund,
  confirmFundReceipt,
  getDashboardStats,
  getExpenseById,
  deleteExpenseDocument,
  updateExpense,
  deleteExpense,
  updateFund,
  deleteFund
} from '../services/api';
import { EXPENSE_CATEGORIES } from '../utils/constants';
import ReportsSection from '../components/ReportsSection';
import { FaTachometerAlt, FaMoneyBillWave, FaFileInvoiceDollar, FaChartBar, FaWallet, FaExclamationCircle, FaCheckCircle, FaClipboardList, FaUser, FaEye, FaDownload, FaFilePdf, FaArrowLeft, FaPlus, FaListUl, FaHistory, FaFileAlt, FaCloudUploadAlt, FaPlusCircle, FaHandHoldingUsd, FaArrowDown, FaClipboardCheck, FaFileContract, FaEdit, FaTrash, FaSpinner, FaCog } from 'react-icons/fa';
import * as XLSX from 'xlsx';
import ProfileSection from '../components/ProfileSection';
import StatusBadge from '../components/StatusBadge';
import { useTableFilters } from '../hooks/useTableFilters';
import TableControls from '../components/TableControls';
import TablePagination from '../components/TablePagination';
import Toast from '../components/Toast';
import DocumentList from '../components/DocumentList';
import InvoiceModal from '../components/InvoiceModal';
import { handleViewDocument, handleDownloadPDF, handleDownloadDocument } from '../utils/documentHandlers';
import { generateProfessionalPDF } from '../utils/pdfGenerator';


const UserDashboard = () => {
  const { user } = useAuth();
  const socket = useSocket();
  const { formatCurrencyValue } = useSettings();
  const navigate = useNavigate();
  const isInitialMount = useRef(true);
  const [searchParams, setSearchParams] = useSearchParams();
  const activeTab = searchParams.get('tab') || 'dashboard';
  const setActiveTab = (tab) => {
    if (tab === 'settings') {
      navigate('/settings');
      return;
    }
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', tab);
      newParams.delete('editExpenseId');
      newParams.delete('editFundId');
      return newParams;
    }); // Changed from replace: true to push (default)

    // Reset local UI and Form states for a clean slate
    setEditingExpenseId(null);
    setEditingFundId(null);
    setExistingDocument(null);

    setExpenseForm({
      title: '',
      category: '',
      department: '',
      amount: '',
      expense_date: new Date().toISOString().split('T')[0],
      description: ''
    });
    setExpenseFiles([]);

    setSuccess('');
    setError('');
  };

  const handleBack = () => {
    // Map of current tab -> parent tab/view
    const backMap = {
      'add_expense': 'my_expenses',
      'my_expenses': 'dashboard',

      'received_funds': 'dashboard',
      'view_document': 'my_expenses',
      'reports': 'dashboard',
      'profile': 'dashboard',
      'dashboard': 'BACK'
    };

    const targetTab = backMap[activeTab] || 'dashboard';

    if (targetTab === 'BACK') {
      window.history.back();
    } else {
      setActiveTab(targetTab);
    }
  };
  const [expenses, setExpenses] = useState([]);
  const [funds, setFunds] = useState([]);

  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [expenseFormErrors, setExpenseFormErrors] = useState({});
  const [isFormShaking, setIsFormShaking] = useState(false);


  const [expenseForm, setExpenseForm] = useState({
    title: '',
    category: '',
    customCategory: '',
    department: '',
    amount: '',
    expense_date: new Date().toISOString().split('T')[0],
    description: ''
  });
  const [expenseFiles, setExpenseFiles] = useState([]);

  const [viewFund, setViewFund] = useState(null);
  const [viewExpense, setViewExpense] = useState(null);


  const formatCurrency = (amount) => formatCurrencyValue(amount);

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('en-GB').replace(/\//g, '-');
  };

  useEffect(() => {
    setError('');
    // setSuccess(''); // Don't clear success immediately on tab change to allow Toast to show

    // Initial mount should show loader, subsequent tab changes should be silent
    if (isInitialMount.current) {
      loadDashboardData(false);
      isInitialMount.current = false;
    } else {
      loadDashboardData(true);
    }
  }, [activeTab]);

  const loadDashboardData = async (silent = false) => {
    if (!silent) setLoading(true);
    try {
      const [statsRes, expensesRes] = await Promise.all([
        getDashboardStats(),
        getExpenses()
      ]);
      setStats(statsRes.data.stats);
      setExpenses(expensesRes.data.expenses);

      // Auto-refresh currently viewed expense if open
      if (viewExpense) {
        const updated = (expensesRes.data.expenses || []).find(e => Number(e.id) === Number(viewExpense.id));
        if (updated) setViewExpense(updated);
      }

      if (activeTab === 'funds' || activeTab === 'received_funds') {
        const fundsRes = await getOperationalFunds();
        setFunds(fundsRes.data.funds || []);

        // Auto-refresh currently viewed fund if open
        if (viewFund) {
          const updated = (fundsRes.data.funds || []).find(f => Number(f.id) === Number(viewFund.id));
          if (updated) setViewFund(updated);
        }
      }
    } catch (err) {
      setError('Failed to load data');
    }
    setLoading(false);
  };

  // Handle URL Parameters for Persistence (Edit Mode)
  useEffect(() => {
    const editExpenseId = searchParams.get('editExpenseId');
    const editFundId = searchParams.get('editFundId');

    if (editExpenseId && expenses.length > 0 && !editingExpenseId) {
      const expenseToEdit = expenses.find(e => e.id.toString() === editExpenseId);
      if (expenseToEdit) {
        handleEditExpense(expenseToEdit);
      }
    }
  }, [searchParams, expenses, funds]);

  const triggerFormShake = () => {
    setIsFormShaking(true);
    setTimeout(() => setIsFormShaking(false), 400);
  };

  const validateExpenseForm = () => {
    const newErrors = {};
    if (!expenseForm.title?.trim()) newErrors.title = 'Title is required';
    if (!expenseForm.category) newErrors.category = 'Category is required';
    if (expenseForm.category === 'Other' && !expenseForm.customCategory?.trim()) {
      newErrors.customCategory = 'Please specify category';
    }
    if (!expenseForm.department) newErrors.department = 'Department is required';
    if (!expenseForm.amount) newErrors.amount = 'Amount is required';
    else if (isNaN(expenseForm.amount) || Number(expenseForm.amount) <= 0) {
      newErrors.amount = 'Must be a positive number';
    }
    if (!expenseForm.expense_date) newErrors.expense_date = 'Date is required';

    if (!editingExpenseId && (!expenseFiles || expenseFiles.length === 0) && !existingDocument) {
      newErrors.vouchers = 'Please upload at least one voucher';
    }

    setExpenseFormErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleCreateExpense = async (e) => {
    e.preventDefault();
    setExpenseFormErrors({});

    if (!validateExpenseForm()) {
      triggerFormShake();
      return;
    }

    const finalCategory = expenseForm.category === 'Other' ? expenseForm.customCategory : expenseForm.category;
    const formData = new FormData();
    Object.keys(expenseForm).forEach(key => {
      if (key === 'category') {
        formData.append(key, finalCategory);
      } else if (key !== 'customCategory') {
        formData.append(key, expenseForm[key]);
      }
    });
    expenseFiles.forEach(file => {
      formData.append('vouchers', file);
    });

    try {
      setIsSubmitting(true);
      await createExpense(formData);
      setSuccess('Expense created successfully');

      setExpenseForm({
        title: '',
        category: '',
        customCategory: '',
        department: '',
        amount: '',
        expense_date: new Date().toISOString().split('T')[0],
        description: ''
      });
      setExpenseFiles([]);
      setExpenseFormErrors({});
      loadDashboardData(true);
    } catch (err) {
      setExpenseFormErrors({ form: err.response?.data?.message || 'Failed to create expense' });
      triggerFormShake();
    } finally {
      setIsSubmitting(false);
    }
  };


  const handleConfirmReceipt = async (id) => {
    try {
      setIsSubmitting(true);
      await confirmFundReceipt(id);
      loadDashboardData(true);
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message || 'Failed to confirm receipt';
      setError(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  /* Handlers updated to use centralized util */
  const handleViewVoucher = (path) => {
    handleViewDocument(path);
  };

  const handleDownloadInvoice = (path, filename) => {
    handleDownloadDocument(path, filename);
  };

  const handleDownloadExpenseStatement = (expense) => {
    handleDownloadPDF(expense, 'EXPENSE');
  };

  const handleDownloadFund = (fund) => {
    handleDownloadPDF(fund, 'FUND');
  };

  const handleExportExcel = (data, filename) => {
    if (!data || data.length === 0) {
      alert('No data to export');
      return;
    }

    const exportData = data.map(item => ({
      Title: item.title,
      Category: item.category,
      Amount: item.amount,
      Date: item.expense_date.split('T')[0],
      Status: item.status,
      'Approved By': item.approved_by_name || '-'
    }));

    const worksheet = XLSX.utils.json_to_sheet(exportData);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Expenses');
    XLSX.writeFile(workbook, `${filename}.xlsx`);
  };

  const handleExportPDF = (data, title) => {
    if (!data || data.length === 0) {
      alert('No data to export');
      return;
    }

    const columns = [
      { header: 'Title', key: 'title' },
      { header: 'Category', key: 'category' },
      { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v) },
      { header: 'Date', key: 'expense_date', format: (v) => formatDate(v) },
      { header: 'Status', key: 'status' },
      { header: 'Approved By', key: 'approved_by_name', format: (v) => v || '-' }
    ];

    generateProfessionalPDF(title, columns, data);
  };

  const handleViewFund = (fund) => {
    setViewFund(fund);
  };

  const handleViewExpense = async (expense) => {
    try {
      const res = await getExpenseById(expense.id);
      setViewExpense({ ...res.data.expense, documents: res.data.documents });
    } catch (err) {
      setError('Failed to fetch expense details');
      setViewExpense(expense); // Fallback to basic details
    }
  };


  const closeModal = () => {
    setViewFund(null);
    setViewExpense(null);
    setShowSuccessModal(false);
    setSuccessData(null);
  };


  const handleEditExpense = async (expense) => {
    // Basic pre-fill
    const isCustomCategory = !EXPENSE_CATEGORIES.includes(expense.category);
    setExpenseForm({
      title: expense.title,
      category: isCustomCategory ? 'Other' : expense.category,
      customCategory: isCustomCategory ? expense.category : '',
      department: expense.department || '',
      amount: expense.amount,
      expense_date: new Date(expense.expense_date).toISOString().split('T')[0],
      description: expense.description || ''
    });
    setEditingExpenseId(expense.id);

    // Fetch full details including all documents
    try {
      const res = await getExpenseById(expense.id);
      if (res.data.documents) {
        setExistingDocuments(res.data.documents);
      } else {
        setExistingDocuments([]);
      }
    } catch (err) {
      console.error('Failed to fetch expense documents', err);
      setExistingDocuments([]);
    }

    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'add_expense');
      newParams.set('editExpenseId', expense.id);
      return newParams;
    });
  };



  const handleRemoveFile = (index) => {
    setExpenseFiles(prev => prev.filter((_, i) => i !== index));
  };

  const handleDeleteExpense = async (id) => {
    if (window.confirm('Are you sure you want to delete this expense?')) {
      try {
        await deleteExpense(id);
        setSuccess('Expense deleted successfully');
        loadDashboardData(true);
      } catch (err) {
        console.error(err);
        setError(err.response?.data?.message || 'Failed to delete expense');
      }
    }
  };

  const [existingDocument, setExistingDocument] = useState(null); // Deprecated, keeping temporarily if needed but logic replaced by existingDocuments

  const handleDeleteDocument = async (docId) => {
    if (!window.confirm("Are you sure you want to delete this file?")) return;
    try {
      await deleteExpenseDocument(editingExpenseId, docId);
      setExistingDocuments(prev => prev.filter(d => d.id !== docId));
      setSuccess('Document deleted');
      loadDashboardData(true); // Refresh list to update document count/status if needed
    } catch (err) {
      setError('Failed to delete document');
    }
  };




  const [editingExpenseId, setEditingExpenseId] = useState(null);
  const [editingFundId, setEditingFundId] = useState(null);

  const [existingDocuments, setExistingDocuments] = useState([]); // Array of { id, original_filename, ... }

  // Reset editing state when switching tabs if not intended
  useEffect(() => {
    // 1. Handle Edit Expense Persistence
    const editExpId = searchParams.get('editExpenseId');
    if (editExpId && expenses.length > 0 && !editingExpenseId) {
      const exp = expenses.find(e => e.id.toString() === editExpId);
      if (exp) {
        handleEditExpense(exp); // Reuse handleEditExpense to fetch docs
      }
    }



    // Clear state if tab changes and params are missing (handled by setActiveTab mostly, but good for cleanup)
    if (activeTab !== 'add_expense' && !editExpId) {
      setEditingExpenseId(null);
      setExistingDocuments([]);
      setExpenseForm({ title: '', category: '', department: '', amount: '', expense_date: new Date().toISOString().split('T')[0], description: '' });
      setExpenseFiles([]);
    }

  }, [activeTab, searchParams, expenses, funds]);

  const handleUpdateExpense = async (e) => {
    e.preventDefault();
    setExpenseFormErrors({});

    if (!validateExpenseForm()) {
      triggerFormShake();
      return;
    }

    const finalCategory = expenseForm.category === 'Other' ? expenseForm.customCategory : expenseForm.category;
    const formData = new FormData();
    Object.keys(expenseForm).forEach(key => {
      if (key === 'category') {
        formData.append(key, finalCategory);
      } else if (key !== 'customCategory') {
        formData.append(key, expenseForm[key]);
      }
    });
    if (expenseFiles.length > 0) {
      expenseFiles.forEach(file => formData.append('vouchers', file));
    }

    try {
      setIsSubmitting(true);
      await updateExpense(editingExpenseId, formData);
      setSuccess('Expense updated successfully');
      setEditingExpenseId(null);
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('editExpenseId');
        return newParams;
      });
      setExistingDocuments([]);
      setExpenseForm({ title: '', category: '', customCategory: '', department: '', amount: '', expense_date: new Date().toISOString().split('T')[0], description: '' });
      setExpenseFiles([]);
      setExpenseFormErrors({});
      loadDashboardData(true);
      setSearchParams({ tab: 'my_expenses' });
    } catch (err) {
      setExpenseFormErrors({ form: err.response?.data?.message || 'Failed to update expense' });
      triggerFormShake();
    } finally {
      setIsSubmitting(false);
    }
  };


  const tabs = [
    { id: 'dashboard', label: 'Dashboard', icon: <FaTachometerAlt /> },
    {
      id: 'expenses_root',
      label: 'Expenses',
      icon: <FaFileInvoiceDollar />,
      subItems: [
        { id: 'add_expense', label: 'Add Expense', icon: <FaPlusCircle /> },
        { id: 'my_expenses', label: 'My Expenses', icon: <FaListUl /> }
      ]
    },
    { id: 'received_funds', label: 'Received Funds', icon: <FaArrowDown /> },
    { id: 'reports', label: 'Reports', icon: <FaFileAlt /> },
    { id: 'settings', label: 'Settings', icon: <FaCog /> }
  ];

  const userExpenses = expenses.filter(e => {
    const user = JSON.parse(localStorage.getItem('user'));
    return e.user_id == user?.id;
  });

  // Table Filters Hooks
  const expenseFilters = useTableFilters(
    userExpenses,
    ['title', 'category', 'amount', 'status'],
    'expense_date'
  );

  const fundFilters = useTableFilters(
    funds,
    ['from_user_name', 'amount', 'description', 'status', 'payment_mode'],
    'created_at'
  );

  const exportTableData = (data, title, columns) => {
    generateProfessionalPDF(title, columns, data);
  };


  const getPageTitle = () => {
    switch (activeTab) {
      case 'dashboard': return 'My Dashboard';
      case 'add_expense': return editingExpenseId ? 'Edit Expense' : 'Create Expense';
      case 'my_expenses': return 'My Expenses';
      case 'received_funds': return 'Received Funds';
      case 'reports': return 'Reports';
      case 'profile': return 'My Profile';
      default: return 'User Dashboard';
    }
  };

  return (
    <>
      <Layout
        title="User Dashboard"
        menuItems={tabs}
        activeItem={activeTab}
        onMenuItemClick={setActiveTab}
      >
        {error && <Toast message={error} type="error" onClose={() => setError('')} />}
        {success && <Toast message={success} type="success" onClose={() => setSuccess('')} />}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1.5rem' }}>
            <button
              onClick={handleBack}
              style={{
                background: 'none',
                border: 'none',
                color: 'var(--secondary-600)',
                cursor: 'pointer',
                padding: '0.5rem',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                borderRadius: '50%',
                transition: 'background 0.2s',
                flexShrink: 0
              }}
              title="Go Back"
              onMouseOver={(e) => e.currentTarget.style.background = 'var(--secondary-100)'}
              onMouseOut={(e) => e.currentTarget.style.background = 'none'}
            >
              <FaArrowLeft size={20} />
            </button>
            <h3 style={{ margin: 0 }}>{getPageTitle()}</h3>
          </div>



          {activeTab === 'dashboard' && (
            <div>
              {/* Title removed, moved to header */}
              <div className="dashboard-grid">
                {/* Card 1: Allocated Funds */}
                <div className="card stat-card info">
                  <div className="stat-icon-wrapper"><FaMoneyBillWave /></div>
                  <div>
                    <span className="stat-label">Allocated Funds</span>
                    <span className="stat-value">
                      {formatCurrency(stats.receivedFunds ? stats.receivedFunds.filter(f => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].includes(f.status)).reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) : 0)}
                    </span>
                  </div>
                </div>

                {/* Card 2: Total Expenses */}
                <div className="card stat-card primary">
                  <div className="stat-icon-wrapper"><FaFileInvoiceDollar /></div>
                  <div>
                    <span className="stat-label">Total Expenses</span>
                    <span className="stat-value">
                      {formatCurrency(stats.ownExpenses ? stats.ownExpenses.reduce((sum, e) => sum + (parseFloat(e.total_amount) || 0), 0) : 0)}
                    </span>
                  </div>
                </div>

                {/* Card 3: Outstanding Balance */}
                <div className="card stat-card success">
                  <div className="stat-icon-wrapper"><FaWallet /></div>
                  <div>
                    <span className="stat-label">Outstanding Balance</span>
                    <span className="stat-value">
                      {formatCurrency(
                        (stats.receivedFunds ? stats.receivedFunds.filter(f => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].includes(f.status)).reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) : 0) -
                        (stats.ownExpenses ? stats.ownExpenses.filter(e => ['RECEIPT_APPROVED', 'FUND_ALLOCATED', 'EXPANSION_ALLOCATED', 'COMPLETED'].includes(e.status)).reduce((sum, e) => sum + (parseFloat(e.total_amount) || 0), 0) : 0)
                      )}
                    </span>
                  </div>
                </div>

                {/* Card 4: Pending Approvals */}
                <div className="card stat-card warning">
                  <div className="stat-icon-wrapper"><FaExclamationCircle /></div>
                  <div>
                    <span className="stat-label">Pending Approvals</span>
                    <span className="stat-value">
                      {stats.ownExpenses ? stats.ownExpenses.filter(e => e.status === 'PENDING_APPROVAL').reduce((sum, e) => sum + e.total, 0) : 0}
                    </span>
                  </div>
                </div>
              </div>

              {/* Dashboard removed as requested - only for CEO now */}
            </div>
          )}

          {activeTab === 'add_expense' && (
            <div className="dashboard-creation-container">
              <div className="card">
                {/* Title removed */}
                <form
                  onSubmit={editingExpenseId ? handleUpdateExpense : handleCreateExpense}
                  className={`card ${isFormShaking ? 'shake' : ''}`}
                  noValidate
                >
                  {expenseFormErrors.form && (
                    <div className="alert alert-danger" style={{ marginBottom: '1.5rem', animation: 'slideDown 0.3s ease', display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.75rem', background: 'rgba(239, 68, 68, 0.1)', color: 'var(--danger-500)', borderRadius: '4px' }}>
                      <FaExclamationCircle /> {expenseFormErrors.form}
                    </div>
                  )}
                  <div className="form-grid">
                    <div className={`form-group ${expenseFormErrors.title ? 'shake' : ''}`}>
                      <label htmlFor="title">Title *</label>
                      <input
                        type="text"
                        id="title"
                        value={expenseForm.title}
                        onChange={(e) => {
                          setExpenseForm({ ...expenseForm, title: e.target.value });
                          if (expenseFormErrors.title) setExpenseFormErrors({ ...expenseFormErrors, title: '' });
                        }}
                        className={expenseFormErrors.title ? 'is-invalid' : ''}
                        placeholder="Expense title"
                        required
                      />
                      {expenseFormErrors.title && <span className="invalid-feedback">{expenseFormErrors.title}</span>}
                    </div>
                    <div className={`form-group ${expenseFormErrors.category ? 'shake' : ''}`}>
                      <label htmlFor="category">Category *</label>
                      <select
                        id="category"
                        value={expenseForm.category}
                        onChange={(e) => {
                          setExpenseForm({ ...expenseForm, category: e.target.value });
                          if (expenseFormErrors.category) setExpenseFormErrors({ ...expenseFormErrors, category: '' });
                        }}
                        className={expenseFormErrors.category ? 'is-invalid' : ''}
                        required
                      >
                        <option value="">Select Category</option>
                        {EXPENSE_CATEGORIES.map(cat => (
                          <option key={cat} value={cat}>{cat}</option>
                        ))}
                        <option value="Other">Other (Please Specify)</option>
                      </select>
                      {expenseFormErrors.category && <span className="invalid-feedback">{expenseFormErrors.category}</span>}
                    </div>
                    {expenseForm.category === 'Other' && (
                      <div className={`form-group animate-slide-in ${expenseFormErrors.customCategory ? 'shake' : ''}`}>
                        <label htmlFor="customCategory">Custom Category Name *</label>
                        <input
                          type="text"
                          id="customCategory"
                          placeholder="Enter category name"
                          value={expenseForm.customCategory}
                          onChange={(e) => {
                            setExpenseForm({ ...expenseForm, customCategory: e.target.value });
                            if (expenseFormErrors.customCategory) setExpenseFormErrors({ ...expenseFormErrors, customCategory: '' });
                          }}
                          className={expenseFormErrors.customCategory ? 'is-invalid' : ''}
                          required
                        />
                        {expenseFormErrors.customCategory && <span className="invalid-feedback">{expenseFormErrors.customCategory}</span>}
                      </div>
                    )}
                    <div className={`form-group ${expenseFormErrors.department ? 'shake' : ''}`}>
                      <label htmlFor="department">Department *</label>
                      <select
                        id="department"
                        value={expenseForm.department || ''}
                        onChange={(e) => {
                          setExpenseForm({ ...expenseForm, department: e.target.value });
                          if (expenseFormErrors.department) setExpenseFormErrors({ ...expenseFormErrors, department: '' });
                        }}
                        className={expenseFormErrors.department ? 'is-invalid' : ''}
                        required
                      >
                        <option value="">Select Department</option>
                        <option value="IT">IT</option>
                        <option value="HR">HR</option>
                        <option value="Marketing">Marketing</option>
                        <option value="Sales">Sales</option>
                        <option value="Operations">Operations</option>
                        <option value="Finance">Finance</option>
                        <option value="Logistics">Logistics</option>
                      </select>
                      {expenseFormErrors.department && <span className="invalid-feedback">{expenseFormErrors.department}</span>}
                    </div>
                    <div className={`form-group ${expenseFormErrors.amount ? 'shake' : ''}`}>
                      <label htmlFor="amount">Amount *</label>
                      <input
                        type="number"
                        id="amount"
                        step="0.01"
                        value={expenseForm.amount}
                        onChange={(e) => {
                          setExpenseForm({ ...expenseForm, amount: e.target.value });
                          if (expenseFormErrors.amount) setExpenseFormErrors({ ...expenseFormErrors, amount: '' });
                        }}
                        className={expenseFormErrors.amount ? 'is-invalid' : ''}
                        required
                      />
                      {expenseFormErrors.amount && <span className="invalid-feedback">{expenseFormErrors.amount}</span>}
                    </div>
                    <div className={`form-group ${expenseFormErrors.expense_date ? 'shake' : ''}`}>
                      <label htmlFor="expense_date">Date *</label>
                      <input
                        type="date"
                        id="expense_date"
                        value={expenseForm.expense_date}
                        onChange={(e) => {
                          setExpenseForm({ ...expenseForm, expense_date: e.target.value });
                          if (expenseFormErrors.expense_date) setExpenseFormErrors({ ...expenseFormErrors, expense_date: '' });
                        }}
                        className={expenseFormErrors.expense_date ? 'is-invalid' : ''}
                        required
                        max={new Date().toISOString().split('T')[0]}
                      />
                      {expenseFormErrors.expense_date && <span className="invalid-feedback">{expenseFormErrors.expense_date}</span>}
                    </div>
                  </div>
                  <div className="form-group">
                    <label htmlFor="description">Description</label>
                    <textarea
                      id="description"
                      value={expenseForm.description}
                      onChange={(e) => setExpenseForm({ ...expenseForm, description: e.target.value })}
                      placeholder="Add any additional details..."
                    />
                  </div>

                  <div className={`form-group ${expenseFormErrors.vouchers ? 'shake' : ''}`}>
                    <label>Voucher/Document * (PDF, JPG, PNG)</label>
                    {expenseFiles.length === 0 && existingDocuments.length === 0 && (
                      <label className={`file-upload-box ${expenseFormErrors.vouchers ? 'is-invalid' : ''}`}>
                        <FaCloudUploadAlt className="file-upload-icon" />
                        <span className="file-upload-text">Click to upload voucher</span>
                        <span className="file-upload-hint">Supported formats: PDF, JPG, PNG</span>
                        <input
                          type="file"
                          accept=".pdf,.jpg,.jpeg,.png"
                          onChange={(e) => {
                            if (e.target.files && e.target.files.length > 0) {
                              setExpenseFiles([e.target.files[0]]);
                              if (expenseFormErrors.vouchers) setExpenseFormErrors({ ...expenseFormErrors, vouchers: '' });
                            }
                          }}
                          style={{ display: 'none' }}
                        />
                      </label>
                    )}
                    {expenseFormErrors.vouchers && <span className="invalid-feedback">{expenseFormErrors.vouchers}</span>}
                    {expenseFiles.length > 0 && (
                      <div style={{ marginTop: '0.5rem', display: 'flex', flexDirection: 'column', gap: '0.25rem' }}>
                        {expenseFiles.map((file, idx) => (
                          <div key={idx} style={{ fontSize: '0.8rem', color: 'var(--primary-600)', display: 'flex', alignItems: 'center', gap: '0.5rem', justifyContent: 'space-between', background: 'var(--secondary-50)', padding: '4px 8px', borderRadius: '4px' }}>
                            <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                              <FaFileAlt /> {file.name}
                            </span>
                            <button
                              type="button"
                              onClick={() => handleRemoveFile(idx)}
                              style={{ background: 'none', border: 'none', color: '#ef4444', cursor: 'pointer', padding: '0', fontSize: '1rem', display: 'flex', alignItems: 'center' }}
                              title="Remove file"
                            >
                              <FaTrash style={{ width: '12px', height: '12px' }} />
                            </button>
                          </div>
                        ))}
                      </div>
                    )}
                    {existingDocuments.length > 0 && (
                      <div style={{ marginTop: '0.5rem', display: 'flex', flexDirection: 'column', gap: '0.25rem' }}>
                        <p style={{ fontSize: '0.8rem', fontWeight: 'bold', margin: '0.5rem 0 0.2rem' }}>Existing Vouchers:</p>
                        {existingDocuments.map((doc, idx) => (
                          <div key={doc.id || idx} style={{ fontSize: '0.8rem', color: 'var(--primary-600)', display: 'flex', alignItems: 'center', gap: '0.5rem', justifyContent: 'space-between', background: 'var(--primary-50)', padding: '4px 8px', borderRadius: '4px' }}>
                            <span
                              style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', overflow: 'hidden', cursor: 'pointer' }}
                              onClick={() => handleViewVoucher(doc.document_path)}
                              title="View Voucher"
                            >
                              <FaFileAlt />
                              <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: '200px', textDecoration: 'underline' }}>
                                {doc.original_filename || doc.document_path.split('/').pop()}
                              </span>
                            </span>
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button
                                type="button"
                                onClick={() => handleDeleteDocument(doc.id)}
                                style={{ background: 'none', border: 'none', color: '#ef4444', cursor: 'pointer', padding: '0' }}
                                title="Delete Permanently"
                              >
                                <FaTrash />
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                  <div style={{ display: 'flex', gap: '1rem', marginTop: '5px' }}>
                    <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
                      {isSubmitting ? (
                        <>
                          <span className="btn-spinner"></span>
                          {editingExpenseId ? 'Updating...' : 'Creating...'}
                        </>
                      ) : (
                        editingExpenseId ? 'Update Expense' : 'Create Expense'
                      )}
                    </button>
                    {editingExpenseId && (
                      <button
                        type="button"
                        className="btn btn-secondary"
                        onClick={() => {
                          setEditingExpenseId(null);
                          setExistingDocuments([]); // Clear array
                          setExpenseForm({
                            title: '',
                            category: '',
                            amount: '',
                            expense_date: new Date().toISOString().split('T')[0],
                            description: ''
                          });
                          setExpenseFiles([]);
                          setSearchParams({ tab: 'my_expenses' });
                        }}
                      >
                        Cancel
                      </button>
                    )}
                  </div>
                </form>
              </div>

              <div className="side-recent">
                <h4>Recent Expenses</h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                  {expenses.slice(0, 3).map(expense => (
                    <div key={expense.id} className="card" style={{ padding: '1rem', borderLeft: '4px solid var(--primary-500)' }}>
                      <div className="expense-details">
                        <div className="expense-title">{expense.title}</div>
                        <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{formatCurrency(expense.amount)} • {formatDate(expense.expense_date)}</div>
                      </div>
                      <div className="expense-status">
                        <StatusBadge
                          status={expense.status}
                          style={{ marginTop: '0.5rem', transform: 'scale(0.8)', transformOrigin: 'left' }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )
          }

          {
            activeTab === 'my_expenses' && (
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                  {/* Title removed */}
                </div>

                <TableControls
                  searchTerm={expenseFilters.searchTerm}
                  setSearchTerm={expenseFilters.setSearchTerm}
                  startDate={expenseFilters.startDate}
                  setStartDate={expenseFilters.setStartDate}
                  endDate={expenseFilters.endDate}
                  setEndDate={expenseFilters.setEndDate}
                  onDownload={() => exportTableData(
                    expenseFilters.filteredData,
                    'My Expenses',
                    [
                      { header: 'ID', key: 'id' },
                      { header: 'Date', key: 'expense_date', format: (v) => formatDate(v) },
                      { header: 'Title', key: 'title' },
                      { header: 'Category', key: 'category' },
                      { header: 'Department', key: 'department', format: (v) => v || '-' },
                      { header: 'Description', key: 'description', format: (v) => v || '-' },
                      { header: 'Status', key: 'status' },
                      { header: 'Approved By', key: 'approved_by_name', format: (v, item) => item.approved_by_name ? `${item.approved_by_name} (${item.approved_by_role})` : '-' },
                      { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') }
                    ]
                  )}
                  placeholder="Title, Category, Amount..."
                />

                <div className="table-responsive">
                  <table style={{ whiteSpace: 'nowrap' }}>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Title</th>
                        <th>Category</th>
                        <th>Department</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Approved By</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {expenseFilters.currentItems.map(expense => (
                        <tr key={expense.id}>
                          <td>{expense.id}</td>
                          <td>{formatDate(expense.expense_date)}</td>
                          <td>{expense.title}</td>
                          <td>{expense.category}</td>
                          <td>{expense.department || '-'}</td>
                          <td>{formatCurrency(expense.amount)}</td>
                          <td>
                            <StatusBadge status={expense.status} />
                          </td>
                          <td>{expense.approved_by_name ? `${expense.approved_by_name} (${expense.approved_by_role})` : '-'}</td>
                          <td>
                            <div style={{ display: 'flex', gap: '8px', alignItems: 'center', whiteSpace: 'nowrap' }}>
                              <button
                                onClick={() => handleViewExpense(expense)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
                              {(expense.status === 'PENDING_APPROVAL' || expense.status === 'CREATED' || expense.status === 'REJECTED') && (
                                <>
                                  <button
                                    onClick={() => handleEditExpense(expense)}
                                    className="btn btn-warning"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Edit"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaEdit />}
                                  </button>
                                  <button
                                    onClick={() => handleDeleteExpense(expense.id)}
                                    className="btn btn-danger"
                                    style={{ padding: '0.4rem', borderRadius: '50%', background: '#dc3545', color: 'white', border: 'none', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Delete"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaTrash />}
                                  </button>
                                </>
                              )}
                              {expense.document_path && (
                                <button
                                  onClick={() => handleViewVoucher(expense.document_path)}
                                  className="btn btn-info"
                                  style={{ padding: '0.4rem', borderRadius: '50%', background: '#0dcaf0', color: 'white', border: 'none' }}
                                  title="View Voucher"
                                >
                                  <FaFileAlt />
                                </button>
                              )}
                              <button
                                onClick={() => handleDownloadExpenseStatement(expense)}
                                className="btn btn-primary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="Download Invoice"
                              >
                                <FaDownload />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                      {expenseFilters.currentItems.length === 0 && (<tr><td colSpan="8" style={{ textAlign: 'center' }}>No expenses found</td></tr>)}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={expenseFilters.currentPage}
                  setCurrentPage={expenseFilters.setCurrentPage}
                  totalPages={expenseFilters.totalPages}
                  itemsPerPage={expenseFilters.itemsPerPage}
                  setItemsPerPage={expenseFilters.setItemsPerPage}
                />
                {userExpenses.length === 0 && <p>No expenses yet</p>}
              </div>
            )
          }


          {



            activeTab === 'received_funds' && (
              <div>
                <TableControls
                  searchTerm={fundFilters.searchTerm}
                  setSearchTerm={fundFilters.setSearchTerm}
                  startDate={fundFilters.startDate}
                  setStartDate={fundFilters.setStartDate}
                  endDate={fundFilters.endDate}
                  setEndDate={fundFilters.setEndDate}
                  onDownload={() => exportTableData(
                    fundFilters.filteredData,
                    'My Fund Received',
                    [
                      { header: 'ID', key: 'id' },
                      { header: 'Date', key: 'created_at', format: (v) => formatDate(v) },
                      { header: 'Manager', key: 'from_user_name' },
                      { header: 'Description', key: 'description', format: (v) => v || '-' },
                      { header: 'Payment Mode', key: 'payment_mode' },
                      { header: 'Ref #', key: 'transaction_id', format: (v, item) => v || item.cheque_number || '-' },
                      { header: 'Status', key: 'status' },
                      { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') }
                    ]
                  )}
                  placeholder="Allocated By, Amount, Status..."
                />
                <div className="table-responsive">
                  <table style={{ whiteSpace: 'nowrap' }}>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Manager</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Payment Mode</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {fundFilters.currentItems.length > 0 ? (
                        fundFilters.currentItems.map(fund => (
                          <tr key={fund.id}>
                            <td>{fund.id}</td>
                            <td>{formatDate(fund.created_at)}</td>
                            <td>{fund.from_user_name}</td>
                            <td style={{ maxWidth: '200px' }}>
                              <div
                                style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '200px' }}
                                title={fund.description || '-'}
                              >
                                {fund.description || '-'}
                              </div>
                            </td>
                            <td>{formatCurrency(fund.amount)}</td>
                            <td>{fund.payment_mode || '-'}</td>
                            <td>
                              <StatusBadge status={fund.status} />
                            </td>
                            <td>
                              <div style={{ display: 'flex', gap: '8px', alignItems: 'center', whiteSpace: 'nowrap' }}>
                                <button
                                  onClick={() => handleViewFund(fund)}
                                  className="btn btn-secondary"
                                  style={{ padding: '0.4rem', borderRadius: '50%' }}
                                  title="View Details"
                                >
                                  <FaEye />
                                </button>

                                {fund.status === 'RECEIVED' && (
                                  <button
                                    onClick={() => handleDownloadFund(fund)}
                                    className="btn btn-primary"
                                    style={{ padding: '0.4rem', borderRadius: '50%' }}
                                    title="Download Statement"
                                  >
                                    <FaDownload />
                                  </button>
                                )}
                                {fund.status === 'ALLOCATED' && (
                                  <button
                                    onClick={() => handleConfirmReceipt(fund.id)}
                                    className="btn btn-success"
                                    disabled={isSubmitting}
                                    style={{ padding: '0.4rem', fontSize: '0.8rem', minWidth: '80px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '5px' }}
                                  >
                                    {isSubmitting ? (
                                      <>
                                        <span className="btn-spinner" style={{ width: '0.8rem', height: '0.8rem' }}></span>
                                        Wait
                                      </>
                                    ) : 'Confirm'}
                                  </button>
                                )}
                              </div>
                            </td>
                          </tr>
                        ))
                      ) : (
                        <tr>
                          <td colSpan="8" style={{ textAlign: 'center', padding: '1rem' }}>No fund received found</td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={fundFilters.currentPage}
                  setCurrentPage={fundFilters.setCurrentPage}
                  totalPages={fundFilters.totalPages}
                  itemsPerPage={fundFilters.itemsPerPage}
                  setItemsPerPage={fundFilters.setItemsPerPage}
                />
              </div>
            )
          }

          {
            activeTab === 'reports' && (
              <ReportsSection role="USER" />
            )
          }

          {
            activeTab === 'profile' && (
              <ProfileSection />
            )
          }
        </div >
      </Layout>

      {viewExpense && (
        <InvoiceModal
          data={viewExpense}
          onClose={closeModal}
          onDownload={(expense) => handleDownloadPDF(expense, 'EXPENSE')}
        />
      )}

      {
        viewFund && (
          <InvoiceModal
            data={viewFund}
            type="FUND"
            onClose={closeModal}
            onDownload={(fund) => handleDownloadFund(fund)}
          />
        )
      }
    </>
  );
};

export default UserDashboard;


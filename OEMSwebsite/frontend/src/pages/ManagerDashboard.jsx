import React, { useState, useEffect, useCallback, useMemo, useRef } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import Layout from '../components/Layout';
import { useAuth } from '../context/AuthContext';
import { useSocket } from '../context/SocketContext';
import { useSettings } from '../context/SettingsContext';
import {
  createExpense,
  getExpenses,
  approveExpense,
  rejectExpense,
  getUsers,
  allocateOperationalFund,
  getOperationalFunds,
  confirmFundReceipt,
  requestExpansionFund,
  getExpansionFunds,
  getDashboardStats,
  allocateFundRequest,
  approveFundRequest,
  rejectFundRequest,

  getExpenseById,
  updateExpense,
  updateExpenseStatus,
  deleteExpense,
  updateExpansionFund,
  deleteExpansionFund,
  updateFund,
  deleteFund,
  deleteExpenseDocument
} from '../services/api';
import ReportsSection from '../components/ReportsSection';
import ProfileSection from '../components/ProfileSection';
import { EXPENSE_CATEGORIES } from '../utils/constants';
import { FaTachometerAlt, FaMoneyBillWave, FaFileInvoiceDollar, FaChartBar, FaWallet, FaExclamationCircle, FaUsers, FaArrowRight, FaHandHoldingUsd, FaUser, FaEye, FaDownload, FaFilePdf, FaArrowLeft, FaPlus, FaListUl, FaClock, FaHistory, FaFileAlt, FaCloudUploadAlt, FaCheckCircle, FaPlusCircle, FaHourglassHalf, FaUsersCog, FaClipboardCheck, FaFileContract, FaArrowDown, FaArrowUp, FaEdit, FaTrash, FaCheck, FaTimes, FaSpinner, FaCog } from 'react-icons/fa';
import Toast from '../components/Toast';
import StatusBadge from '../components/StatusBadge';
import * as XLSX from 'xlsx';

import { useTableFilters } from '../hooks/useTableFilters';
import TableControls from '../components/TableControls';
import TablePagination from '../components/TablePagination';
import DocumentList from '../components/DocumentList';

import InvoiceModal from '../components/InvoiceModal'; // Import the new modal
import AllocationForm from '../components/AllocationForm'; // Import AllocationForm
import { handleViewDocument, handleDownloadPDF, handleDownloadDocument } from '../utils/documentHandlers'; // Import handlers
import { generateExpensePDF, generateFundPDF, generateExpansionPDF, generateProfessionalPDF } from '../utils/pdfGenerator';

/**
 * ManagerDashboard Component
 * Key dashboard for Manager role. Handles team expenses and operational fund management.
 */
const ManagerDashboard = () => {
  const { user } = useAuth();
  const socket = useSocket();
  const { formatCurrencyValue } = useSettings();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const isInitialMount = useRef(true);
  const activeTab = searchParams.get('tab') || 'dashboard';
  const setActiveTab = (tab) => {
    if (tab === 'settings') {
      navigate('/settings');
      return;
    }
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', tab);
      // Clear sticky action/edit params
      newParams.delete('editAllocId');
      newParams.delete('editExpenseId');
      newParams.delete('editExpansionId');
      newParams.delete('allocatingRequestId');
      newParams.delete('requestingExpansion');
      newParams.delete('allocatingFromReceived');
      return newParams;
    }); // Changed from replace: true to push

    // Reset local UI and Form states for a clean slate
    setEditingFund(null);
    setEditingExpense(null);
    setEditingExpansion(null);
    setAllocatingRequestId(null);
    setExistingDocuments([]);

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
    setFundForm({
      to_user_id: '',
      amount: '',
      description: '',
      payment_mode: 'CASH',
      cheque_number: '',
      bank_name: '',
      cheque_date: '',
      account_holder_name: '',
      upi_id: '',
      transaction_id: ''
    });
    setExpansionForm({
      requested_amount: '',
      justification: ''
    });
    // Removed direct clearance of Success/Error to allow Toast persistence across tabs
  };
  const [expenses, setExpenses] = useState([]);
  const [users, setUsers] = useState([]);
  const [expansionFunds, setExpansionFunds] = useState([]);
  const [receivedFunds, setReceivedFunds] = useState([]);
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

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
  const [fundForm, setFundForm] = useState({
    to_user_id: '',
    amount: '',
    description: '',
    payment_mode: 'CASH'
  });
  const [expansionForm, setExpansionForm] = useState({
    requested_amount: '',
    justification: ''
  });

  // Validation & Animation States
  const [expenseFormErrors, setExpenseFormErrors] = useState({});
  const [isExpenseShaking, setIsExpenseShaking] = useState(false);
  const [expansionFormErrors, setExpansionFormErrors] = useState({});
  const [isExpansionShaking, setIsExpansionShaking] = useState(false);
  const [fundFormErrors, setFundFormErrors] = useState({});
  const [isFundShaking, setIsFundShaking] = useState(false);
  const [viewExpense, setViewExpense] = useState(null);
  const [viewFund, setViewFund] = useState(null);
  const [viewExpansion, setViewExpansion] = useState(null);
  const [editingExpense, setEditingExpense] = useState(null);
  const [editingExpansion, setEditingExpansion] = useState(null);
  const [editingFund, setEditingFund] = useState(null);
  const [allocatingRequestId, setAllocatingRequestId] = useState(null);
  const [existingDocuments, setExistingDocuments] = useState([]);

  // URL Persistence Effect
  useEffect(() => {
    // 1. Handle Edit Allocation Persistence
    const editAllocId = searchParams.get('editAllocId');
    if (editAllocId && receivedFunds.length > 0 && !editingFund) {
      const fundToEdit = receivedFunds.find(f => f.id.toString() === editAllocId);
      if (fundToEdit) {
        handleEditFund(fundToEdit);
      }
    }

    // 2. Handle Allocating Request Persistence
    const allocReqId = searchParams.get('allocatingRequestId');
    if (allocReqId && receivedFunds.length > 0 && !allocatingRequestId) {
      const fundObj = receivedFunds.find(f => f.id.toString() === allocReqId);
      if (fundObj) {
        handlePreFillAllocation(fundObj);
      }
    }

    // 3. Handle Edit Expense Persistence
    const editExpId = searchParams.get('editExpenseId');
    if (editExpId && expenses.length > 0 && !editingExpense) {
      const exp = expenses.find(e => e.id.toString() === editExpId);
      if (exp) {
        handleEditExpense(exp);
      }
    }

    // 4. Handle Edit Expansion Persistence
    const editExpnId = searchParams.get('editExpansionId');
    if (editExpnId && expansionFunds.length > 0 && !editingExpansion) {
      const expn = expansionFunds.find(e => e.id.toString() === editExpnId);
      if (expn) {
        handleEditExpansion(expn);
      }
    }

    // Clear states logic
    if (activeTab !== 'allocate_fund' && !editAllocId && !allocReqId) {
      setEditingFund(null);
      setAllocatingRequestId(null);
      // Don't clear form if it's being used for a fresh allocation
    }

    if (activeTab !== 'add_expense' && !editExpId) {
      setEditingExpense(null);
      setExistingDocuments([]);
    }

    if (activeTab !== 'request_expansion' && !editExpnId) {
      setEditingExpansion(null);
    }
  }, [activeTab, searchParams, receivedFunds, expenses, expansionFunds]);


  // Derived Data & Hooks
  const myExpenses = expenses.filter(e => e.user_id === user?.id);
  const pendingUserExpenses = expenses.filter(e => {
    // Check if there is ANY existing expansion request for this expense
    const hasExpansion = expansionFunds.some(ef => {
      const match = ef.justification?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
      return match && parseInt(match[1]) === e.id;
    });

    return (e.status === 'PENDING_APPROVAL' || e.status === 'RECEIPT_APPROVED' || e.status === 'EXPANSION_REQUESTED') && e.user_role === 'USER' && !hasExpansion;
  });
  const allUserExpenses = expenses.filter(e => e.user_role === 'USER');
  const allocatedFunds = receivedFunds.filter(f => f.from_user_id === user?.id && ['ALLOCATED', 'RECEIVED', 'COMPLETED'].includes(f.status));
  const receivedFundsList = receivedFunds.filter(f => f.to_user_id === user?.id);


  const myExpenseFilters = useTableFilters(myExpenses, ['title', 'category', 'department', 'amount'], 'expense_date');
  const pendingUserExpenseFilters = useTableFilters(pendingUserExpenses, ['title', 'full_name', 'department', 'amount'], 'expense_date');
  const allUserExpenseFilters = useTableFilters(allUserExpenses, ['title', 'full_name', 'department', 'amount', 'status'], 'expense_date');
  const allocatedFundFilters = useTableFilters(allocatedFunds, ['to_user_name', 'amount', 'status'], 'created_at');
  const receivedFundFilters = useTableFilters(receivedFundsList, ['from_user_name', 'amount', 'status'], 'created_at');

  const expansionFilters = useTableFilters(expansionFunds, ['requested_amount', 'status'], 'requested_at');

  const exportTableData = (data, title, columns) => {
    generateProfessionalPDF(title, columns, data);
  };

  const formatCurrency = (amount) => formatCurrencyValue(amount);

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('en-GB').replace(/\//g, '-');
  };

  useEffect(() => {
    setError('');
    // setSuccess(''); // Don't clear success immediately on tab change

    // Initial mount should show loader, subsequent tab changes should be silent
    if (isInitialMount.current) {
      loadDashboardData(false);
      isInitialMount.current = false;
    } else {
      loadDashboardData(true);
    }
  }, [activeTab]);

  // Shake Triggers
  const triggerExpenseShake = () => { setIsExpenseShaking(true); setTimeout(() => setIsExpenseShaking(false), 400); };
  const triggerExpansionShake = () => { setIsExpansionShaking(true); setTimeout(() => setIsExpansionShaking(false), 400); };
  const triggerFundShake = () => { setIsFundShaking(true); setTimeout(() => setIsFundShaking(false), 400); };

  // Validation Helpers
  const validateExpenseForm = () => {
    const newErrors = {};
    if (!expenseForm.title?.trim()) newErrors.title = 'Title is required';
    if (!expenseForm.category) newErrors.category = 'Category is required';
    if (expenseForm.category === 'Other' && !expenseForm.customCategory?.trim()) newErrors.customCategory = 'Specify category';
    if (!expenseForm.department) newErrors.department = 'Department is required';
    if (!expenseForm.amount || isNaN(expenseForm.amount) || Number(expenseForm.amount) <= 0) newErrors.amount = 'Valid amount required';
    if (!expenseForm.expense_date) newErrors.expense_date = 'Date is required';
    if (!editingExpense && (!expenseFiles || expenseFiles.length === 0)) newErrors.vouchers = 'Upload at least one voucher';
    setExpenseFormErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const validateExpansionForm = () => {
    const newErrors = {};
    if (!expansionForm.requested_amount || isNaN(expansionForm.requested_amount) || Number(expansionForm.requested_amount) <= 0) {
      newErrors.requested_amount = 'Valid amount required';
    }
    if (!expansionForm.justification?.trim()) newErrors.justification = 'Justification is required';
    setExpansionFormErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };



  /**
   * Core Data Fetching
   * Synchronizes dashboard state with backend API.
   */
  const loadDashboardData = async (silent = false) => {
    if (!silent) setLoading(true);
    try {
      console.log('Fetching dashboard stats...');
      const statsRes = await getDashboardStats();
      console.log('Stats loaded:', statsRes.data);
      setStats(statsRes.data.stats);

      console.log('Fetching expenses...');
      const expensesRes = await getExpenses();
      console.log('Expenses loaded:', expensesRes.data);
      setExpenses(expensesRes.data.expenses);

      // Auto-refresh currently viewed expense if open
      if (viewExpense) {
        const updated = (expensesRes.data.expenses || []).find(e => Number(e.id) === Number(viewExpense.id));
        if (updated) setViewExpense(updated);
      }

      if (activeTab === 'users' || activeTab === 'funds' || activeTab === 'allocate_fund' || activeTab === 'fund_history' || activeTab === 'received_funds' || activeTab === 'fund_requests' || activeTab === 'pending_approvals') {
        console.log('Fetching users, funds, and expansion funds...');
        const [usersRes, fundsRes, expansionRes] = await Promise.all([
          getUsers(),
          getOperationalFunds(),
          getExpansionFunds()
        ]);

        setUsers(usersRes.data.users);
        setReceivedFunds(fundsRes.data.funds);
        setExpansionFunds(expansionRes.data.funds);

        // Auto-refresh currently viewed fund if open
        if (viewFund) {
          const updated = (fundsRes.data.funds || []).find(f => Number(f.id) === Number(viewFund.id));
          if (updated) setViewFund(updated);
        }

        // Auto-refresh currently viewed expansion if open
        if (viewExpansion) {
          const updated = (expansionRes.data.funds || []).find(e => Number(e.id) === Number(viewExpansion.id));
          if (updated) setViewExpansion(updated);
        }

        console.log('Current User ID:', user?.id);
        console.log('Fetched Users:', usersRes.data.users);
        const myTeam = usersRes.data.users.filter(u => Number(u.manager_id) === Number(user?.id));
        console.log('Filtered Team:', myTeam);
        setUsers(myTeam);
        setReceivedFunds(fundsRes.data.funds || []);
        setExpansionFunds(expansionRes.data.funds || []);
      }
      if (activeTab === 'expansion' || activeTab === 'request_expansion' || activeTab === 'expansion_history') {
        console.log('Fetching expansion funds...');
        const res = await getExpansionFunds();
        setExpansionFunds(res.data.funds);
      }
    } catch (err) {
      console.error('Dashboard data load error:', err);
      const msg = err.response?.data?.message || err.message || 'Unknown error';
      setError(`Failed to load data: ${msg}`);
    }
    setLoading(false);
  };

  const handleCreateExpense = async (e) => {
    e.preventDefault();
    setExpenseFormErrors({});

    if (!validateExpenseForm()) {
      triggerExpenseShake();
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
      triggerExpenseShake();
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleViewExpense = async (expense) => {
    try {
      const res = await getExpenseById(expense.id);
      setViewExpense({ ...res.data.expense, documents: res.data.documents });
    } catch (err) {
      setError('Failed to fetch expense details');
      setViewExpense(expense); // Fallback to basic
    }
  };

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

  const handleDownloadExpansion = (fund) => {
    handleDownloadPDF(fund, 'EXPANSION');
  };

  const handleApproveExpense = async (id) => {
    try {
      setIsSubmitting(true);
      await approveExpense(id);
      setSuccess('Expense approved');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to approve expense');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleRejectExpense = async (id) => {
    const reason = prompt('Enter rejection reason:');
    if (!reason) return;
    try {
      setIsSubmitting(true);
      await rejectExpense(id, reason);
      setSuccess('Expense rejected');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to reject expense');
    } finally {
      setIsSubmitting(false);
    }
  };


  const handleEditExpense = async (expense) => {
    const isCustomCategory = expense.category && !EXPENSE_CATEGORIES.includes(expense.category);
    setEditingExpense(expense);
    setExpenseForm({
      title: expense.title,
      category: isCustomCategory ? 'Other' : expense.category,
      customCategory: isCustomCategory ? expense.category : '',
      department: expense.department || '',
      amount: expense.amount,
      expense_date: expense.expense_date.split('T')[0],
      description: expense.description || ''
    });
    setExpenseFiles([]); // Clear files, user can upload new ones if needed
    setExistingDocuments([]);

    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'add_expense');
      newParams.set('editExpenseId', expense.id);
      return newParams;
    });

    try {
      const res = await getExpenseById(expense.id);
      if (res.data.documents) {
        setExistingDocuments(res.data.documents);
      }
    } catch (err) {
      console.error("Failed to fetch documents", err);
    }
  };

  const handleUpdateExpense = async (e) => {
    e.preventDefault();
    setExpenseFormErrors({});
    if (!validateExpenseForm()) {
      triggerExpenseShake();
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
    expenseFiles.forEach(file => formData.append('vouchers', file));

    try {
      setIsSubmitting(true);
      await updateExpense(editingExpense.id, formData);
      setSuccess('Expense updated successfully');
      setEditingExpense(null);
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('editExpenseId');
        newParams.set('tab', 'my_expenses');
        return newParams;
      });
      setExpenseForm({ title: '', category: '', customCategory: '', department: '', amount: '', expense_date: new Date().toISOString().split('T')[0], description: '' });
      setExpenseFiles([]);
      setExistingDocuments([]);
      setExpenseFormErrors({});
      loadDashboardData(true);
    } catch (err) {
      setExpenseFormErrors({ form: err.response?.data?.message || 'Failed to update expense' });
      triggerExpenseShake();
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteExpense = async (id) => {
    if (!window.confirm('Are you sure you want to delete this expense?')) return;
    try {
      await deleteExpense(id);
      setSuccess('Expense deleted successfully');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to delete expense');
    }
  };

  const handleDeleteDocument = async (docId) => {
    if (!window.confirm("Are you sure you want to delete this file?")) return;
    try {
      await deleteExpenseDocument(editingExpense.id, docId);
      setExistingDocuments(prev => prev.filter(d => d.id !== docId));
      setSuccess('Document deleted');
      // Start reload but don't block
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to delete document');
    }
  };

  const handleEditExpansion = (fund) => {
    setEditingExpansion(fund);
    setExpansionForm({
      requested_amount: fund.requested_amount,
      justification: fund.justification
    });
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'request_expansion');
      newParams.set('editExpansionId', fund.id);
      return newParams;
    });
  };

  const handleUpdateExpansion = async (e) => {
    e.preventDefault();
    setExpansionFormErrors({});
    if (!validateExpansionForm()) {
      triggerExpansionShake();
      return;
    }
    try {
      setIsSubmitting(true);
      await updateExpansionFund(editingExpansion.id, expansionForm);
      setSuccess('Expansion request updated successfully');
      setEditingExpansion(null);
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('editExpansionId');
        return newParams;
      });
      setExpansionForm({ requested_amount: '', justification: '' });
      setActiveTab('expansion_history');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to update expansion request');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteExpansion = async (id) => {
    if (!window.confirm('Are you sure you want to delete this request?')) return;
    try {
      // Find the request to get the linked expense ID from justification
      const requestToDelete = expansionFunds.find(ef => ef.id === id);
      if (requestToDelete) {
        const idMatch = requestToDelete.justification?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
        if (idMatch) {
          const expenseId = idMatch[1];
          // Revert expense status to Approved so it reappears in Pending/Team lists with Expansion button
          await updateExpenseStatus(expenseId, 'RECEIPT_APPROVED');
        }
      }

      await deleteExpansionFund(id);
      setSuccess('Request deleted and expense status reverted');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to delete or revert status');
    }
  };

  const handleEditFund = (fund) => {
    setEditingFund(fund);
    setFundForm({
      to_user_id: fund.to_user_id,
      amount: fund.amount,
      payment_mode: fund.payment_mode || 'CASH',
      description: fund.description || '',
      cheque_number: fund.cheque_number || '',
      bank_name: fund.bank_name || '',
      cheque_date: fund.cheque_date ? fund.cheque_date.split('T')[0] : '',
      account_holder_name: fund.account_holder_name || '',
      upi_id: fund.upi_id || '',
      transaction_id: fund.transaction_id || ''
    });
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'allocate_fund');
      newParams.set('editAllocId', fund.id);
      return newParams;
    }, { replace: true });
  };

  const handleUpdateFund = async (formData) => {
    try {
      setIsSubmitting(true);
      setError('');
      setSuccess('');

      await updateFund(editingFund.id, formData);
      setSuccess('Fund allocation updated successfully');

      // Comprehensive form reset
      setFundForm({
        to_user_id: '',
        amount: '',
        description: '',
        payment_mode: 'CASH',
        cheque_number: '',
        bank_name: '',
        cheque_date: '',
        account_holder_name: '',
        upi_id: '',
        transaction_id: ''
      });
      setEditingFund(null);

      // Clear URL params IMMEDIATELY
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('editAllocId');
        return newParams;
      }, { replace: true });

      await loadDashboardData(true);

      // Redirect tab after a short delay
      setTimeout(() => {
        setSearchParams(prev => {
          const newParams = new URLSearchParams(prev);
          newParams.set('tab', 'fund_history');
          return newParams;
        }, { replace: true });
        setActiveTab('fund_history');
      }, 1500);

    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || 'Failed to update fund allocation');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteFund = async (id) => {
    if (!window.confirm('Are you sure you want to delete this allocation?')) return;
    try {
      await deleteFund(id);
      setSuccess('Allocation deleted');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to delete');
    }
  };

  const handleConfirmFundReceipt = async (id) => {
    try {
      await confirmFundReceipt(id);
      setSuccess('expense fund received');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to confirm receipt');
    }
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



  const handleAllocateFund = async (formData) => {
    try {
      setIsSubmitting(true);
      setError('');
      setSuccess('');

      if (allocatingRequestId) {
        await updateFund(allocatingRequestId, formData);
        await allocateFundRequest(allocatingRequestId);
        setSuccess('Fund allocated for request');
        setAllocatingRequestId(null);
      } else {
        await allocateOperationalFund(formData);
        setSuccess('Fund allocated successfully');
      }

      // Comprehensive form reset
      setFundForm({
        to_user_id: '',
        amount: '',
        description: '',
        payment_mode: 'CASH',
        cheque_number: '',
        bank_name: '',
        cheque_date: '',
        account_holder_name: '',
        upi_id: '',
        transaction_id: ''
      });
      setEditingFund(null);

      // Clear URL pre-fill params IMMEDIATELY
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('allocatingRequestId');
        newParams.delete('editAllocId');
        newParams.delete('allocatingFromReceived');
        // Add any other pre-fill params if discovered
        return newParams;
      }, { replace: true });

      await loadDashboardData(true);

      // Redirect tab after a short delay so user sees success message
      setTimeout(() => {
        setSearchParams(prev => {
          const newParams = new URLSearchParams(prev);
          newParams.set('tab', 'fund_history');
          return newParams;
        }, { replace: true });
        setActiveTab('fund_history');
      }, 1500);

    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || 'Failed to allocate fund');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handlePreFillAllocation = (fund) => {
    setFundForm({
      to_user_id: fund.to_user_id,
      amount: fund.amount,
      description: fund.description || '',
      payment_mode: 'CASH'
    });
    setAllocatingRequestId(fund.id);
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'allocate_fund');
      newParams.set('allocatingRequestId', fund.id);
      return newParams;
    }, { replace: true });
  };

  const handlePreFillFromReceived = (fund) => {
    // Extract Expense ID from description if it exists: "Expansion fund for approved expense: ... (ID: 20)"
    const idMatch = fund.description?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
    const expenseId = idMatch ? parseInt(idMatch[1]) : null;

    let targetUserId = '';
    if (expenseId) {
      const expense = expenses.find(e => e.id === expenseId);
      if (expense) {
        targetUserId = expense.user_id;
      }
    }

    const newForm = {
      to_user_id: targetUserId,
      amount: fund.amount,
      description: fund.description || '',
      payment_mode: fund.payment_mode || 'CASH',
      // Pass through payment details
      cheque_number: fund.cheque_number || '',
      bank_name: fund.bank_name || '',
      cheque_date: fund.cheque_date ? fund.cheque_date.split('T')[0] : '', // Format for date input
      account_holder_name: fund.account_holder_name || '',
      cheque_image_path: fund.cheque_image_path || null, // Pass image path
      upi_id: fund.upi_id || '',
      transaction_id: fund.transaction_id || ''
    };

    setFundForm(newForm);
    // Remove direct setActiveTab call as it resets the form. 
    // setSearchParams below will update the activeTab (derived from URL)

    // Persist in URL
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'allocate_fund');
      newParams.set('allocatingFromReceived', 'true');
      return newParams;
    }, { replace: true });
  };

  const handleRequestExpansion = async (e) => {
    e.preventDefault();
    if (!expansionForm.requested_amount || !expansionForm.justification) {
      setError('Please fill in all fields for expansion request');
      return;
    }

    // Validation: Ensure justification contains an Expense ID
    const idMatch = expansionForm.justification.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
    if (!idMatch) {
      setError('Expansion requests must be linked to an approved expense. Please use the "Request Expansion" button from an approved expense record.');
      return;
    }

    try {
      setIsSubmitting(true);
      setError('');
      setSuccess('');
      await requestExpansionFund(expansionForm);

      setSuccess('Expansion request submitted successfully');

      setExpansionForm({ requested_amount: '', justification: '' });
      loadDashboardData(true);

      // Redirect to expansion history after successful submission
      setTimeout(() => {
        setSearchParams(prev => {
          const newParams = new URLSearchParams(prev);
          newParams.delete('requestingExpansion');
          newParams.set('tab', 'expansion_history');
          return newParams;
        }, { replace: true });
        setActiveTab('expansion_history');
      }, 1500);
    } catch (err) {
      setError('Failed to request expansion fund');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleRequestExpansionForExpense = (expense) => {
    // Reset specific states to avoid conflicts, but do NOT reset the form we are about to fill
    setEditingFund(null);
    setEditingExpense(null);
    setEditingExpansion(null);
    setAllocatingRequestId(null);

    setExpansionForm({
      requested_amount: expense.amount,
      justification: `Expansion fund for approved expense: ${expense.title} (ID: ${expense.id})`
    });

    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'request_expansion');
      newParams.set('requestingExpansion', 'true');
      // Clear sticky action/edit params
      newParams.delete('editAllocId');
      newParams.delete('editExpenseId');
      newParams.delete('editExpansionId');
      newParams.delete('allocatingRequestId');
      return newParams;
    }, { replace: true });

    setSuccess('Expansion request form pre-filled with expense details');
  };

  const handleConfirmReceipt = async (id) => {
    try {
      await confirmFundReceipt(id);
      setSuccess('Fund receipt confirmed');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to confirm receipt');
    }
  };

  const handleRemoveFile = (index) => {
    setExpenseFiles(prev => prev.filter((_, i) => i !== index));
  };

  const closeModal = () => {
    setViewExpense(null);
    setViewFund(null);
    setViewExpansion(null);
  };

  const tabs = [
    { id: 'dashboard', label: 'Dashboard', icon: <FaTachometerAlt /> },
    {
      id: 'expenses_root',
      label: 'Expenses',
      icon: <FaFileInvoiceDollar />,
      subItems: [
        { id: 'add_expense', label: 'Add Expense', icon: <FaPlusCircle /> },
        { id: 'my_expenses', label: 'My Expenses', icon: <FaListUl /> },
        { id: 'pending_approvals', label: 'Pending Approval', icon: <FaCheckCircle /> },
        { id: 'team_expenses', label: 'All Expense', icon: <FaUsersCog /> }
      ]
    },
    {
      id: 'funds_root',
      label: 'Operational Fund',
      icon: <FaWallet />,
      subItems: [
        { id: 'allocate_fund', label: 'Allocate Fund', icon: <FaHandHoldingUsd /> },
        { id: 'received_funds', label: 'Received Funds', icon: <FaArrowDown /> },
        { id: 'fund_history', label: 'Allocated History', icon: <FaHistory /> },

      ]
    },
    {
      id: 'expansion_root',
      label: 'Expansion Fund',
      icon: <FaChartBar />,
      subItems: [
        { id: 'request_expansion', label: 'Request Expansion', icon: <FaPlusCircle /> },
        { id: 'expansion_history', label: 'Request History', icon: <FaHistory /> }
      ]
    },
    { id: 'reports', label: 'Reports', icon: <FaFileAlt /> },
    { id: 'settings', label: 'Settings', icon: <FaCog /> }
  ];


  const getPageTitle = () => {
    switch (activeTab) {
      case 'dashboard': return 'Dashboard Overview';
      case 'add_expense': return editingExpense ? 'Edit Expense' : 'Create Expense';
      case 'my_expenses': return 'My Expenses';
      case 'pending_approvals': return 'Pending Approvals for Team';
      case 'team_expenses': return 'All Expense History';
      case 'allocate_fund': return editingFund ? 'Edit Allocation' : 'Allocate Operational Fund';
      case 'received_funds': return 'Received Funds';
      case 'fund_history': return 'Allocated Funds History';

      case 'request_expansion': return editingExpansion ? 'Edit Expansion Request' : 'Request Expansion Fund';
      case 'expansion_history': return 'Expansion Fund History';
      case 'reports': return 'Reports';
      case 'profile': return 'My Profile';
      default: return 'Manager Dashboard';
    }
  };

  const handleBack = () => {
    switch (activeTab) {
      case 'add_expense':
        setActiveTab('my_expenses');
        break;
      case 'allocate_fund':
        setActiveTab('fund_history');
        break;
      case 'request_expansion':
        setActiveTab('expansion_history');
        break;
      case 'dashboard':
        window.history.back();
        break;
      default:
        setActiveTab('dashboard');
        break;
    }
  };

  return (
    <>
      <Layout
        title="Manager Dashboard"
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

                {/* Card 1: Total Funds Received (Allocated) */}
                <div className="card stat-card info">
                  <div className="stat-icon-wrapper"><FaMoneyBillWave /></div>
                  <div>
                    <span className="stat-label">Total Funds Received</span>
                    <span className="stat-value">
                      {formatCurrency(stats.receivedFunds ? stats.receivedFunds.filter(f => f.status === 'RECEIVED').reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) : 0)}
                    </span>
                  </div>
                </div>

                {/* Card 2: My Expenses (Outflow 1) */}
                <div className="card stat-card warning">
                  <div className="stat-icon-wrapper"><FaFileInvoiceDollar /></div>
                  <div>
                    <span className="stat-label">My Expenses</span>
                    <span className="stat-value">
                      {formatCurrency(
                        stats.ownExpenses
                          ? stats.ownExpenses.reduce((sum, e) => sum + (parseFloat(e.total_amount) || 0), 0)
                          : expenses.filter(e => e.user_id === user?.id && e.status !== 'REJECTED').reduce((sum, e) => sum + (parseFloat(e.amount) || 0), 0)
                      )}
                    </span>
                  </div>
                </div>

                {/* Card 3: Allocated to Team (Outflow 2) */}
                <div className="card stat-card primary">
                  <div className="stat-icon-wrapper"><FaArrowRight /></div>
                  <div>
                    <span className="stat-label">Allocated to Team</span>
                    <span className="stat-value">
                      {formatCurrency(stats.allocatedFunds ? stats.allocatedFunds.filter(f => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].includes(f.status)).reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) : 0)}
                    </span>
                  </div>
                </div>

                {/* Card 4: Outstanding Balance */}
                <div className="card stat-card success">
                  <div className="stat-icon-wrapper"><FaWallet /></div>
                  <div>
                    <span className="stat-label">Outstanding Balance</span>
                    <span className="stat-value">
                      {formatCurrency(
                        (stats.receivedFunds ? stats.receivedFunds.filter(f => f.status === 'RECEIVED').reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) : 0) -
                        (stats.ownExpenses
                          ? stats.ownExpenses.filter(e => ['RECEIPT_APPROVED', 'FUND_ALLOCATED', 'EXPANSION_ALLOCATED', 'COMPLETED'].includes(e.status)).reduce((sum, e) => sum + (parseFloat(e.total_amount) || 0), 0)
                          : expenses.filter(e => e.user_id === user?.id && ['RECEIPT_APPROVED', 'FUND_ALLOCATED', 'EXPANSION_ALLOCATED', 'COMPLETED'].includes(e.status)).reduce((sum, e) => sum + (parseFloat(e.amount) || 0), 0)) -
                        (stats.allocatedFunds ? stats.allocatedFunds.filter(f => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].includes(f.status)).reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) : 0)
                      )}
                    </span>
                  </div>
                </div>

                <div className="card stat-card warning">
                  <div className="stat-icon-wrapper"><FaExclamationCircle /></div>
                  <div>
                    <span className="stat-label">Pending Approvals</span>
                    <span className="stat-value">{stats.pendingApprovals || 0}</span>
                  </div>
                </div>

              </div>
            </div>
          )}

          {activeTab === 'add_expense' && (
            <div className="dashboard-creation-container">
              <div className="card">
                {/* Title removed */}
                <form
                  onSubmit={editingExpense ? handleUpdateExpense : handleCreateExpense}
                  className={`card ${isExpenseShaking ? 'shake' : ''}`}
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
                          <div key={idx} style={{ fontSize: '0.8rem', color: 'var(--primary-600)', display: 'flex', alignItems: 'center', gap: '0.5rem', justifyContent: 'space-between', background: '#f8fafc', padding: '4px 8px', borderRadius: '4px' }}>
                            <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                              <FaFileAlt /> {file.name} (New)
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
                          <div key={doc.id || idx} style={{ fontSize: '0.8rem', color: 'var(--primary-600)', display: 'flex', alignItems: 'center', gap: '0.5rem', justifyContent: 'space-between', background: '#e0f2fe', padding: '4px 8px', borderRadius: '4px' }}>
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
                  <div style={{ display: 'flex', gap: '1rem', marginTop: '10px' }}>
                    <button
                      type="submit"
                      className="btn btn-primary"
                      disabled={isSubmitting}
                      style={{ display: 'flex', alignItems: 'center', gap: '8px', minWidth: '140px', justifyContent: 'center' }}
                    >
                      {isSubmitting ? (
                        <>
                          <span className="btn-spinner"></span> Processing...
                        </>
                      ) : (
                        editingExpense ? 'Update Expense' : 'Create Expense'
                      )}
                    </button>
                    {editingExpense && (
                      <button
                        type="button"
                        onClick={() => {
                          setEditingExpense(null);
                          setExpenseForm({
                            title: '',
                            category: '',
                            department: '',
                            amount: '',
                            expense_date: new Date().toISOString().split('T')[0],
                            description: ''
                          });
                          setExistingDocuments([]);
                          setActiveTab('my_expenses');
                        }}
                        className="btn btn-secondary"
                      >
                        Cancel
                      </button>
                    )}
                  </div>
                </form>
              </div>

              <div className="side-recent">
                <h4>Recent My Expenses</h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                  {myExpenses.slice(0, 3).map(expense => (
                    <div key={expense.id} className="card" style={{ padding: '1rem', borderLeft: '4px solid var(--primary-500)' }}>
                      <div className="expense-details">
                        <div className="expense-title">{expense.title}</div>
                        <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{formatCurrency(expense.amount)} • {formatDate(expense.expense_date)}</div>
                      </div>
                      <div className="expense-status">
                        <StatusBadge status={expense.status} />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div >
          )}

          {
            activeTab === 'my_expenses' && (
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>

                </div>

                <TableControls
                  searchTerm={myExpenseFilters.searchTerm}
                  setSearchTerm={myExpenseFilters.setSearchTerm}
                  startDate={myExpenseFilters.startDate}
                  setStartDate={myExpenseFilters.setStartDate}
                  endDate={myExpenseFilters.endDate}
                  setEndDate={myExpenseFilters.setEndDate}
                  onDownload={() => exportTableData(
                    myExpenseFilters.filteredData,
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
                      {myExpenseFilters.currentItems.map(expense => (
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
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button
                                onClick={() => handleViewExpense(expense)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
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
                              {(expense.status === 'PENDING_APPROVAL' || expense.status === 'REJECTED') && (
                                <>
                                  <button
                                    onClick={() => handleEditExpense(expense)}
                                    className="btn btn-warning"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Edit Expense"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaEdit />}
                                  </button>
                                  <button
                                    onClick={() => handleDeleteExpense(expense.id)}
                                    className="btn btn-danger"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Delete Expense"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaTrash />}
                                  </button>
                                </>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                      {myExpenseFilters.currentItems.length === 0 && (<tr><td colSpan="8" style={{ textAlign: 'center' }}>No expenses found</td></tr>)}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={myExpenseFilters.currentPage}
                  setCurrentPage={myExpenseFilters.setCurrentPage}
                  totalPages={myExpenseFilters.totalPages}
                  itemsPerPage={myExpenseFilters.itemsPerPage}
                  setItemsPerPage={myExpenseFilters.setItemsPerPage}
                />
              </div>
            )
          }


          {
            activeTab === 'pending_approvals' && (
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>

                </div>
                <TableControls
                  searchTerm={pendingUserExpenseFilters.searchTerm}
                  setSearchTerm={pendingUserExpenseFilters.setSearchTerm}
                  startDate={pendingUserExpenseFilters.startDate}
                  setStartDate={pendingUserExpenseFilters.setStartDate}
                  endDate={pendingUserExpenseFilters.endDate}
                  setEndDate={pendingUserExpenseFilters.setEndDate}
                  onDownload={() => exportTableData(
                    pendingUserExpenseFilters.filteredData,
                    'Pending Expenses',
                    [
                      { header: 'ID', key: 'id' },
                      { header: 'Date', key: 'expense_date', format: (v) => formatDate(v) },
                      { header: 'Employee', key: 'full_name' },
                      { header: 'Email', key: 'email' },
                      { header: 'Title', key: 'title' },
                      { header: 'Category', key: 'category' },
                      { header: 'Department', key: 'department', format: (v) => v || '-' },
                      { header: 'Description', key: 'description', format: (v) => v || '-' },
                      { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') },
                      { header: 'Status', key: 'status' }
                    ]
                  )}
                  placeholder="Title, User, Amount..."
                />
                <div className="table-responsive">
                  <table style={{ whiteSpace: 'nowrap' }}>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Title</th>
                        <th>Created By</th>
                        <th>Category</th>
                        <th>Department</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {pendingUserExpenseFilters.currentItems.map(expense => (
                        <tr key={expense.id}>
                          <td>{expense.id}</td>
                          <td>{formatDate(expense.expense_date)}</td>
                          <td>{expense.title}</td>
                          <td>
                            {expense.full_name}
                            <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginLeft: '4px' }}>
                              ({expense.user_role})
                            </span>
                          </td>
                          <td>{expense.category}</td>
                          <td>{expense.department || '-'}</td>
                          <td>{formatCurrency(expense.amount)}</td>
                          <td>
                            <StatusBadge status={expense.status} />
                          </td>
                          <td>
                            <div style={{ display: 'flex', gap: '10px', alignItems: 'center', whiteSpace: 'nowrap' }}>
                              <button
                                onClick={() => handleViewExpense(expense)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
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
                              {expense.status === 'PENDING_APPROVAL' ? (
                                <>
                                  <button
                                    onClick={() => handleApproveExpense(expense.id)}
                                    className="btn"
                                    style={{ background: '#28a745', color: 'white', padding: '0', borderRadius: '50%', width: '32px', height: '32px', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 4px rgba(40, 167, 69, 0.2)', border: 'none', transition: 'all 0.2s' }}
                                    title="Approve"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? (
                                      <span className="btn-spinner" style={{ width: '14px', height: '14px', borderWidth: '2px' }}></span>
                                    ) : (
                                      <FaCheck style={{ fontSize: '0.85rem' }} />
                                    )}
                                  </button>
                                  <button
                                    onClick={() => handleRejectExpense(expense.id)}
                                    className="btn"
                                    style={{ background: '#dc3545', color: 'white', padding: '0', borderRadius: '50%', width: '32px', height: '32px', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 4px rgba(220, 53, 69, 0.2)', border: 'none', transition: 'all 0.2s' }}
                                    title="Reject"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? (
                                      <span className="btn-spinner" style={{ width: '14px', height: '14px', borderWidth: '2px' }}></span>
                                    ) : (
                                      <FaTimes style={{ fontSize: '0.85rem' }} />
                                    )}
                                  </button>
                                </>
                              ) : (expense.status === 'RECEIPT_APPROVED' && expense.user_id !== user.id && !expansionFunds.some(ef => ef.justification?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i)?.[1] === expense.id.toString())) ? (
                                <button
                                  onClick={() => handleRequestExpansionForExpense(expense)}
                                  className="btn"
                                  style={{
                                    padding: '6px 14px',
                                    fontSize: '0.85rem',
                                    color: 'white',
                                    background: 'linear-gradient(135deg, #FF8C00 0%, #FF4500 100%)',
                                    border: 'none',
                                    borderRadius: '20px',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '6px',
                                    boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
                                    fontWeight: '500',
                                    transition: 'all 0.3s ease'
                                  }}
                                >
                                  <FaPlusCircle /> Request Expansion
                                </button>
                              ) : null}
                            </div>
                          </td>
                        </tr>
                      ))}
                      {pendingUserExpenseFilters.currentItems.length === 0 && (<tr><td colSpan="8" style={{ textAlign: 'center' }}>No pending expenses</td></tr>)}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={pendingUserExpenseFilters.currentPage}
                  setCurrentPage={pendingUserExpenseFilters.setCurrentPage}
                  totalPages={pendingUserExpenseFilters.totalPages}
                  itemsPerPage={pendingUserExpenseFilters.itemsPerPage}
                  setItemsPerPage={pendingUserExpenseFilters.setItemsPerPage}
                />
              </div>
            )
          }

          {
            activeTab === 'team_expenses' && (
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>

                </div>
                <TableControls
                  searchTerm={allUserExpenseFilters.searchTerm}
                  setSearchTerm={allUserExpenseFilters.setSearchTerm}
                  startDate={allUserExpenseFilters.startDate}
                  setStartDate={allUserExpenseFilters.setStartDate}
                  endDate={allUserExpenseFilters.endDate}
                  setEndDate={allUserExpenseFilters.setEndDate}
                  onDownload={() => exportTableData(
                    allUserExpenseFilters.filteredData,
                    'All Expense',
                    [
                      { header: 'ID', key: 'id' },
                      { header: 'Date', key: 'expense_date', format: (v) => formatDate(v) },
                      { header: 'Employee', key: 'full_name' },
                      { header: 'Email', key: 'email' },
                      { header: 'Title', key: 'title' },
                      { header: 'Category', key: 'category' },
                      { header: 'Department', key: 'department', format: (v) => v || '-' },
                      { header: 'Description', key: 'description', format: (v) => v || '-' },
                      { header: 'Approved By', key: 'approved_by_name', format: (v, item) => item.approved_by_name ? `${item.approved_by_name} (${item.approved_by_role})` : '-' },
                      { header: 'Status', key: 'status' },
                      { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') }
                    ]
                  )}
                  placeholder="Title, User, Category..."
                />
                <div className="table-responsive">
                  <table style={{ whiteSpace: 'nowrap' }}>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Title</th>
                        <th>Created By</th>
                        <th>Category</th>
                        <th>Department</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {allUserExpenseFilters.currentItems.map(expense => (
                        <tr key={expense.id}>
                          <td>{expense.id}</td>
                          <td>{formatDate(expense.expense_date)}</td>
                          <td>{expense.title}</td>
                          <td>
                            {expense.full_name}
                            <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginLeft: '4px' }}>
                              ({expense.user_role})
                            </span>
                          </td>
                          <td>{expense.category}</td>
                          <td>{expense.department || '-'}</td>
                          <td>{formatCurrency(expense.amount)}</td>
                          <td>
                            <StatusBadge status={expense.status} />
                          </td>
                          <td>
                            <div style={{ display: 'flex', gap: '10px', alignItems: 'center', whiteSpace: 'nowrap' }}>
                              <button
                                onClick={() => handleViewExpense(expense)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
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
                              {(expense.status === 'RECEIPT_APPROVED' && expense.user_id != user.id && !expansionFunds.some(ef => ef.justification?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i)?.[1] === expense.id.toString())) && (
                                <button
                                  onClick={() => handleRequestExpansionForExpense(expense)}
                                  className="btn btn-warning"
                                  style={{ padding: '0.4rem', borderRadius: '50%' }}
                                  title="Request Expansion"
                                >
                                  <FaPlusCircle />
                                </button>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                      {allUserExpenseFilters.currentItems.length === 0 && (<tr><td colSpan="8" style={{ textAlign: 'center' }}>No expenses found</td></tr>)}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={allUserExpenseFilters.currentPage}
                  setCurrentPage={allUserExpenseFilters.setCurrentPage}
                  totalPages={allUserExpenseFilters.totalPages}
                  itemsPerPage={allUserExpenseFilters.itemsPerPage}
                  setItemsPerPage={allUserExpenseFilters.setItemsPerPage}
                />
              </div>
            )
          }



          {
            activeTab === 'allocate_fund' && (
              <div className="dashboard-creation-container">
                {/* Check if we are in an active allocation flow */}
                {(fundForm.to_user_id || editingFund || searchParams.get('allocatingFromReceived')) ? (
                  <AllocationForm
                    managers={users}
                    initialData={fundForm}
                    onSubmit={editingFund ? handleUpdateFund : handleAllocateFund}
                    onCancel={() => {
                      setEditingFund(null);
                      setFundForm({ to_user_id: '', amount: '', description: '', payment_mode: 'CASH' });
                      setSearchParams(prev => {
                        const newParams = new URLSearchParams(prev);
                        newParams.delete('allocatingFromReceived');
                        if (editingFund) {
                          newParams.set('tab', 'fund_history');
                        } else {
                          newParams.set('tab', 'dashboard');
                        }
                        return newParams;
                      });
                    }}
                    loading={isSubmitting}
                  />
                ) : (
                  <div className="dashboard-empty-state">
                    <div className="dashboard-empty-icon" style={{ color: 'var(--primary-200)' }}>
                      <FaHandHoldingUsd />
                    </div>
                    <h3 className="dashboard-empty-title">Ready to Allocate Funds?</h3>
                    <p className="dashboard-empty-text">
                      To allocate funds to an employee, please first click the <strong>'Allocate'</strong> button in the <strong>Received Funds</strong> tab after receiving payment from the CEO.
                    </p>
                    <div className="dashboard-empty-actions">
                      <button onClick={() => setActiveTab('received_funds')} className="btn btn-primary">
                        Go to Received Funds
                      </button>
                    </div>
                  </div>

                )}

                <div className="side-recent">
                  <h4>Recent Allocations</h4>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                    {allocatedFunds.slice(0, 3).map(fund => (
                      <div key={fund.id} className="card" style={{ padding: '1rem', borderLeft: '4px solid var(--success-500)' }}>
                        <div className="expense-details">
                          <div className="expense-title">To: {fund.to_user_name}</div>
                          <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{formatCurrency(fund.amount)} • {formatDate(fund.created_at)}</div>
                        </div>
                        <div className="expense-status">
                          <StatusBadge status={fund.status} />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )
          }

          {
            activeTab === 'fund_history' && (
              <div>

                <TableControls
                  searchTerm={allocatedFundFilters.searchTerm}
                  setSearchTerm={allocatedFundFilters.setSearchTerm}
                  startDate={allocatedFundFilters.startDate}
                  setStartDate={allocatedFundFilters.setStartDate}
                  endDate={allocatedFundFilters.endDate}
                  setEndDate={allocatedFundFilters.setEndDate}
                  onDownload={() => exportTableData(
                    allocatedFundFilters.filteredData,
                    'Allocated Funds',
                    [
                      { header: 'ID', key: 'id' },
                      { header: 'Date', key: 'created_at', format: (v) => formatDate(v) },
                      { header: 'To User', key: 'to_user_name' },
                      { header: 'Description', key: 'description', format: (v) => v || '-' },
                      { header: 'Payment Mode', key: 'payment_mode' },
                      { header: 'Ref #', key: 'transaction_id', format: (v, item) => v || item.cheque_number || '-' },
                      { header: 'Status', key: 'status' },
                      { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') }
                    ]
                  )}
                  placeholder="User, Amount, Mode..."
                />
                <div className="table-responsive">
                  <table style={{ whiteSpace: 'nowrap' }}>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>To User</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Payment Mode</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {allocatedFundFilters.currentItems.map(fund => (
                        <tr key={fund.id}>
                          <td>{fund.id}</td>
                          <td>{formatDate(fund.created_at)}</td>
                          <td>{fund.to_user_name}</td>
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
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button
                                onClick={() => setViewFund(fund)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
                              <button
                                onClick={() => handleDownloadPDF(fund, 'FUND')}
                                className="btn btn-primary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="Download Statement"
                              >
                                <FaDownload />
                              </button>
                              {(fund.status === 'PENDING' || fund.status === 'ALLOCATED') && (
                                <>
                                  <button
                                    onClick={() => handleEditFund(fund)}
                                    className="btn btn-warning"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Edit Allocation"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaEdit />}
                                  </button>
                                  <button
                                    onClick={() => handleDeleteFund(fund.id)}
                                    className="btn btn-danger"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Delete Allocation"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaTrash />}
                                  </button>
                                </>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                      {allocatedFundFilters.currentItems.length === 0 && (<tr><td colSpan="8" style={{ textAlign: 'center' }}>No allocated funds yet</td></tr>)}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={allocatedFundFilters.currentPage}
                  setCurrentPage={allocatedFundFilters.setCurrentPage}
                  totalPages={allocatedFundFilters.totalPages}
                  itemsPerPage={allocatedFundFilters.itemsPerPage}
                  setItemsPerPage={allocatedFundFilters.setItemsPerPage}
                />
              </div>
            )
          }

          {
            activeTab === 'received_funds' && (
              <div>

                <TableControls
                  searchTerm={receivedFundFilters.searchTerm}
                  setSearchTerm={receivedFundFilters.setSearchTerm}
                  startDate={receivedFundFilters.startDate}
                  setStartDate={receivedFundFilters.setStartDate}
                  endDate={receivedFundFilters.endDate}
                  setEndDate={receivedFundFilters.setEndDate}
                  onDownload={() => exportTableData(
                    receivedFundFilters.filteredData,
                    'Received Funds',
                    [
                      { header: 'ID', key: 'id' },
                      { header: 'Date', key: 'created_at', format: (v) => formatDate(v) },
                      { header: 'Allocated By', key: 'from_user_name' },
                      { header: 'Description', key: 'description' },
                      { header: 'Payment Mode', key: 'payment_mode' },
                      { header: 'Ref #', key: 'transaction_id', format: (v, item) => v || item.cheque_number || '-' },
                      { header: 'Status', key: 'status' },
                      { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') }
                    ]
                  )}
                  placeholder="Allocated By, Amount..."
                />
                <div className="table-responsive">
                  <table style={{ whiteSpace: 'nowrap' }}>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Allocated By</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Payment Mode</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {receivedFundFilters.currentItems.map(fund => (
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
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button
                                onClick={() => setViewFund(fund)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
                              <button
                                onClick={() => handleDownloadFund(fund)}
                                className="btn btn-primary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="Download Statement"
                              >
                                <FaDownload />
                              </button>
                              {fund.status === 'ALLOCATED' && (
                                <button
                                  onClick={() => handleConfirmFundReceipt(fund.id)}
                                  className="btn btn-success"
                                  style={{ padding: '0.4rem 0.8rem', fontSize: '0.85rem' }}
                                  disabled={isSubmitting}
                                >
                                  {isSubmitting ? <span className="btn-spinner"></span> : 'Confirm'}
                                </button>
                              )}
                              {fund.status === 'RECEIVED' && (() => {
                                const idMatch = fund.description?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
                                const expenseId = idMatch ? parseInt(idMatch[1]) : null;
                                const isAllocated = expenseId && expenses.some(e => e.id === expenseId && (e.status === 'FUND_ALLOCATED' || e.status === 'COMPLETED'));

                                if (isAllocated) return null;

                                return (
                                  <button
                                    onClick={() => handlePreFillFromReceived(fund)}
                                    className="btn"
                                    style={{
                                      padding: '6px 14px',
                                      fontSize: '0.85rem',
                                      color: 'white',
                                      background: 'linear-gradient(135deg, #6B73FF 0%, #000DFF 100%)',
                                      border: 'none',
                                      borderRadius: '20px',
                                      display: 'flex',
                                      alignItems: 'center',
                                      gap: '6px',
                                      boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
                                      fontWeight: '500',
                                      transition: 'all 0.3s ease'
                                    }}
                                    title="Allocate Fund"
                                  >
                                    <FaHandHoldingUsd /> Allocate
                                  </button>
                                );
                              })()}
                            </div>
                          </td>
                        </tr>
                      ))}
                      {receivedFundFilters.currentItems.length === 0 && (<tr><td colSpan="8" style={{ textAlign: 'center' }}>No funds received yet</td></tr>)}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={receivedFundFilters.currentPage}
                  setCurrentPage={receivedFundFilters.setCurrentPage}
                  totalPages={receivedFundFilters.totalPages}
                  itemsPerPage={receivedFundFilters.itemsPerPage}
                  setItemsPerPage={receivedFundFilters.setItemsPerPage}
                />
              </div>
            )
          }



          {
            activeTab === 'request_expansion' && (
              <div className="dashboard-creation-container">
                {/* Check if we are in an active expansion flow */}
                {(editingExpansion || searchParams.get('requestingExpansion') === 'true') ? (
                  <div className={`card ${isExpansionShaking ? 'shake' : ''}`}>
                    <form
                      onSubmit={editingExpansion ? handleUpdateExpansion : handleRequestExpansion}
                      style={{ marginBottom: '30px' }}
                      noValidate
                    >
                      {expansionFormErrors.form && (
                        <div className="alert alert-danger" style={{ marginBottom: '1.5rem', animation: 'slideDown 0.3s ease', display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.75rem', background: 'rgba(239, 68, 68, 0.1)', color: 'var(--danger-500)', borderRadius: '4px' }}>
                          <FaExclamationCircle /> {expansionFormErrors.form}
                        </div>
                      )}
                      <div className={`form-group ${expansionFormErrors.requested_amount ? 'shake' : ''}`}>
                        <label htmlFor="requested_amount">Requested Amount *</label>
                        <input
                          type="number"
                          id="requested_amount"
                          step="0.01"
                          value={expansionForm.requested_amount}
                          onChange={(e) => {
                            setExpansionForm({ ...expansionForm, requested_amount: e.target.value });
                            if (expansionFormErrors.requested_amount) setExpansionFormErrors({ ...expansionFormErrors, requested_amount: '' });
                          }}
                          className={expansionFormErrors.requested_amount ? 'is-invalid' : ''}
                          required
                          placeholder="0.00"
                        />
                        {expansionFormErrors.requested_amount && <span className="invalid-feedback">{expansionFormErrors.requested_amount}</span>}
                      </div>
                      <div className={`form-group ${expansionFormErrors.justification ? 'shake' : ''}`}>
                        <label htmlFor="justification">Justification *</label>
                        <textarea
                          id="justification"
                          value={expansionForm.justification}
                          onChange={(e) => {
                            setExpansionForm({ ...expansionForm, justification: e.target.value });
                            if (expansionFormErrors.justification) setExpansionFormErrors({ ...expansionFormErrors, justification: '' });
                          }}
                          className={expansionFormErrors.justification ? 'is-invalid' : ''}
                          required
                          placeholder="Why is this expansion needed?"
                        />
                        {expansionFormErrors.justification && <span className="invalid-feedback">{expansionFormErrors.justification}</span>}
                      </div>
                      <div style={{ display: 'flex', gap: '1rem' }}>
                        <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
                          {isSubmitting ? (
                            <>
                              <span className="btn-spinner"></span>
                              {editingExpansion ? 'Updating...' : 'Submitting...'}
                            </>
                          ) : (
                            editingExpansion ? 'Update Request' : 'Submit Request'
                          )}
                        </button>
                        <button
                          type="button"
                          onClick={() => {
                            setEditingExpansion(null);
                            setExpansionForm({ requested_amount: '', justification: '' });
                            setSearchParams(prev => {
                              const newParams = new URLSearchParams(prev);
                              newParams.delete('requestingExpansion');
                              newParams.delete('editExpansionId');
                              newParams.set('tab', 'expansion_history');
                              return newParams;
                            });
                          }}
                          className="btn btn-secondary"
                        >
                          Cancel
                        </button>
                      </div>
                    </form>
                  </div>
                ) : (
                  <div className="dashboard-empty-state">
                    <div className="dashboard-empty-icon" style={{ color: 'var(--accent-main)' }}>
                      <FaHourglassHalf />
                    </div>
                    <h3 className="dashboard-empty-title">Need an Expansion Fund?</h3>
                    <p className="dashboard-empty-text">
                      To request an expansion fund, please first click the <strong>'Request Expansion'</strong> button on an approved expense record from your <strong>Pending Approvals</strong> or <strong>Team Expenses</strong> lists.
                    </p>
                    <div className="dashboard-empty-actions">
                      <button onClick={() => setActiveTab('pending_approvals')} className="btn btn-primary">
                        View Pending Approvals
                      </button>
                      <button onClick={() => setActiveTab('team_expenses')} className="btn btn-secondary">
                        View Team Expenses
                      </button>
                    </div>
                  </div>


                )}

                <div className="side-recent">
                  <h4>Recent Expansion Requests</h4>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                    {expansionFunds.slice(0, 3).map(fund => (
                      <div key={fund.id} className="card" style={{ padding: '1rem', borderLeft: '4px solid var(--accent-main)' }}>
                        <div className="expense-details">
                          <div className="expense-title">Request from {fund.manager_name}</div>
                          <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{formatDate(fund.requested_at)}</div>
                        </div>
                        <div className="expense-status">
                          <StatusBadge status={fund.status} />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )
          }

          {
            activeTab === 'expansion_history' && (
              <div>
                <TableControls
                  searchTerm={expansionFilters.searchTerm}
                  setSearchTerm={expansionFilters.setSearchTerm}
                  startDate={expansionFilters.startDate}
                  setStartDate={expansionFilters.setStartDate}
                  endDate={expansionFilters.endDate}
                  setEndDate={expansionFilters.setEndDate}
                  onDownload={() => exportTableData(
                    expansionFilters.filteredData,
                    'Expansion Requests',
                    [
                      { header: 'ID', key: 'id' },
                      { header: 'Date', key: 'requested_at', format: (v) => formatDate(v) },
                      { header: 'Requester', key: 'manager_name' },
                      { header: 'Justification', key: 'justification', format: (v) => v || '-' },
                      { header: 'Requested', key: 'requested_amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') },
                      { header: 'Approved', key: 'approved_amount', format: (v) => v ? formatCurrency(v).replace('₹', 'Rs. ') : '-' },
                      { header: 'Status', key: 'status' }
                    ]
                  )}
                  placeholder="Status..."
                />
                <div className="table-responsive">
                  <table style={{ whiteSpace: 'nowrap' }}>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Requested Amount</th>
                        <th>Approved Amount</th>
                        <th>Justification</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {expansionFilters.currentItems.map(fund => (
                        <tr key={fund.id}>
                          <td>{fund.id}</td>
                          <td>{formatDate(fund.requested_at)}</td>
                          <td>{formatCurrency(fund.requested_amount)}</td>
                          <td>{fund.approved_amount ? formatCurrency(fund.approved_amount) : '-'}</td>
                          <td style={{ maxWidth: '200px' }}>
                            <div
                              style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '200px' }}
                              title={fund.justification || '-'}
                            >
                              {fund.justification}
                            </div>
                          </td>
                          <td>
                            <StatusBadge status={fund.status} />
                          </td>
                          <td>
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button
                                onClick={() => setViewExpansion(fund)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
                              <button
                                onClick={() => handleDownloadExpansion(fund)}
                                className="btn btn-primary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="Download Statement"
                              >
                                <FaDownload />
                              </button>

                              {(fund.status === 'PENDING' || fund.status === 'REJECTED') && (
                                <>
                                  <button
                                    onClick={() => handleEditExpansion(fund)}
                                    className="btn btn-warning"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Edit Request"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaEdit />}
                                  </button>
                                  <button
                                    onClick={() => handleDeleteExpansion(fund.id)}
                                    className="btn btn-danger"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Delete Request"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaTrash />}
                                  </button>
                                </>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                      {expansionFilters.currentItems.length === 0 && (<tr><td colSpan="7" style={{ textAlign: 'center' }}>No expansion fund requests</td></tr>)}
                    </tbody>
                  </table>
                </div>
                <TablePagination
                  currentPage={expansionFilters.currentPage}
                  setCurrentPage={expansionFilters.setCurrentPage}
                  totalPages={expansionFilters.totalPages}
                  itemsPerPage={expansionFilters.itemsPerPage}
                  setItemsPerPage={expansionFilters.setItemsPerPage}
                />
              </div>
            )
          }

          {
            activeTab === 'reports' && (
              <ReportsSection role="MANAGER" />
            )
          }
          {
            activeTab === 'profile' && (
              <ProfileSection />
            )
          }
        </div >
      </Layout >


      {
        viewExpense && (
          <InvoiceModal
            data={viewExpense}
            type="EXPENSE"
            onClose={closeModal}
            onDownload={(expense) => handleDownloadPDF(expense, 'EXPENSE')}
          />
        )
      }

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

      {
        viewExpansion && (
          <InvoiceModal
            data={viewExpansion}
            type="EXPANSION"
            onClose={closeModal}
            onDownload={(fund) => handleDownloadExpansion(fund)}
          />
        )
      }



    </>
  );
};

export default ManagerDashboard;

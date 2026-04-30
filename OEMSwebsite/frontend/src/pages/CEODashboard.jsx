import React, { useState, useEffect, useCallback, useMemo, useRef } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import Layout from '../components/Layout';
import { useAuth } from '../context/AuthContext';
import { useSocket } from '../context/SocketContext';
import { useSettings } from '../context/SettingsContext';
import {
  getPendingUsers,
  approveUser,
  getManagers,
  allocateOperationalFund,
  requestExpansionFund,
  getExpansionFunds,
  reviewExpansionFund,
  getExpenses,
  approveExpense,
  rejectExpense,
  getDashboardStats,
  getExpenseReports,
  assignManager,
  getOperationalFunds,
  getExpenseById,

  getAllUsers,
  updateExpense,
  updateExpenseStatus,
  deleteExpense,
  updateFund,
  deleteFund,
  updateExpansionFund,
  deleteExpansionFund
} from '../services/api';
import { generateProfessionalPDF, generateUserPDF, generateFundPDF, generateExpansionPDF, generateExpensePDF } from '../utils/pdfGenerator';
import ReportsSection from '../components/ReportsSection';
import DashboardCharts from '../components/DashboardCharts';
import AllocationUsage from '../components/AllocationUsage';
import AllocationForm from '../components/AllocationForm';
import ProfileSection from '../components/ProfileSection';
import { EXPENSE_CATEGORIES } from '../utils/constants';
import { FaTachometerAlt, FaChartPie, FaChartLine, FaUsers, FaUserPlus, FaMoneyBillWave, FaFileInvoiceDollar, FaCheckCircle, FaTimesCircle, FaDownload, FaEye, FaUserCheck, FaWallet, FaHandHoldingUsd, FaChartBar, FaUser, FaExclamationTriangle, FaFilePdf, FaArrowLeft, FaPlus, FaListUl, FaClock, FaHistory, FaFileAlt, FaCloudUploadAlt, FaHourglassHalf, FaUsersCog, FaClipboardCheck, FaFileContract, FaPlusCircle, FaEdit, FaTrash, FaCheck, FaTimes, FaUserTie, FaCog, FaSpinner } from 'react-icons/fa';
import Toast from '../components/Toast';
import StatusBadge from '../components/StatusBadge';
import * as XLSX from 'xlsx';

import { useTableFilters } from '../hooks/useTableFilters';
import TableControls from '../components/TableControls';
import TablePagination from '../components/TablePagination';
import DocumentList from '../components/DocumentList';
import InvoiceModal from '../components/InvoiceModal';
import { handleViewDocument, handleDownloadPDF, handleDownloadDocument } from '../utils/documentHandlers';


/**
 * CEODashboard Component
 * Main interface for CEO users. Provides oversight of users, expenses, and fund allocations.
 */
export default function CEODashboard() {
  const { user } = useAuth();
  const socket = useSocket();
  const { formatCurrencyValue } = useSettings();
  const navigate = useNavigate();
  const isInitialMount = useRef(true);
  const [searchParams, setSearchParams] = useSearchParams();
  const activeTab = searchParams.get('tab') || 'dashboard';
  /**
   * Tab and Navigation State Management
   */
  const setActiveTab = (tab) => {
    if (tab === 'settings') {
      navigate('/settings');
      return;
    }
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', tab);
      // Clear sticky action/edit params when switching tabs via sidebar
      newParams.delete('editAllocId');
      newParams.delete('editExpenseId');
      newParams.delete('editExpansionId');
      newParams.delete('allocateUserId');
      newParams.delete('allocateAmount');
      newParams.delete('allocateDesc');
      newParams.delete('allocatingExpenseId');
      newParams.delete('allocatingExpansionId');
      newParams.delete('allocatingExpansionId');
      return newParams;
    }); // Changed from replace: true to push

    // Reset local UI and Form states
    setEditingFund(null);
    setEditingExpense(null);
    setEditingExpansion(null);
    setAllocatingExpenseId(null);
    setAllocatingExpansionId(null);

    setFundForm({
      to_user_id: '',
      amount: '',
      description: '',
      payment_mode: 'CASH',
      expansion_id: null,
      cheque_number: '',
      bank_name: '',
      cheque_date: '',
      account_holder_name: '',
      upi_id: '',
      transaction_id: ''
    });

    setSuccess('');
    setError('');
  };
  const [pendingUsers, setPendingUsers] = useState([]);
  const [allUsers, setAllUsers] = useState([]);
  const [managers, setManagers] = useState([]);
  const [expansionFunds, setExpansionFunds] = useState([]);
  const [allocationHistory, setAllocationHistory] = useState([]);
  const [expenses, setExpenses] = useState([]);
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [allocatingExpenseId, setAllocatingExpenseId] = useState(null);
  const [allocatingExpansionId, setAllocatingExpansionId] = useState(null);
  const [approvedExpenseIds, setApprovedExpenseIds] = useState([]);

  // Form states
  const [fundForm, setFundForm] = useState({
    to_user_id: '',
    amount: '',
    description: '',
    payment_mode: 'CASH',
    expansion_id: null,
    cheque_number: '',
    bank_name: '',
    cheque_date: '',
    account_holder_name: '',
    upi_id: '',
    transaction_id: ''
  });

  // Validation & Animation States
  const [expenseFormErrors, setExpenseFormErrors] = useState({});
  const [expansionFormErrors, setExpansionFormErrors] = useState({});
  const [isExpenseShaking, setIsExpenseShaking] = useState(false);
  const [isExpansionShaking, setIsExpansionShaking] = useState(false);

  const triggerExpenseShake = () => {
    setIsExpenseShaking(true);
    setTimeout(() => setIsExpenseShaking(false), 500);
  };

  const triggerExpansionShake = () => {
    setIsExpansionShaking(true);
    setTimeout(() => setIsExpansionShaking(false), 500);
  };

  const validateExpenseForm = (data) => {
    const errors = {};
    if (!data.title?.trim()) errors.title = 'Title is required';
    if (!data.category) errors.category = 'Category is required';
    if (data.category === 'Other' && !data.customCategory?.trim()) errors.customCategory = 'Please specify category';
    if (!data.department) errors.department = 'Department is required';
    if (!data.amount || parseFloat(data.amount) <= 0) errors.amount = 'Amount must be greater than 0';
    if (!data.expense_date) errors.expense_date = 'Date is required';

    setExpenseFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const validateExpansionForm = (data) => {
    const errors = {};
    if (!data.requested_amount || parseFloat(data.requested_amount) <= 0) errors.requested_amount = 'Amount must be greater than 0';
    if (!data.justification?.trim()) errors.justification = 'Justification is required';

    setExpansionFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const [viewExpense, setViewExpense] = useState(null);
  const [viewExpansion, setViewExpansion] = useState(null);
  const [viewFund, setViewFund] = useState(null);
  const [viewUserInfo, setViewUserInfo] = useState(null);

  const [endDate, setEndDate] = useState('');

  // Edit States
  const [editingExpense, setEditingExpense] = useState(null);
  const [editingFund, setEditingFund] = useState(null);
  const [editingExpansion, setEditingExpansion] = useState(null);

  // Table Filters Hooks
  const registrationFilters = useTableFilters(
    allUsers,
    ['full_name', 'email', 'role', 'mobile_number', 'id'],
    'created_at'
  );

  const expenseFilters = useTableFilters(
    expenses,
    ['title', 'category', 'amount', 'status'],
    'expense_date'
  );



  const handleBack = () => {
    if (activeTab === 'dashboard') {
      window.history.back();
    } else {
      setActiveTab('dashboard');
    }
  };

  // URL Persistence Effect
  useEffect(() => {
    // 1. Handle Edit Allocation Persistence
    const editAllocId = searchParams.get('editAllocId');
    const allocateUserId = searchParams.get('allocateUserId');
    const allocateAmount = searchParams.get('allocateAmount');
    const allocateDesc = searchParams.get('allocateDesc');
    const allocExpId = searchParams.get('allocatingExpenseId');
    const allocExpansionId = searchParams.get('allocatingExpansionId');

    if (editAllocId && allocationHistory.length > 0 && !editingFund) {
      const fundToEdit = allocationHistory.find(f => f.id.toString() === editAllocId);
      if (fundToEdit) {
        handleEditAllocation(fundToEdit);
      }
    } else if (allocateUserId && allocateAmount && !editingFund) {
      // Handle New Allocation Persistence
      setFundForm(prev => ({
        ...prev,
        to_user_id: allocateUserId,
        amount: allocateAmount,
        description: allocateDesc || '',
        expansion_id: allocExpansionId || null
      }));
      if (allocExpId) {
        setAllocatingExpenseId(parseInt(allocExpId));
      }
    }

    // 2. Handle Edit Expense Persistence
    const editExpId = searchParams.get('editExpenseId');
    if (editExpId && expenses.length > 0 && !editingExpense) {
      const exp = expenses.find(e => e.id.toString() === editExpId);
      if (exp) {
        handleEditExpense(exp);
      }
    }

    // 3. Handle Edit Expansion Persistence
    const editExpnId = searchParams.get('editExpansionId');
    if (editExpnId && expansionFunds.length > 0 && !editingExpansion) {
      const expn = expansionFunds.find(e => e.id.toString() === editExpnId);
      if (expn) {
        handleEditExpansion(expn);
      }
    }

    // Clear state if tab changes and params are missing
    if (activeTab !== 'allocate_fund' && !editAllocId && !allocateUserId) {
      setEditingFund(null);
      // Don't clear form if fresh allocation
    }
  }, [activeTab, searchParams, allocationHistory, expenses, expansionFunds]);

  // Real-time Update Effect
  useEffect(() => {
    if (socket) {
      const handleUpdate = () => {
        console.log('Real-time update received, refetching CEO data (silent)...');
        loadDashboardData(true);
      };

      socket.on('expenseUpdated', handleUpdate);
      socket.on('fundUpdated', handleUpdate);
      socket.on('expansionUpdated', handleUpdate);
      socket.on('notificationReceived', handleUpdate);
      socket.on('userUpdated', handleUpdate);

      return () => {
        socket.off('expenseUpdated', handleUpdate);
        socket.off('fundUpdated', handleUpdate);
        socket.off('expansionUpdated', handleUpdate);
        socket.off('notificationReceived', handleUpdate);
        socket.off('userUpdated', handleUpdate);
      };
    }
  }, [socket]);

  const pendingUserFilters = useTableFilters(
    pendingUsers,
    ['full_name', 'email', 'mobile_number'],
    'created_at'
  );

  const approvedUsersOnly = allUsers.filter(u => u.role === 'USER' && u.status === 'APPROVED');

  const allUserFilters = useTableFilters(
    approvedUsersOnly,
    ['full_name', 'email', 'role', 'mobile_number'],
    'created_at'
  );

  const fundFilters = useTableFilters(
    allocationHistory,
    ['to_user_name', 'amount', 'payment_mode', 'status'],
    'created_at'
  );

  const expansionFilters = useTableFilters(
    expansionFunds,
    ['manager_name', 'requested_amount', 'justification', 'status'],
    'requested_at'
  );

  const ownExpenses = expenses.filter(e => e.user_id === user?.id);
  // Show expenses that are either PENDING_APPROVAL or RECEIPT_APPROVED, but exclude regular USER expenses (handled by Managers)
  const pendingExpenses = expenses.filter(e => (e.status === 'PENDING_APPROVAL' || e.status === 'RECEIPT_APPROVED') && e.user_role !== 'USER');

  const ownExpenseFilters = useTableFilters(
    ownExpenses,
    ['title', 'category', 'amount', 'status'],
    'expense_date'
  );

  const pendingExpenseFilters = useTableFilters(
    pendingExpenses,
    ['title', 'category', 'amount', 'status', 'full_name'],
    'expense_date'
  );

  const formatCurrency = (amount) => formatCurrencyValue(amount);

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('en-GB').replace(/\//g, '-');
  };

  const exportTableData = (data, title, columns) => {
    generateProfessionalPDF(title, columns, data);
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



  /**
   * Data Loading Lifecycle
   * Fetches dashboard statistics, expenses, and tab-specific data.
   */
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

      if (activeTab === 'users_root' || activeTab === 'pending_users' || activeTab === 'all_users' || activeTab === 'registration_history') {
        const [pendingRes, allUsersRes, managersRes] = await Promise.all([
          getPendingUsers(),
          getAllUsers(),
          getManagers()
        ]);
        setPendingUsers(pendingRes.data.users || []);
        setAllUsers(allUsersRes.data.users || []);
        setManagers(managersRes.data.managers || []);
      }

      if (activeTab === 'funds' || activeTab === 'fund_history' || activeTab === 'allocate_fund' || activeTab === 'expansion_requests') {
        const [fundsRes, expansionRes] = await Promise.all([
          getOperationalFunds(),
          getExpansionFunds()
        ]);
        setAllocationHistory(fundsRes.data.funds);
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
      }

      if (activeTab === 'funds' || activeTab === 'allocate_fund' || activeTab === 'fund_history') {
        const [managersRes, fundsRes] = await Promise.all([
          getManagers(),
          getOperationalFunds()
        ]);
        setManagers(managersRes.data.managers || []);
        // Filter to show only funds allocated BY the CEO (current user)
        const allFunds = fundsRes.data.funds || [];
        setAllocationHistory(allFunds.filter(f => f.from_user_id === user?.id));
      }
      if (activeTab === 'expansion' || activeTab === 'review_expansion' || activeTab === 'expansion_history') {
        const res = await getExpansionFunds();
        setExpansionFunds(res.data.funds);
      }
    } catch (err) {
      setError('Failed to load data');
    }
    setLoading(false);
  };

  const handleToggleStatus = async (user) => {
    const newAction = user.status === 'APPROVED' ? 'DEACTIVATE' : 'ACTIVATE';
    const confirmMessage = user.status === 'APPROVED'
      ? `Are you sure you want to deactivate ${user.full_name}?`
      : `Are you sure you want to activate ${user.full_name}?`;

    if (window.confirm(confirmMessage)) {
      try {
        setIsSubmitting(true);
        await approveUser(user.id, newAction);
        setSuccess(`User status updated to ${newAction === 'ACTIVATE' ? 'Active' : 'Inactive'}`);
        loadDashboardData(true);
      } catch (err) {
        setError('Failed to update user status');
      } finally {
        setIsSubmitting(false);
      }
    }
  };

  const handleApproveUser = async (id, action) => {
    try {
      setIsSubmitting(true);
      await approveUser(id, action);
      setSuccess(`User ${action.toLowerCase()}d successfully`);
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to update user status');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleAssignManager = async (userId, managerId) => {
    try {
      setIsSubmitting(true);
      await assignManager(userId, managerId);
      setSuccess(managerId ? 'Manager assigned successfully' : 'User unassigned successfully');
      loadDashboardData(true);
    } catch (err) {
      setError('Failed to assign manager');
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

  const handleDownloadExpansion = (fund) => {
    generateExpansionPDF(fund);
  };

  const handleDownloadUserPDF = async (user) => {
    try {
      generateUserPDF(user);
    } catch (error) {
      console.error('Error generating PDF:', error);
      alert('Failed to generate PDF');
    }
  };

  const handleDownloadRegistrationHistory = (filteredData) => {
    const title = 'Registration History Report';
    const columns = [
      { header: 'Joined Date', key: 'created_at', format: (v) => formatDate(v) },
      { header: 'ID', key: 'id' },
      { header: 'Name', key: 'full_name' },
      { header: 'Email', key: 'email' },
      { header: 'Mobile', key: 'mobile_number', format: (v) => v || '-' },
      { header: 'Manager', key: 'manager_name', format: (v) => v || '-' },
      { header: 'Role', key: 'role' },
      { header: 'Status', key: 'status' }
    ];

    generateProfessionalPDF(title, columns, filteredData);
  };

  /* Allocation Logic */
  const handleAllocateFund = async (formData) => {
    // formData is passed from AllocationForm (FormData object)
    try {
      setIsSubmitting(true);
      setError('');
      setSuccess('');

      const response = await allocateOperationalFund(formData);
      setSuccess('Fund allocated successfully!');
      await loadDashboardData(true);

      // Clear form and internal state immediately
      setFundForm({
        to_user_id: '',
        amount: '',
        description: '',
        payment_mode: 'CASH',
        expansion_id: null,
        cheque_number: '',
        bank_name: '',
        cheque_date: '',
        account_holder_name: '',
        upi_id: '',
        transaction_id: ''
      });
      setAllocatingExpenseId(null);
      setAllocatingExpansionId(null);
      setEditingFund(null);

      // Clear URL pre-fill params IMMEDIATELY to prevent useEffect from re-populating
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('allocateUserId');
        newParams.delete('allocateAmount');
        newParams.delete('allocateDesc');
        newParams.delete('allocatingExpenseId');
        newParams.delete('allocatingExpansionId');
        newParams.delete('editAllocId');
        return newParams;
      }, { replace: true });

      // We keep replace: true here because this is a redirect after success, 
      // not a user navigation we want in history stack? 
      // Actually giving it history is fine, but usually redirects replace.
      // Keeping it as is for form submission flow.

      // Redirect tab after a short delay so user sees success message on current page
      setTimeout(() => {
        setSearchParams(prev => {
          const newParams = new URLSearchParams(prev);
          newParams.set('tab', 'fund_history');
          return newParams;
        }, { replace: true });
      }, 1500);
    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || 'Failed to allocate fund');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleReviewExpansion = async (id, action, amount = null) => {
    try {
      setIsSubmitting(true);
      await reviewExpansionFund(id, {
        action,
        approved_amount: amount
      });
      setSuccess(`Expansion fund request ${action.toLowerCase()}d`);
      loadDashboardData(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to review expansion fund');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleApproveExpansion = async (fund) => {
    try {
      setIsSubmitting(true);
      await reviewExpansionFund(fund.id, {
        action: 'APPROVE',
        approved_amount: fund.requested_amount
      });
      setSuccess('Expansion request approved. You can now allocate funds.');

      await loadDashboardData(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to approve expansion fund');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleRejectExpansion = async (id) => {
    const reason = prompt('Please enter rejection reason:');
    if (!reason) return; // Require a reason for rejection
    try {
      setIsSubmitting(true);
      await reviewExpansionFund(id, {
        action: 'REJECT',
        rejection_reason: reason
      });
      setSuccess('Expansion fund request rejected');
      loadDashboardData(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to reject expansion fund');
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



  const handleApproveExpense = async (expense) => {
    try {
      setIsSubmitting(true);
      await approveExpense(expense.id);
      setSuccess('Expense approved. You can now allocate funds.');
      // Update local state to reflect change immediately
      setExpenses(prev => prev.map(e => e.id === expense.id ? { ...e, status: 'RECEIPT_APPROVED' } : e));
      await loadDashboardData(true); // Refresh to ensure sync
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

  // Edit/Delete Handlers

  const handleEditExpense = (expense) => {
    const isCustomCategory = expense.category && !EXPENSE_CATEGORIES.includes(expense.category);
    setEditingExpense({
      ...expense,
      category: isCustomCategory ? 'Other' : expense.category,
      customCategory: isCustomCategory ? expense.category : ''
    });
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('editExpenseId', expense.id);
      return newParams;
    });
  };

  const handleUpdateExpense = async (e) => {
    e.preventDefault();
    setExpenseFormErrors({});
    if (!validateExpenseForm(editingExpense)) {
      triggerExpenseShake();
      return;
    }

    const finalCategory = editingExpense.category === 'Other' ? editingExpense.customCategory : editingExpense.category;

    try {
      setIsSubmitting(true);
      await updateExpense(editingExpense.id, { ...editingExpense, category: finalCategory });
      setSuccess('Expense updated successfully');
      setEditingExpense(null);
      setExpenseFormErrors({});
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('editExpenseId');
        return newParams;
      });
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
      setError(err.response?.data?.message || 'Failed to delete expense');
    }
  };

  const handleEditAllocation = (fund) => {
    setEditingFund(fund);
    setFundForm({
      to_user_id: fund.to_user_id || fund.manager_id,
      amount: fund.amount,
      description: fund.description || '',
      payment_mode: fund.payment_mode || 'CASH',
      cheque_number: fund.cheque_number || '',
      bank_name: fund.bank_name || '',
      cheque_date: fund.cheque_date ? fund.cheque_date.split('T')[0] : '', // Format date for input
      account_holder_name: fund.account_holder_name || '',
      upi_id: fund.upi_id || '',
      transaction_id: fund.transaction_id || ''
    });
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'allocate_fund');
      newParams.set('editAllocId', fund.id);
      return newParams;
    });
  };

  const handleUpdateAllocation = async (formData) => {
    try {
      setIsSubmitting(true);
      await updateFund(editingFund.id, formData);
      setSuccess('Allocation updated successfully');
      setEditingFund(null);
      setFundForm({
        to_user_id: '',
        amount: '',
        description: '',
        payment_mode: 'CASH',
        expansion_id: null,
        cheque_number: '',
        bank_name: '',
        cheque_date: '',
        account_holder_name: '',
        upi_id: '',
        transaction_id: ''
      });
      await loadDashboardData(true);

      // Clear Context IMMEDIATELY
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('editAllocId');
        return newParams;
      }, { replace: true });

      setTimeout(() => {
        setSearchParams(prev => {
          const newParams = new URLSearchParams(prev);
          newParams.set('tab', 'fund_history');
          return newParams;
        }, { replace: true });
      }, 1500);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to update fund');
    } finally {
      setIsSubmitting(false);
    }
  };


  const handleDeleteAllocation = async (id) => {
    if (!window.confirm('Are you sure you want to delete this allocation?')) return;
    try {
      await deleteFund(id);
      setSuccess('Allocation deleted successfully');
      loadDashboardData(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to delete allocation');
    }
  };

  const handleEditExpansion = (fund) => {
    setEditingExpansion(fund);
    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('editExpansionId', fund.id);
      return newParams;
    });
  };

  const handleUpdateExpansion = async (e) => {
    e.preventDefault();
    setExpansionFormErrors({});
    if (!validateExpansionForm(editingExpansion)) {
      triggerExpansionShake();
      return;
    }
    try {
      setIsSubmitting(true);
      await updateExpansionFund(editingExpansion.id, editingExpansion);
      setSuccess('Expansion request updated successfully');
      setEditingExpansion(null);
      setExpansionFormErrors({});
      setSearchParams(prev => {
        const newParams = new URLSearchParams(prev);
        newParams.delete('editExpansionId');
        return newParams;
      });
      loadDashboardData(true);
    } catch (err) {
      setExpansionFormErrors({ form: err.response?.data?.message || 'Failed to update expansion request' });
      triggerExpansionShake();
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteExpansion = async (id) => {
    if (!window.confirm('Are you sure you want to delete this expansion request?')) return;
    try {
      await deleteExpansionFund(id);
      setSuccess('Expansion request deleted successfully');
      loadDashboardData(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to delete expansion request');
    }
  };

  const closeModal = () => {
    setViewExpense(null);
    setViewExpansion(null);
    setViewFund(null);
    setViewUserInfo(null);
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
      'Approved By': item.approved_by_name || '-',
      Description: item.description || ''
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



  const tabs = [
    { id: 'dashboard', label: 'Dashboard', icon: <FaTachometerAlt /> },
    { id: 'allocation', label: 'Allocation & Usage', icon: <FaChartPie /> },
    {
      id: 'expenses_root',
      label: 'Expenses',
      icon: <FaFileInvoiceDollar />,
      subItems: [
        { id: 'pending_approvals', label: 'Pending Approvals', icon: <FaHourglassHalf /> },
        { id: 'all_expenses', label: 'All Expenses', icon: <FaUsersCog /> }
      ]
    },
    {
      id: 'users_root',
      label: 'User Approvals',
      icon: <FaUserCheck />,
      subItems: [
        { id: 'pending_users', label: 'Pending Approvals', icon: <FaUserCheck /> },
        { id: 'all_users', label: 'User Assignment', icon: <FaUsers /> },
        { id: 'registration_history', label: 'Registration History', icon: <FaHistory /> }
      ]
    },
    {
      id: 'funds_root',
      label: 'Fund Allocation',
      icon: <FaWallet />,
      subItems: [
        { id: 'allocate_fund', label: 'Allocate Fund', icon: <FaHandHoldingUsd /> },
        { id: 'fund_history', label: 'Allocation History', icon: <FaHistory /> }
      ]
    },
    {
      id: 'expansion_root',
      label: 'Expansion Fund',
      icon: <FaChartBar />,
      subItems: [
        { id: 'review_expansion', label: 'Review Requests', icon: <FaHourglassHalf /> },
        { id: 'expansion_history', label: 'History & Logs', icon: <FaHistory /> }
      ]
    },
    { id: 'reports', label: 'Finance Reports', icon: <FaChartLine /> },
    { id: 'settings', label: 'Settings', icon: <FaCog /> }
  ];


  const handlePreFillAllocation = (fund) => {
    setFundForm({
      to_user_id: fund.manager_id,
      amount: fund.approved_amount || fund.requested_amount,
      description: `Allocation for Expansion Request #${fund.id} - ${fund.justification || ''}`,
      payment_mode: 'CASH',
      expansion_id: fund.id
    });
    setAllocatingExpansionId(fund.id);
    setEditingFund(null); // Clear editing state when starting fresh allocation

    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'allocate_fund');
      newParams.set('allocateUserId', fund.manager_id);
      newParams.set('allocateAmount', fund.approved_amount || fund.requested_amount);
      newParams.set('allocateDesc', `Allocation for Expansion Request #${fund.id} - ${fund.justification || ''}`);
      newParams.set('allocatingExpansionId', fund.id);
      return newParams;
    });
    // setActiveTab('allocate_fund'); // redundant with searchParams update
  };

  const handlePreFillAllocationWithExpense = (expense) => {
    setFundForm({
      to_user_id: expense.user_id,
      amount: expense.amount,
      description: `Allocation for Expense #${expense.id} - ${expense.title}`,
      payment_mode: 'CASH',
      expansion_id: null
    });
    setAllocatingExpenseId(expense.id);
    setEditingFund(null);

    setSearchParams(prev => {
      const newParams = new URLSearchParams(prev);
      newParams.set('tab', 'allocate_fund');
      newParams.set('allocateUserId', expense.user_id);
      newParams.set('allocateAmount', expense.amount);
      newParams.set('allocateDesc', `Allocation for Expense #${expense.id} - ${expense.title}`);
      newParams.set('allocatingExpenseId', expense.id);
      return newParams;
    });
  };

  const getPageTitle = () => {
    switch (activeTab) {
      case 'dashboard': return 'Dashboard Overview';
      case 'allocation': return 'Allocation & Usage Overview';
      case 'pending_approvals': return 'Pending Approvals';
      case 'all_expenses': return 'All Expenses';
      case 'pending_users': return 'Pending User Approvals';
      case 'all_users': return 'User Assignment';
      case 'registration_history': return 'Users and Managers Registration History';
      case 'allocate_fund': return editingFund ? 'Edit Allocate Fund to Manager' : 'Allocate Funds to Manager';
      case 'fund_history': return 'Fund Allocation History';
      case 'review_expansion': return 'Pending Expansion Requests';
      case 'expansion_history': return 'Expansion Fund History';
      case 'reports': return 'Reports';
      case 'profile': return 'My Profile';
      default: return 'Dashboard';
    }
  };

  return (
    <>
      <Layout
        title="CEO Dashboard"
        menuItems={tabs}
        activeItem={activeTab}
        onMenuItemClick={setActiveTab}
      >
        {(success || error) && (
          <Toast
            message={success || error}
            type={success ? 'success' : 'error'}
            onClose={() => { setSuccess(''); setError(''); }}
          />
        )}
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
                {/* Card 1: Total Allocated Funds (Outflow) */}
                <div className="card stat-card info">
                  <div className="stat-icon-wrapper"><FaWallet /></div>
                  <div>
                    <span className="stat-label">Total Allocated Funds</span>
                    <span className="stat-value">
                      {formatCurrency(stats.allocatedFunds?.filter(f => f.status !== 'REJECTED').reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) || 0)}
                    </span>
                  </div>
                </div>

                {/* Card 2: Total Organization Expenses */}
                {stats.expenses && (
                  <div className="card stat-card warning">
                    <div className="stat-icon-wrapper"><FaMoneyBillWave /></div>
                    <div>
                      <span className="stat-label">Total Organization Expenses</span>
                      <span className="stat-value">
                        {formatCurrency(stats.expenses.reduce((sum, e) => sum + (parseFloat(e.total_amount) || 0), 0))}
                      </span>
                    </div>
                  </div>
                )}

                {/* Card 3: Outstanding Balance (Allocated - Expenses) */}
                <div className="card stat-card success">
                  <div className="stat-icon-wrapper"><FaChartBar /></div>
                  <div>
                    <span className="stat-label">Organization Outstanding Balance</span>
                    <span className="stat-value">
                      {formatCurrency((stats.allocatedFunds?.filter(f => f.status !== 'REJECTED').reduce((sum, f) => sum + (parseFloat(f.total_amount) || 0), 0) || 0)
                        - (stats.expenses?.filter(e => e.status !== 'REJECTED').reduce((sum, e) => sum + (parseFloat(e.total_amount) || 0), 0) || 0)
                      )}
                    </span>
                  </div>
                </div>

                <div className="card stat-card primary">
                  <div className="stat-icon-wrapper"><FaUserCheck /></div>
                  <div>
                    <span className="stat-label">Pending User Approvals</span>
                    <span className="stat-value">{stats.pendingUsers || 0}</span>
                  </div>
                </div>
                <div className="card stat-card warning">
                  <div className="stat-icon-wrapper"><FaExclamationTriangle /></div>
                  <div>
                    <span className="stat-label">Pending Expansion Requests</span>
                    <span className="stat-value">{stats.pendingExpansionRequests || 0}</span>
                  </div>
                </div>
              </div>

              {/* Charts Section */}
              <DashboardCharts expenses={expenses} stats={stats} />
            </div>
          )}

          {activeTab === 'allocation' && (
            <AllocationUsage />
          )}



          {activeTab === 'pending_approvals' && (
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                {/* Title removed */}
              </div>
              <TableControls
                searchTerm={pendingExpenseFilters.searchTerm}
                setSearchTerm={pendingExpenseFilters.setSearchTerm}
                startDate={pendingExpenseFilters.startDate}
                setStartDate={pendingExpenseFilters.setStartDate}
                endDate={pendingExpenseFilters.endDate}
                setEndDate={pendingExpenseFilters.setEndDate}
                onDownload={() => exportTableData(
                  pendingExpenseFilters.filteredData,
                  'Pending Approvals',
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
                    {pendingExpenseFilters.currentItems.map(expense => (
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
                          <div style={{ display: 'flex', gap: '8px' }}>
                            <button onClick={() => handleViewExpense(expense)} className="btn btn-secondary" style={{ padding: '0.4rem', borderRadius: '50%' }} title="View Details"><FaEye /></button>
                            {expense.document_path && (
                              <button
                                onClick={() => handleViewDocument(expense.document_path)}
                                className="btn btn-info"
                                style={{ padding: '0.4rem', borderRadius: '50%', background: '#0dcaf0', color: 'white', border: 'none' }}
                                title="View Voucher"
                              >
                                <FaFileAlt />
                              </button>
                            )}
                            <button onClick={() => handleDownloadExpenseStatement(expense)} className="btn btn-primary" style={{ padding: '0.4rem', borderRadius: '50%' }} title="Download Invoice"><FaDownload /></button>
                            {expense.status === 'PENDING_APPROVAL' && (
                              <div style={{ display: 'flex', gap: '8px' }}>
                                <button
                                  onClick={() => handleApproveExpense(expense)}
                                  className="btn btn-success"
                                  style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                  title="Approve"
                                  disabled={isSubmitting}
                                >
                                  {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaCheck />}
                                </button>
                                <button
                                  onClick={() => handleRejectExpense(expense.id)}
                                  className="btn btn-danger"
                                  style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                  title="Reject"
                                  disabled={isSubmitting}
                                >
                                  {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaTimes />}
                                </button>
                              </div>
                            )}
                            {expense.status === 'RECEIPT_APPROVED' && (
                              <button
                                onClick={() => handlePreFillAllocationWithExpense(expense)}
                                className="btn"
                                style={{
                                  padding: '0.4rem 0.8rem',
                                  fontSize: '0.85rem',
                                  color: 'white',
                                  background: 'linear-gradient(135deg, #6B73FF 0%, #000DFF 100%)',
                                  border: 'none',
                                  borderRadius: '20px',
                                  display: 'flex',
                                  alignItems: 'center',
                                  gap: '6px'
                                }}
                                title="Allocate Fund"
                              >
                                <FaHandHoldingUsd /> Allocate
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                    {pendingExpenseFilters.currentItems.length === 0 && (<tr><td colSpan="8" style={{ textAlign: 'center' }}>No pending expenses</td></tr>)}
                  </tbody>
                </table>
              </div>
              <TablePagination
                currentPage={pendingExpenseFilters.currentPage}
                setCurrentPage={pendingExpenseFilters.setCurrentPage}
                totalPages={pendingExpenseFilters.totalPages}
                itemsPerPage={pendingExpenseFilters.itemsPerPage}
                setItemsPerPage={pendingExpenseFilters.setItemsPerPage}
              />
            </div>
          )}

          {activeTab === 'all_expenses' && (
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
                  'All Expenses',
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
                placeholder="Title, Category, Amount..."
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
                      <th>Approved By</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {expenseFilters.currentItems.length > 0 ? (
                      expenseFilters.currentItems.map(expense => (
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
                                  onClick={() => handleViewDocument(expense.document_path)}
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
                                title="Download Statement"
                              >
                                <FaDownload />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan="9" style={{ textAlign: 'center', padding: '1rem' }}>No expenses found</td>
                      </tr>
                    )}
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
            </div>
          )}

          {activeTab === 'pending_users' && (
            <div>
              {/* Title removed */}
              <TableControls
                searchTerm={pendingUserFilters.searchTerm}
                setSearchTerm={pendingUserFilters.setSearchTerm}
                startDate={pendingUserFilters.startDate}
                setStartDate={pendingUserFilters.setStartDate}
                endDate={pendingUserFilters.endDate}
                setEndDate={pendingUserFilters.setEndDate}
                onDownload={() => exportTableData(
                  pendingUserFilters.filteredData,
                  'Pending User Approvals',
                  [
                    { header: 'ID', key: 'id' },
                    { header: 'Date', key: 'created_at', format: (v) => formatDate(v) },
                    { header: 'Name', key: 'full_name' },
                    { header: 'Email', key: 'email' },
                    { header: 'Mobile', key: 'mobile_number', format: (v) => v || '-' },
                    { header: 'Role', key: 'role' },
                    { header: 'Status', key: 'status' }
                  ]
                )}
                placeholder="Name, Email..."
              />
              <div className="table-responsive">
                <table style={{ whiteSpace: 'nowrap' }}>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Name</th>
                      <th>Email</th>
                      <th>Role</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {pendingUserFilters.currentItems.map(u => (
                      <tr key={u.id}>
                        <td>{u.id}</td>
                        <td>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                            {u.profile_image ? (
                              <div style={{ width: '26px', height: '26px', borderRadius: '50%', overflow: 'hidden', border: '1px solid var(--border-light)', flexShrink: 0 }}>
                                <img
                                  src={`https://oems-backend.vercel.app${u.profile_image.startsWith('/') ? '' : '/'}${u.profile_image.replace(/\\/g, '/')}`}
                                  alt={u.full_name}
                                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                                  onError={(e) => {
                                    e.target.style.display = 'none';
                                    e.target.parentElement.innerHTML = `<div style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: var(--secondary-100); color: var(--primary-500); font-size: 11px; font-weight: bold;">${u.full_name.charAt(0).toUpperCase()}</div>`;
                                  }}
                                />
                              </div>
                            ) : (
                              <div style={{ width: '26px', height: '26px', borderRadius: '50%', background: 'var(--secondary-100)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary-500)', fontSize: '11px', fontWeight: 'bold', border: '1px solid var(--border-light)', flexShrink: 0 }}>
                                {u.full_name.charAt(0).toUpperCase()}
                              </div>
                            )}
                            <div>
                              <div style={{ fontWeight: '600', color: 'var(--text-main)', fontSize: '0.85rem', lineHeight: '1.2' }}>{u.full_name}</div>
                              <div style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>
                                {u.role}
                              </div>
                            </div>
                          </div>
                        </td>
                        <td>{u.email}</td>
                        <td>{u.role}</td>
                        <td>
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button
                              onClick={() => handleApproveUser(u.id, 'APPROVE')}
                              className="btn btn-success"
                              style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                              title="Approve"
                              disabled={isSubmitting}
                            >
                              {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaCheck />}
                            </button>
                            <button
                              onClick={() => handleApproveUser(u.id, 'REJECT')}
                              className="btn btn-danger"
                              style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                              title="Reject"
                              disabled={isSubmitting}
                            >
                              {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaTimes />}
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                    {pendingUserFilters.currentItems.length === 0 && (
                      <tr>
                        <td colSpan="5" style={{ textAlign: 'center' }}>No pending users</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
              <TablePagination
                currentPage={pendingUserFilters.currentPage}
                setCurrentPage={pendingUserFilters.setCurrentPage}
                totalPages={pendingUserFilters.totalPages}
                itemsPerPage={pendingUserFilters.itemsPerPage}
                setItemsPerPage={pendingUserFilters.setItemsPerPage}
              />
            </div>
          )}

          {activeTab === 'all_users' && (
            <div>
              {/* Title removed */}
              <TableControls
                searchTerm={allUserFilters.searchTerm}
                setSearchTerm={allUserFilters.setSearchTerm}
                startDate={allUserFilters.startDate}
                setStartDate={allUserFilters.setStartDate}
                endDate={allUserFilters.endDate}
                setEndDate={allUserFilters.setEndDate}
                onDownload={() => exportTableData(
                  allUserFilters.filteredData,
                  'All Users',
                  [
                    { header: 'ID', key: 'id' },
                    { header: 'Joined Date', key: 'created_at', format: (v) => formatDate(v) },
                    { header: 'Name', key: 'full_name' },
                    { header: 'Email', key: 'email' },
                    { header: 'Mobile', key: 'mobile_number', format: (v) => v || '-' },
                    { header: 'Role', key: 'role' },
                    { header: 'Assigned Manager', key: 'manager_name', format: (v) => v || '-' }
                  ]
                )}
                placeholder="Name, Email..."
              />
              <div className="table-responsive">
                <table style={{ whiteSpace: 'nowrap' }}>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Date</th>
                      <th>Name</th>
                      <th>Email</th>
                      <th>Role</th>
                      <th>Assigned Manager</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {allUserFilters.currentItems.map(u => (
                      <tr key={u.id}>
                        <td>{u.id}</td>
                        <td>{formatDate(u.created_at)}</td>
                        <td>
                          {u.full_name}
                          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginLeft: '4px' }}>
                            ({u.role})
                          </span>
                        </td>
                        <td>{u.email}</td>
                        <td>{u.role}</td>
                        <td>
                          <select
                            defaultValue={u.manager_id || ''}
                            onChange={(e) => {
                              handleAssignManager(u.id, e.target.value);
                            }}
                            style={{ padding: '0.35rem', borderRadius: '4px', border: '1px solid var(--border-light)' }}
                          >
                            <option value="">Unassigned</option>
                            {managers && managers.map(m => (
                              <option key={m.id} value={m.id}>{m.full_name}</option>
                            ))}
                          </select>
                        </td>
                        <td>
                          {u.manager_id ? (
                            <StatusBadge status='ASSIGNED' />
                          ) : (
                            <StatusBadge status='UNASSIGNED' />
                          )}
                        </td>
                      </tr>
                    ))}
                    {allUserFilters.currentItems.length === 0 && (<tr><td colSpan="7" style={{ textAlign: 'center' }}>No users found</td></tr>)}
                  </tbody>
                </table>
              </div>
              <TablePagination
                currentPage={allUserFilters.currentPage}
                setCurrentPage={allUserFilters.setCurrentPage}
                totalPages={allUserFilters.totalPages}
                itemsPerPage={allUserFilters.itemsPerPage}
                setItemsPerPage={allUserFilters.setItemsPerPage}
              />
            </div>
          )}

          {activeTab === 'registration_history' && (
            <div>
              {/* Refactored Registration History Table */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                {/* Title removed */}
              </div>

              <TableControls
                searchTerm={registrationFilters.searchTerm}
                setSearchTerm={registrationFilters.setSearchTerm}
                startDate={registrationFilters.startDate}
                setStartDate={registrationFilters.setStartDate}
                endDate={registrationFilters.endDate}
                setEndDate={registrationFilters.setEndDate}
                onDownload={() => handleDownloadRegistrationHistory(registrationFilters.filteredData)}
                placeholder="Name, Mobile, ID..."
              />

              <div className="table-responsive">
                <table style={{ whiteSpace: 'nowrap' }}>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Date</th>
                      <th>Name</th>
                      <th>Email</th>
                      <th>Mobile Number</th>
                      <th>Assigned Manager</th>
                      <th>Role</th>
                      <th>Status</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {registrationFilters.currentItems.map(u => (
                      <tr key={u.id}>
                        <td>{u.id}</td>
                        <td>{formatDate(u.created_at)}</td>
                        <td>
                          {u.full_name}
                          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginLeft: '4px' }}>
                            ({u.role})
                          </span>
                        </td>
                        <td>{u.email}</td>
                        <td>{u.mobile_number || '-'}</td>
                        <td>{u.manager_name || '-'}</td>
                        <td>{u.role}</td>
                        <td>
                          {(() => {
                            const activeManagerIds = new Set(allUsers.filter(u => u.manager_id).map(u => u.manager_id));
                            const isActiveManager = u.role === 'MANAGER' && activeManagerIds.has(u.id);
                            const finalStatus = (u.manager_name || isActiveManager) ? 'ACTIVE' : u.status;
                            return (
                              <StatusBadge status={finalStatus} />
                            );
                          })()}
                        </td>
                        <td>
                          <div style={{ display: 'flex', gap: '8px', alignItems: 'center', whiteSpace: 'nowrap' }}>
                            <button
                              onClick={() => setViewUserInfo(u)}
                              className="btn btn-secondary"
                              style={{ padding: '0.4rem', borderRadius: '50%' }}
                              title="View Details"
                            >
                              <FaEye />
                            </button>
                            <button
                              onClick={() => {
                                const title = `User Details: ${u.full_name}`;
                                const columns = [
                                  { header: 'Field', key: 'field' },
                                  { header: 'Value', key: 'value' }
                                ];
                                const data = [
                                  { field: 'Full Name', value: u.full_name },
                                  { field: 'Role', value: u.role },
                                  { field: 'Email', value: u.email },
                                  { field: 'Mobile', value: u.mobile_number || '-' },
                                  { field: 'Joined Date', value: formatDate(u.created_at) },
                                  { field: 'Status', value: u.status }
                                ];
                                generateProfessionalPDF(title, columns, data);
                              }}
                              className="btn btn-primary"
                              style={{ padding: '0.4rem', borderRadius: '50%' }}
                              title="Download Report"
                            >
                              <FaDownload />
                            </button>

                            {u.status !== 'PENDING' && (
                              <button
                                onClick={() => handleToggleStatus(u)}
                                className={`btn ${u.status === 'APPROVED' ? 'btn-danger' : 'btn-success'}`}
                                style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                title={u.status === 'APPROVED' ? 'Deactivate User' : 'Activate User'}
                              >
                                {u.status === 'APPROVED' ? <FaTimesCircle /> : <FaCheckCircle />}
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                    {registrationFilters.currentItems.length === 0 && (
                      <tr><td colSpan="9" style={{ textAlign: 'center' }}>No records found</td></tr>
                    )}
                  </tbody>
                </table>
              </div>

              <TablePagination
                currentPage={registrationFilters.currentPage}
                setCurrentPage={registrationFilters.setCurrentPage}
                totalPages={registrationFilters.totalPages}
                itemsPerPage={registrationFilters.itemsPerPage}
                setItemsPerPage={registrationFilters.setItemsPerPage}
              />
            </div>
          )}

          {activeTab === 'allocate_fund' && (
            <div className="dashboard-creation-container">
              {/* Check if we are in an active allocation flow */}
              {(fundForm.to_user_id || editingFund || allocatingExpenseId || allocatingExpansionId) ? (
                <AllocationForm
                  managers={managers}
                  initialData={fundForm}
                  onSubmit={editingFund ? handleUpdateAllocation : handleAllocateFund}
                  onCancel={() => {
                    setEditingFund(null);
                    setFundForm({
                      to_user_id: '',
                      amount: '',
                      description: '',
                      payment_mode: 'CASH',
                      expansion_id: null,
                      cheque_number: '',
                      bank_name: '',
                      cheque_date: '',
                      account_holder_name: '',
                      upi_id: '',
                      transaction_id: ''
                    });
                    if (editingFund) {
                      setSearchParams({ tab: 'fund_history' });
                    } else {
                      setSearchParams({ tab: 'dashboard' });
                    }
                  }}
                />
              ) : (
                <div className="dashboard-empty-state">
                  <div className="dashboard-empty-icon" style={{ color: 'var(--primary-200)' }}>
                    <FaHandHoldingUsd />
                  </div>
                  <h3 className="dashboard-empty-title">Ready to Allocate Funds?</h3>
                  <p className="dashboard-empty-text">
                    To allocate funds to a manager, please first approve an expense or an expansion request from the respective tabs.
                  </p>
                  <div className="dashboard-empty-actions">
                    <button onClick={() => setActiveTab('pending_approvals')} className="btn btn-primary">
                      View Pending Expenses
                    </button>
                    <button onClick={() => setActiveTab('review_expansion')} className="btn btn-secondary">
                      Review Expansion Requests
                    </button>
                  </div>
                </div>
              )}

              <div className="side-recent">
                <h4>Recent Allocations</h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                  {allocationHistory.filter(f => f.from_user_id === user?.id).slice(0, 3).map(fund => (
                    <div key={fund.id} className="card" style={{ padding: '1rem', borderLeft: '4px solid var(--success-500)' }}>
                      <div style={{ fontWeight: 'bold' }}>To: {fund.to_user_name}</div>
                      <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{formatCurrency(fund.amount)} • {formatDate(fund.created_at)}</div>
                      <StatusBadge status={fund.status} />
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {activeTab === 'fund_history' && (
            <div>
              {/* Title removed */}
              <TableControls
                searchTerm={fundFilters.searchTerm}
                setSearchTerm={fundFilters.setSearchTerm}
                startDate={fundFilters.startDate}
                setStartDate={fundFilters.setStartDate}
                endDate={fundFilters.endDate}
                setEndDate={fundFilters.setEndDate}
                onDownload={() => exportTableData(
                  fundFilters.filteredData,
                  'Fund Allocation History',
                  [
                    { header: 'ID', key: 'id' },
                    { header: 'Date', key: 'created_at', format: (v) => formatDate(v) },
                    { header: 'To User', key: 'to_user_name' },
                    { header: 'Description', key: 'description', format: (v) => v || '-' },
                    { header: 'Payment Mode', key: 'payment_mode' },
                    { header: 'Amount', key: 'amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') },
                    { header: 'Status', key: 'status' },
                    { header: 'Cheque No', key: 'cheque_number' },
                    { header: 'Bank', key: 'bank_name' },
                    { header: 'Cheque Date', key: 'cheque_date', format: (v) => v ? formatDate(v) : '-' },
                    { header: 'Account Holder', key: 'account_holder_name' },
                    { header: 'UPI ID', key: 'upi_id' },
                    { header: 'Transaction ID', key: 'transaction_id' }
                  ]
                )}
                placeholder="Manager, Amount, Mode..."
              />
              <div className="table-responsive">
                <table style={{ whiteSpace: 'nowrap' }}>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Date</th>
                      <th>Manager</th>
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
                          <td>{fund.to_user_name}</td>
                          <td>{formatCurrency(fund.amount)}</td>
                          <td>{fund.payment_mode || '-'}</td>
                          <td>
                            <StatusBadge status={fund.status} />
                          </td>
                          <td>
                            <div style={{ display: 'flex', gap: '5px', alignItems: 'center', whiteSpace: 'nowrap' }}>
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
                                title="Download PDF"
                              >
                                <FaDownload />
                              </button>
                              {fund.status === 'ALLOCATED' && (
                                <>
                                  <button
                                    onClick={() => handleEditAllocation(fund)}
                                    className="btn btn-warning"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Edit Allocation"
                                    disabled={isSubmitting}
                                  >
                                    {isSubmitting ? <span className="btn-spinner" style={{ width: '12px', height: '12px', borderWidth: '2px' }}></span> : <FaEdit />}
                                  </button>
                                  <button
                                    onClick={() => handleDeleteAllocation(fund.id)}
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
                      ))
                    ) : (
                      <tr>
                        <td colSpan="7" style={{ textAlign: 'center', padding: '1rem' }}>No allocation history found</td>
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
          )}

          {activeTab === 'review_expansion' && (
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                {/* Title removed */}
              </div>
              <TableControls
                searchTerm={expansionFilters.searchTerm}
                setSearchTerm={expansionFilters.setSearchTerm}
                startDate={expansionFilters.startDate}
                setStartDate={expansionFilters.setStartDate}
                endDate={expansionFilters.endDate}
                setEndDate={expansionFilters.setEndDate}
                onDownload={() => exportTableData(
                  expansionFilters.filteredData.filter(f => f.status === 'PENDING'),
                  'Pending Expansion Requests',
                  [
                    { header: 'ID', key: 'id' },
                    { header: 'Date', key: 'requested_at', format: (v) => formatDate(v) },
                    { header: 'Requester', key: 'manager_name' },
                    { header: 'Justification', key: 'justification', format: (v) => v || '-' },
                    { header: 'Amount', key: 'requested_amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') },
                    { header: 'Status', key: 'status' }
                  ]
                )}
                placeholder="Manager, Amount..."
              />
              <div className="table-responsive">
                <table style={{ whiteSpace: 'nowrap' }}>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Date</th>
                      <th>Requester</th>
                      <th>Type</th>
                      <th>Amount</th>
                      <th>Description</th>
                      <th>Status</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {expansionFilters.currentItems.filter(fund => fund.status === 'PENDING' || fund.status === 'APPROVED').length > 0 ? (
                      expansionFilters.currentItems.filter(fund => fund.status === 'PENDING' || fund.status === 'APPROVED').map(fund => (
                        <tr key={fund.id}>
                          <td>{fund.id}</td>
                          <td>{formatDate(fund.requested_at)}</td>
                          <td>{fund.manager_name}</td>
                          <td>Expansion</td>
                          <td>{formatCurrency(fund.requested_amount)}</td>
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
                            <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                              <button
                                onClick={() => setViewExpansion(fund)}
                                className="btn btn-secondary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="View Details"
                              >
                                <FaEye />
                              </button>
                              {fund.status === 'PENDING' && (
                                <>
                                  <button
                                    onClick={() => handleApproveExpansion(fund)}
                                    className="btn btn-success"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Approve"
                                  >
                                    <FaCheck />
                                  </button>
                                  <button
                                    onClick={() => handleRejectExpansion(fund.id)}
                                    className="btn btn-danger"
                                    style={{ padding: '0.4rem', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                    title="Reject"
                                  >
                                    <FaTimes />
                                  </button>
                                </>
                              )}
                              {fund.status === 'APPROVED' && (
                                <button
                                  onClick={() => handlePreFillAllocation(fund)}
                                  className="btn"
                                  style={{
                                    padding: '0.4rem 0.8rem',
                                    fontSize: '0.85rem',
                                    color: 'white',
                                    background: 'linear-gradient(135deg, #6B73FF 0%, #000DFF 100%)',
                                    border: 'none',
                                    borderRadius: '20px',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '6px'
                                  }}
                                  title="Allocate Fund"
                                >
                                  <FaHandHoldingUsd /> Allocate
                                </button>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan="8" style={{ textAlign: 'center', padding: '1rem' }}>No pending expansion requests found</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'expansion_history' && (
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
                  'Expansion Fund History',
                  [
                    { header: 'ID', key: 'id' },
                    { header: 'Date', key: 'requested_at', format: (v) => formatDate(v) },
                    { header: 'Requester', key: 'manager_name' },
                    { header: 'Justification', key: 'justification', format: (v) => v || '-' },
                    { header: 'Reviewer', key: 'reviewer_name', format: (v) => v || '-' },
                    { header: 'Amount', key: 'requested_amount', format: (v) => formatCurrency(v).replace('₹', 'Rs. ') },
                    { header: 'Approved', key: 'approved_amount', format: (v) => v ? formatCurrency(v).replace('₹', 'Rs. ') : '0.00' },
                    { header: 'Status', key: 'status' }
                  ]
                )}
                placeholder="Manager, Amount, Status..."
              />
              <div className="table-responsive">
                <table style={{ whiteSpace: 'nowrap' }}>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Date</th>
                      <th>Requester</th>
                      <th>Type</th>
                      <th>Description</th>
                      <th>Amount</th>
                      <th>Status</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {expansionFilters.currentItems.length > 0 ? (
                      expansionFilters.currentItems.map(fund => (
                        <tr key={fund.id}>
                          <td>{fund.id}</td>
                          <td>{formatDate(fund.requested_at)}</td>
                          <td>{fund.manager_name}</td>
                          <td>Expansion</td>
                          <td style={{ maxWidth: '200px' }}>
                            <div
                              style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '200px' }}
                              title={fund.justification || '-'}
                            >
                              {fund.justification}
                            </div>
                          </td>
                          <td>{formatCurrency(fund.requested_amount)}</td>
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
                                onClick={() => handleDownloadPDF(fund, 'EXPANSION')}
                                className="btn btn-primary"
                                style={{ padding: '0.4rem', borderRadius: '50%' }}
                                title="Download Statement"
                              >
                                <FaDownload />
                              </button>

                            </div>
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan="8" style={{ textAlign: 'center', padding: '1rem' }}>No expansion fund history found</td>
                      </tr>
                    )}
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
          )}

          {
            activeTab === 'reports' && (
              <ReportsSection role="CEO" />
            )
          }

          {
            activeTab === 'profile' && (
              <ProfileSection />
            )
          }
        </div>
      </Layout>
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
        viewExpansion && (
          <InvoiceModal
            data={viewExpansion}
            type="EXPANSION"
            onClose={closeModal}
            onDownload={(fund) => handleDownloadPDF(fund, 'EXPANSION')}
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
        viewUserInfo && (
          <div className="modal-overlay" onClick={closeModal} style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(15, 23, 42, 0.6)', backdropFilter: 'blur(4px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 2000
          }}>
            <div className="modal-content" onClick={e => e.stopPropagation()} style={{
              background: 'var(--bg-card)', width: '95%', maxWidth: '600px',
              borderRadius: '8px', boxShadow: 'var(--shadow-xl)',
              overflow: 'hidden', display: 'flex', flexDirection: 'column',
              maxHeight: '90vh', border: '1px solid var(--border-light)', animation: 'fade-in-up 0.3s ease-out'
            }}>
              {/* Header */}
              <div style={{
                background: 'var(--bg-card)', padding: '1rem 1.5rem', borderBottom: '1px solid var(--border-light)',
                display: 'flex', justifyContent: 'space-between', alignItems: 'center'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  <div style={{
                    width: '36px', height: '36px', borderRadius: '6px',
                    background: '#3b82f6', color: 'white', display: 'flex',
                    alignItems: 'center', justifyContent: 'center', fontSize: '1rem',
                    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                  }}>
                    <FaUser />
                  </div>
                  <div>
                    <h2 style={{ margin: 0, fontSize: 'clamp(0.9rem, 2.5vw, 1.1rem)', fontWeight: '700', color: 'var(--text-main)', letterSpacing: '-0.01em', textTransform: 'uppercase' }}>
                      User Details
                    </h2>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', fontWeight: '500' }}>
                      System User Profile
                    </div>
                  </div>
                </div>
                <button onClick={closeModal} style={{ background: 'none', border: 'none', color: '#94a3b8', cursor: 'pointer', fontSize: '1.1rem' }}>
                  <FaTimesCircle />
                </button>
              </div>

              {/* Body */}
              <div style={{ padding: '1.5rem', overflowY: 'auto', background: 'var(--secondary-50)' }}>
                <div style={{
                  background: 'var(--bg-card)', border: '1px solid var(--border-light)', borderRadius: '6px',
                  padding: '1.25rem', display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '1.5rem'
                }}>
                  <div style={{ gridColumn: 'span 2', display: 'flex', alignItems: 'center', gap: '1rem', borderBottom: '1px solid var(--border-light)', paddingBottom: '1rem', marginBottom: '0.5rem' }}>
                    <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'var(--secondary-100)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary-500)', fontSize: '1.2rem' }}>
                      <FaUser />
                    </div>
                    <div>
                      <div style={{ fontSize: '1.1rem', fontWeight: '700', color: 'var(--text-main)' }}>{viewUserInfo.full_name}</div>
                      <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{viewUserInfo.email}</div>
                    </div>
                  </div>

                  <div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>Role</div>
                    <div style={{ display: 'inline-block', padding: '0.25rem 0.5rem', background: 'var(--secondary-100)', borderRadius: '4px', fontSize: '0.8rem', fontWeight: '600', color: 'var(--text-main)' }}>
                      {viewUserInfo.role}
                    </div>
                  </div>
                  <div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>Status</div>
                    <StatusBadge status={viewUserInfo.status} />
                  </div>
                  <div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>Mobile Number</div>
                    <div style={{ fontSize: '0.9rem', color: 'var(--text-main)', fontWeight: '500' }}>{viewUserInfo.mobile_number || '-'}</div>
                  </div>
                  <div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>System ID</div>
                    <div style={{ fontSize: '0.9rem', color: 'var(--text-main)', fontFamily: 'monospace' }}>#{String(viewUserInfo.id).padStart(4, '0')}</div>
                  </div>
                  <div style={{ gridColumn: 'span 2' }}>
                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600', marginBottom: '0.2rem' }}>Assigned Manager</div>
                    <div style={{ fontSize: '0.9rem', color: 'var(--text-main)', fontWeight: '500', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <FaUserTie color="var(--text-muted)" /> {viewUserInfo.manager_name || <span style={{ color: 'var(--text-muted)', fontStyle: 'italic' }}>Unassigned</span>}
                    </div>
                  </div>
                </div>
              </div>

              {/* Footer */}
              <div style={{ padding: '1rem 1.5rem', background: '#ffffff', borderTop: '1px solid #e2e8f0', display: 'flex', justifyContent: 'flex-end', gap: '1rem' }}>
                <button onClick={closeModal} style={{
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
              </div>
            </div>
          </div>
        )
      }

      {/* Edit Expense Modal */}
      {editingExpense && (
        <div className="modal-overlay" onClick={() => setEditingExpense(null)}>
          <div className={`modal-content ${isExpenseShaking ? 'shake' : ''}`} onClick={e => e.stopPropagation()} style={{ background: 'var(--bg-card)', padding: '2rem', width: '90%', maxWidth: '500px', borderRadius: '1rem' }}>
            <h2>Edit Expense</h2>
            <form onSubmit={handleUpdateExpense} noValidate>
              {expenseFormErrors.form && (
                <div className="alert alert-danger" style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.75rem', borderRadius: '4px' }}>
                  <FaExclamationCircle /> {expenseFormErrors.form}
                </div>
              )}
              <div className={`form-group ${expenseFormErrors.title ? 'shake' : ''}`}>
                <label htmlFor="edit_title">Title</label>
                <input
                  type="text"
                  id="edit_title"
                  className={`form-control ${expenseFormErrors.title ? 'is-invalid' : ''}`}
                  value={editingExpense.title}
                  onChange={e => {
                    setEditingExpense({ ...editingExpense, title: e.target.value });
                    if (expenseFormErrors.title) setExpenseFormErrors({ ...expenseFormErrors, title: '' });
                  }}
                  required
                />
                {expenseFormErrors.title && <span className="invalid-feedback">{expenseFormErrors.title}</span>}
              </div>
              <div className={`form-group ${expenseFormErrors.category ? 'shake' : ''}`}>
                <label htmlFor="edit_category">Category</label>
                <select
                  id="edit_category"
                  className={`form-control ${expenseFormErrors.category ? 'is-invalid' : ''}`}
                  value={editingExpense.category}
                  onChange={e => {
                    setEditingExpense({ ...editingExpense, category: e.target.value });
                    if (expenseFormErrors.category) setExpenseFormErrors({ ...expenseFormErrors, category: '' });
                  }}
                  required
                >
                  <option value="">Select Category</option>
                  {EXPENSE_CATEGORIES.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                  <option value="Other">Other</option>
                </select>
                {expenseFormErrors.category && <span className="invalid-feedback">{expenseFormErrors.category}</span>}
              </div>
              {editingExpense.category === 'Other' && (
                <div className={`form-group animate-slide-in ${expenseFormErrors.customCategory ? 'shake' : ''}`}>
                  <label htmlFor="edit_customCategory">Custom Category Name</label>
                  <input
                    type="text"
                    id="edit_customCategory"
                    className={`form-control ${expenseFormErrors.customCategory ? 'is-invalid' : ''}`}
                    placeholder="Enter category name"
                    value={editingExpense.customCategory || ''}
                    onChange={(e) => {
                      setEditingExpense({ ...editingExpense, customCategory: e.target.value });
                      if (expenseFormErrors.customCategory) setExpenseFormErrors({ ...expenseFormErrors, customCategory: '' });
                    }}
                    required
                  />
                  {expenseFormErrors.customCategory && <span className="invalid-feedback">{expenseFormErrors.customCategory}</span>}
                </div>
              )}
              <div className={`form-group ${expenseFormErrors.department ? 'shake' : ''}`}>
                <label htmlFor="edit_department">Department</label>
                <select
                  id="edit_department"
                  className={`form-control ${expenseFormErrors.department ? 'is-invalid' : ''}`}
                  value={editingExpense.department || ''}
                  onChange={e => {
                    setEditingExpense({ ...editingExpense, department: e.target.value });
                    if (expenseFormErrors.department) setExpenseFormErrors({ ...expenseFormErrors, department: '' });
                  }}
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
                <label htmlFor="edit_amount">Amount</label>
                <input
                  type="number"
                  id="edit_amount"
                  className={`form-control ${expenseFormErrors.amount ? 'is-invalid' : ''}`}
                  value={editingExpense.amount}
                  onChange={e => {
                    setEditingExpense({ ...editingExpense, amount: e.target.value });
                    if (expenseFormErrors.amount) setExpenseFormErrors({ ...expenseFormErrors, amount: '' });
                  }}
                  required
                />
                {expenseFormErrors.amount && <span className="invalid-feedback">{expenseFormErrors.amount}</span>}
              </div>
              <div className={`form-group ${expenseFormErrors.expense_date ? 'shake' : ''}`}>
                <label htmlFor="edit_expense_date">Date</label>
                <input
                  type="date"
                  id="edit_expense_date"
                  className={`form-control ${expenseFormErrors.expense_date ? 'is-invalid' : ''}`}
                  value={editingExpense.expense_date ? editingExpense.expense_date.split('T')[0] : ''}
                  onChange={e => {
                    setEditingExpense({ ...editingExpense, expense_date: e.target.value });
                    if (expenseFormErrors.expense_date) setExpenseFormErrors({ ...expenseFormErrors, expense_date: '' });
                  }}
                  required
                  max={new Date().toISOString().split('T')[0]}
                />
                {expenseFormErrors.expense_date && <span className="invalid-feedback">{expenseFormErrors.expense_date}</span>}
              </div>
              <div className="form-group">
                <label htmlFor="edit_description">Description</label>
                <textarea
                  id="edit_description"
                  className="form-control"
                  value={editingExpense.description || ''}
                  onChange={e => setEditingExpense({ ...editingExpense, description: e.target.value })}
                />
              </div>
              <div className="modal-actions">
                <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
                  {isSubmitting ? (
                    <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="btn-spinner" style={{ width: '14px', height: '14px', borderWidth: '2px' }}></span> Updating...
                    </span>
                  ) : (
                    'Update Expense'
                  )}
                </button>
                <button type="button" className="btn btn-secondary" onClick={() => { setEditingExpense(null); setExpenseFormErrors({}); }} disabled={isSubmitting}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}



      {/* Edit Expansion Modal */}
      {editingExpansion && (
        <div className="modal-overlay" onClick={() => setEditingExpansion(null)}>
          <div className={`modal-content ${isExpansionShaking ? 'shake' : ''}`} onClick={e => e.stopPropagation()} style={{ background: 'var(--bg-card)', padding: '2rem', width: '90%', maxWidth: '500px', borderRadius: '1rem' }}>
            <h2>Edit Expansion Request</h2>
            <form onSubmit={handleUpdateExpansion} noValidate>
              {expansionFormErrors.form && (
                <div className="alert alert-danger" style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.75rem', borderRadius: '4px' }}>
                  <FaExclamationCircle /> {expansionFormErrors.form}
                </div>
              )}
              <div className={`form-group ${expansionFormErrors.requested_amount ? 'shake' : ''}`}>
                <label htmlFor="edit_requested_amount">Amount</label>
                <input
                  type="number"
                  id="edit_requested_amount"
                  className={`form-control ${expansionFormErrors.requested_amount ? 'is-invalid' : ''}`}
                  value={editingExpansion.requested_amount}
                  onChange={e => {
                    setEditingExpansion({ ...editingExpansion, requested_amount: e.target.value });
                    if (expansionFormErrors.requested_amount) setExpansionFormErrors({ ...expansionFormErrors, requested_amount: '' });
                  }}
                  required
                />
                {expansionFormErrors.requested_amount && <span className="invalid-feedback">{expansionFormErrors.requested_amount}</span>}
              </div>
              <div className={`form-group ${expansionFormErrors.justification ? 'shake' : ''}`}>
                <label htmlFor="edit_justification">Justification</label>
                <textarea
                  id="edit_justification"
                  className={`form-control ${expansionFormErrors.justification ? 'is-invalid' : ''}`}
                  value={editingExpansion.justification || ''}
                  onChange={e => {
                    setEditingExpansion({ ...editingExpansion, justification: e.target.value });
                    if (expansionFormErrors.justification) setExpansionFormErrors({ ...expansionFormErrors, justification: '' });
                  }}
                  required
                />
                {expansionFormErrors.justification && <span className="invalid-feedback">{expansionFormErrors.justification}</span>}
              </div>
              <div className="modal-actions">
                <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
                  {isSubmitting ? (
                    <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="btn-spinner" style={{ width: '14px', height: '14px', borderWidth: '2px' }}></span> Updating...
                    </span>
                  ) : (
                    'Update Expansion'
                  )}
                </button>
                <button type="button" className="btn btn-secondary" onClick={() => { setEditingExpansion(null); setExpansionFormErrors({}); }} disabled={isSubmitting}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}

    </>
  );
}



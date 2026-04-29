import axios from 'axios';

// --- Users ---

export const getPendingUsers = async () => {
    return await axios.get('/api/users/pending');
};

export const getAllUsers = async () => {
    return await axios.get('/api/users');
};

export const approveUser = async (id, action) => {
    return await axios.put(`/api/users/${id}/approve`, { action });
};

export const assignManager = async (userId, managerId) => {
    return await axios.put(`/api/users/${userId}/assign-manager`, { manager_id: managerId });
};

export const getManagers = async () => {
    return await axios.get('/api/users/managers');
};

export const getUsers = async () => {
    return await axios.get('/api/users/users');
};

export const updateProfile = async (formData) => {
    return await axios.put('/api/auth/profile', formData, {
        headers: {
            'Content-Type': 'multipart/form-data',
        },
    });
};

export const deleteProfileImage = async () => {
    return await axios.delete('/api/auth/profile-image');
};


// --- Expenses ---

export const createExpense = async (formData) => {
    return await axios.post('/api/expenses', formData, {
        headers: {
            'Content-Type': 'multipart/form-data',
        },
    });
};

export const getExpenses = async (params = {}) => {
    return await axios.get('/api/expenses', { params });
};

export const getExpenseById = async (id) => {
    return await axios.get(`/api/expenses/${id}`);
};

export const approveExpense = async (id) => {
    return await axios.put(`/api/expenses/${id}/approve`);
};

export const rejectExpense = async (id, reason) => {
    return await axios.put(`/api/expenses/${id}/reject`, { rejection_reason: reason });
};

export const updateExpense = async (id, formData) => {
    return await axios.put(`/api/expenses/${id}`, formData, {
        headers: {
            'Content-Type': 'multipart/form-data',
        },
    });
};

export const updateExpenseStatus = async (id, status) => {
    return await axios.put(`/api/expenses/${id}/status`, { status });
};

export const deleteExpense = async (id) => {
    return await axios.delete(`/api/expenses/${id}`);
};

export const deleteExpenseDocument = async (expenseId, docId) => {
    return await axios.delete(`/api/expenses/${expenseId}/documents/${docId}`);
};


// --- Funds ---

export const allocateOperationalFund = async (data) => {
    return await axios.post('/api/funds/operational', data);
};

export const requestOperationalFund = async (data) => {
    return await axios.post('/api/funds/request', data);
};

export const getOperationalFunds = async (params = {}) => {
    return await axios.get('/api/funds/operational', { params });
};

export const confirmFundReceipt = async (id) => {
    return await axios.put(`/api/funds/operational/${id}/receive`);
};

export const approveFundRequest = async (id) => {
    return await axios.put(`/api/funds/operational/${id}/approve`);
};

export const allocateFundRequest = async (id) => {
    return await axios.put(`/api/funds/operational/${id}/allocate`);
};

export const rejectFundRequest = async (id, reason) => {
    return await axios.put(`/api/funds/operational/${id}/reject`, { rejection_reason: reason });
};

export const updateFund = async (id, data) => {
    return await axios.put(`/api/funds/operational/${id}`, data);
};

export const deleteFund = async (id) => {
    return await axios.delete(`/api/funds/operational/${id}`);
};

export const updateOperationalFund = updateFund;
export const deleteOperationalFund = deleteFund;

export const requestExpansionFund = async (data) => {
    return await axios.post('/api/funds/expansion', data);
};

export const getExpansionFunds = async (params = {}) => {
    return await axios.get('/api/funds/expansion', { params });
};

export const reviewExpansionFund = async (id, data) => {
    return await axios.put(`/api/funds/expansion/${id}/review`, data);
};


// --- Reports / Dashboard ---

export const getDashboardStats = async () => {
    return await axios.get('/api/reports/dashboard');
};

export const getExpenseReports = async (params = {}) => {
    return await axios.get('/api/reports/expenses', { params });
};

export const getFundReports = async (params = {}) => {
    return await axios.get('/api/reports/funds', { params });
};

export const getExpansionReports = async (params = {}) => {
    return await axios.get('/api/reports/expansion', { params });
};

export const updateExpansionFund = async (id, data) => {
    return await axios.put(`/api/funds/expansion/${id}`, data);
};

export const deleteExpansionFund = async (id) => {
    return await axios.delete(`/api/funds/expansion/${id}`);
};

export const getAllocationUsage = async () => {
    return await axios.get('/api/reports/allocation-usage');
};


// --- Notifications ---

export const getNotifications = async () => {
    return await axios.get('/api/notifications');
};

export const markNotificationAsRead = async (id) => {
    return await axios.put(`/api/notifications/${id}/read`);
};

export const markAllNotificationsAsRead = async () => {
    return await axios.put('/api/notifications/read-all');
};

// --- Sessions ---
export const getSessions = async () => {
    return await axios.get('/api/auth/sessions');
};

export const revokeSession = async (sessionId) => {
    return await axios.delete(`/api/auth/sessions/${sessionId}`);
};

export const revokeAllOtherSessions = async () => {
    return await axios.delete('/api/auth/sessions/revoke-all-others');
};

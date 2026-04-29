import React, { createContext, useState, useContext, useEffect } from 'react';
import axios from 'axios';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('token');
    const storedUser = localStorage.getItem('user');

    if (token && storedUser) {
      setUser(JSON.parse(storedUser));
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

      // Fetch fresh user data to ensure sync
      axios.get('/api/auth/me')
        .then(response => {
          if (response.data.user) {
            setUser(response.data.user);
            localStorage.setItem('user', JSON.stringify(response.data.user));
          }
        })
        .catch(() => {
          // If token is invalid, logout (handled by interceptor mostly, but good safety)
        });
    }

    setLoading(false);

    const interceptor = axios.interceptors.response.use(
      (response) => response,
      (error) => {
        const isAuthError = error.response && (error.response.status === 401 || error.response.status === 403);
        const isLogoutRequest = error.config && error.config.url && (error.config.url.includes('/logout') || error.config.url.endsWith('/logout'));

        if (isAuthError && !isLogoutRequest) {
          logout();
        }
        return Promise.reject(error);
      }
    );

    return () => {
      axios.interceptors.response.eject(interceptor);
    };
  }, []);

  const login = async (email, password) => {
    try {
      const deviceInfo = `Browser: ${navigator.userAgent.substring(0, 100)}`;
      const response = await axios.post('/api/auth/login', { email, password, device_info: deviceInfo });
      const { token, user } = response.data;

      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      setUser(user);

      return { success: true };
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Login failed'
      };
    }
  };

  const register = async (userData) => {
    try {
      await axios.post('/api/auth/register', userData);
      return { success: true };
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Registration failed'
      };
    }
  };

  const requestLoginOtp = async (email) => {
    try {
      await axios.post('/api/auth/request-login-otp', { email });
      return { success: true };
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to send OTP'
      };
    }
  };

  const loginWithOtp = async (email, otp) => {
    try {
      const deviceInfo = `Browser: ${navigator.userAgent.substring(0, 100)}`;
      const response = await axios.post('/api/auth/login-otp', { email, otp, device_info: deviceInfo });
      const { token, user } = response.data;

      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      setUser(user);

      return { success: true };
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Invalid or expired OTP'
      };
    }
  };

  const logout = async () => {
    try {
      if (localStorage.getItem('token')) {
        await axios.post('/api/auth/logout');
      }
    } catch (err) {
      console.error('Backend logout error:', err);
    } finally {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      delete axios.defaults.headers.common['Authorization'];
      setUser(null);
    }
  };

  const requestRegistrationOtp = async (email) => {
    try {
      await axios.post('/api/auth/request-registration-otp', { email });
      return { success: true };
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to send verification code'
      };
    }
  };

  const verifyRegistrationOtp = async (email, otp) => {
    try {
      const response = await axios.post('/api/auth/verify-registration-otp', { email, otp });
      return { success: true, verificationToken: response.data.verificationToken };
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Invalid verification code'
      };
    }
  };

  const updateUser = (userData) => {
    const updatedUser = { ...user, ...userData };
    setUser(updatedUser);
    localStorage.setItem('user', JSON.stringify(updatedUser));
  };

  const refreshUserProfile = async () => {
    try {
      const response = await axios.get('/api/auth/me');
      if (response.data.user) {
        setUser(response.data.user);
        localStorage.setItem('user', JSON.stringify(response.data.user));
        return response.data.user;
      }
    } catch (error) {
      console.error('Refresh user profile error:', error);
    }
    return null;
  };

  return (
    <AuthContext.Provider value={{
      user, login, register, requestLoginOtp, loginWithOtp,
      requestRegistrationOtp, verifyRegistrationOtp,
      logout, loading, updateUser, refreshUserProfile
    }}>
      {children}
    </AuthContext.Provider>
  );
};

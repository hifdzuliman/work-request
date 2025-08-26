import React, { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react';
import api from '../services/api';

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
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in from localStorage
    const token = localStorage.getItem('token');
    if (token) {
      // Prevent duplicate API calls
      let isMounted = true;
      
      // Verify token with backend
      api.getCurrentUser()
        .then(userData => {
          if (isMounted) {
            setUser(userData);
            setIsAuthenticated(true);
          }
        })
        .catch(() => {
          if (isMounted) {
            // Token is invalid, clear it
            localStorage.removeItem('token');
            localStorage.removeItem('user');
          }
        })
        .finally(() => {
          if (isMounted) {
            setLoading(false);
          }
        });
      
      return () => {
        isMounted = false;
      };
    } else {
      setLoading(false);
    }
  }, []);

  const login = useCallback(async (username, password) => {
    try {
      const response = await api.login(username, password);
      
      // Handle both response formats (with and without success flag)
      if (response.success && response.token && response.user) {
        // New format with success flag
        const { user, token } = response;
        setUser(user);
        setIsAuthenticated(true);
        localStorage.setItem('user', JSON.stringify(user));
        localStorage.setItem('token', token);
        return { success: true };
      } else if (response.token && response.user) {
        // Direct response format (token + user)
        const { user, token } = response;
        setUser(user);
        setIsAuthenticated(true);
        localStorage.setItem('user', JSON.stringify(user));
        localStorage.setItem('token', token);
        return { success: true };
      } else {
        return { success: false, message: 'Invalid response format' };
      }
    } catch (error) {
      return { success: false, message: error.message || 'Login failed' };
    }
  }, []);

  const logout = () => {
    setUser(null);
    setIsAuthenticated(false);
    localStorage.removeItem('user');
    localStorage.removeItem('token');
  };

  const updateProfile = (updatedData) => {
    const updatedUser = { ...user, ...updatedData };
    setUser(updatedUser);
    localStorage.setItem('user', JSON.stringify(updatedUser));
  };

  const value = useMemo(() => ({
    user,
    isAuthenticated,
    loading,
    login,
    logout,
    updateProfile
  }), [user, isAuthenticated, loading, login, updateProfile]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

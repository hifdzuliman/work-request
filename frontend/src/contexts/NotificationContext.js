import React, { createContext, useContext, useState, useCallback } from 'react';

const NotificationContext = createContext();

export const useNotificationContext = () => {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotificationContext must be used within a NotificationProvider');
  }
  return context;
};

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);

  const addNotification = useCallback((notification) => {
    const id = Date.now() + Math.random();
    const newNotification = {
      id,
      ...notification,
      show: true
    };
    
    setNotifications(prev => [...prev, newNotification]);
    
    return id;
  }, []);

  const removeNotification = useCallback((id) => {
    setNotifications(prev => prev.filter(notif => notif.id !== id));
  }, []);

  const clearAll = useCallback(() => {
    setNotifications([]);
  }, []);

  // Helper functions for common notification types
  const showSuccess = useCallback((title, message, options = {}) => {
    return addNotification({
      type: 'success',
      title,
      message,
      duration: 4000,
      ...options
    });
  }, [addNotification]);

  const showError = useCallback((title, message, options = {}) => {
    return addNotification({
      type: 'error',
      title,
      message,
      duration: 6000,
      autoClose: false, // Errors don't auto-close by default
      ...options
    });
  }, [addNotification]);

  const showWarning = useCallback((title, message, options = {}) => {
    return addNotification({
      type: 'warning',
      title,
      message,
      duration: 5000,
      ...options
    });
  }, [addNotification]);

  const showInfo = useCallback((title, message, options = {}) => {
    return addNotification({
      type: 'info',
      title,
      message,
      duration: 4000,
      ...options
    });
  }, [addNotification]);

  const showPending = useCallback((title, message, options = {}) => {
    return addNotification({
      type: 'pending',
      title,
      message,
      duration: 3000,
      ...options
    });
  }, [addNotification]);

  const showApproved = useCallback((title, message, options = {}) => {
    return addNotification({
      type: 'approved',
      title,
      message,
      duration: 4000,
      ...options
    });
  }, [addNotification]);

  const showRejected = useCallback((title, message, options = {}) => {
    return addNotification({
      type: 'rejected',
      title,
      message,
      duration: 5000,
      autoClose: false, // Rejections don't auto-close by default
      ...options
    });
  }, [addNotification]);

  // Specific notification functions for common use cases
  const showPengajuanSuccess = useCallback((jenisRequest) => {
    const title = 'Pengajuan Berhasil Dibuat!';
    const message = `Pengajuan ${jenisRequest} telah berhasil dibuat dan sedang menunggu persetujuan.`;
    
    return showSuccess(title, message, {
      position: 'top-center'
    });
  }, [showSuccess]);

  const showPengajuanApproved = useCallback((jenisRequest, approver) => {
    const title = 'Pengajuan Disetujui!';
    const message = `Pengajuan ${jenisRequest} telah disetujui oleh ${approver}.`;
    
    return showApproved(title, message, {
      position: 'top-center'
    });
  }, [showApproved]);

  const showPengajuanRejected = useCallback((jenisRequest, approver, reason) => {
    const title = 'Pengajuan Ditolak';
    const message = reason 
      ? `Pengajuan ${jenisRequest} ditolak oleh ${approver}. Alasan: ${reason}`
      : `Pengajuan ${jenisRequest} ditolak oleh ${approver}.`;
    
    return showRejected(title, message, {
      position: 'top-center'
    });
  }, [showRejected]);

  const showPengajuanProcessed = useCallback((jenisRequest, processor) => {
    const title = 'Pengajuan Sedang Diproses';
    const message = `Pengajuan ${jenisRequest} sedang diproses oleh ${processor}.`;
    
    return showPending(title, message, {
      position: 'top-center'
    });
  }, [showPending]);

  const showPengajuanCompleted = useCallback((jenisRequest, completer) => {
    const title = 'Pengajuan Selesai';
    const message = `Pengajuan ${jenisRequest} telah selesai diproses oleh ${completer}.`;
    
    return showSuccess(title, message, {
      position: 'top-center'
    });
  }, [showSuccess]);

  const value = {
    notifications,
    addNotification,
    removeNotification,
    clearAll,
    showSuccess,
    showError,
    showWarning,
    showInfo,
    showPending,
    showApproved,
    showRejected,
    showPengajuanSuccess,
    showPengajuanApproved,
    showPengajuanRejected,
    showPengajuanProcessed,
    showPengajuanCompleted
  };

  return (
    <NotificationContext.Provider value={value}>
      {children}
    </NotificationContext.Provider>
  );
};

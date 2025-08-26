import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { NotificationProvider } from './contexts/NotificationContext';
import { RiwayatProvider } from './contexts/RiwayatContext';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Profile from './pages/Profile';
import Pengajuan from './pages/Pengajuan';
import Persetujuan from './pages/Persetujuan';
import Riwayat from './pages/Riwayat';
import Pengguna from './pages/Pengguna';
import IntegrationTest from './pages/IntegrationTest';
import Layout from './components/Layout';

// Protected Route Component
const ProtectedRoute = ({ children, allowedRoles = [] }) => {
  const { user, isAuthenticated } = useAuth();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  if (allowedRoles.length > 0 && !allowedRoles.includes(user?.role)) {
    return <Navigate to="/dashboard" replace />;
  }
  
  return children;
};

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      <Route path="/dashboard" element={
        <ProtectedRoute>
          <Layout>
            <Dashboard />
          </Layout>
        </ProtectedRoute>
      } />
      <Route path="/profile" element={
        <ProtectedRoute>
          <Layout>
            <Profile />
          </Layout>
        </ProtectedRoute>
      } />
      <Route path="/pengajuan" element={
        <ProtectedRoute>
          <Layout>
            <Pengajuan />
          </Layout>
        </ProtectedRoute>
      } />
      <Route path="/persetujuan" element={
        <ProtectedRoute allowedRoles={['operator']}>
          <Layout>
            <Persetujuan />
          </Layout>
        </ProtectedRoute>
      } />
      <Route path="/riwayat" element={
        <ProtectedRoute>
          <Layout>
            <Riwayat />
          </Layout>
        </ProtectedRoute>
      } />
      <Route path="/pengguna" element={
        <ProtectedRoute allowedRoles={['operator']}>
          <Layout>
            <Pengguna />
          </Layout>
        </ProtectedRoute>
      } />
      <Route path="/integration-test" element={
        <Layout>
          <IntegrationTest />
        </Layout>
      } />
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <NotificationProvider>
        <RiwayatProvider>
          <Router>
            <AppRoutes />
          </Router>
        </RiwayatProvider>
      </NotificationProvider>
    </AuthProvider>
  );
}

export default App;

import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import api from '../services/api';

const RiwayatContext = createContext();

export const useRiwayatContext = () => {
  const context = useContext(RiwayatContext);
  if (!context) {
    throw new Error('useRiwayatContext must be used within a RiwayatProvider');
  }
  return context;
};

export const RiwayatProvider = ({ children }) => {
  const [riwayatList, setRiwayatList] = useState([]);
  const [filteredList, setFilteredList] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState({
    total: 0,
    pending: 0,
    approved: 0,
    rejected: 0
  });

  // Helper function to map backend status to frontend status
  const mapStatusToFrontend = (backendStatus) => {
    const statusMap = {
      'DIAJUKAN': 'pending',
      'DISETUJUI': 'approved',
      'DITOLAK': 'rejected',
      'DIPROSES': 'processing',
      'SELESAI': 'completed'
    };
    return statusMap[backendStatus] || backendStatus;
  };

  // Load riwayat data
  const loadRiwayatData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Call actual API
      const response = await api.getAllRequests();
      const data = response.data || [];
      
      // Transform data to match frontend expectations
      const transformedData = data.map(item => ({
        id: item.id,
        jenis_request: item.jenis_request,
        unit: item.unit,
        pemohon: item.requested_by,
        tanggalPengajuan: item.tgl_request,
        status: mapStatusToFrontend(item.status_request),
        approver: item.approved_by,
        nama_barang: item.nama_barang,
        type_model: item.type_model,
        jumlah: item.jumlah,
        lokasi: item.lokasi,
        jenis_pekerjaan: item.jenis_pekerjaan,
        kegunaan: item.kegunaan,
        tgl_peminjaman: item.tgl_peminjaman,
        tgl_pengembalian: item.tgl_pengembalian,
        keterangan: item.keterangan,
        created_at: item.created_at,
        updated_at: item.updated_at
      }));
      
      setRiwayatList(transformedData);
      setFilteredList(transformedData);
      
      // Calculate stats
      const statsData = {
        total: transformedData.length,
        pending: transformedData.filter(item => item.status === 'pending').length,
        approved: transformedData.filter(item => item.status === 'approved').length,
        rejected: transformedData.filter(item => item.status === 'rejected').length
      };
      setStats(statsData);
      
      return transformedData;
    } catch (error) {
      console.error('Failed to load riwayat data:', error);
      setError('Gagal memuat data riwayat');
      
      // Set empty arrays on error
      setRiwayatList([]);
      setFilteredList([]);
      setStats({ total: 0, pending: 0, approved: 0, rejected: 0 });
      
      throw error;
    } finally {
      setLoading(false);
    }
  }, []);

  // Refresh data
  const refreshData = useCallback(async () => {
    return await loadRiwayatData();
  }, [loadRiwayatData]);

  // Get dashboard stats
  const getDashboardStats = useCallback(async () => {
    try {
      // Call actual API
      const response = await api.getDashboardStats();
      return response;
    } catch (error) {
      console.error('Failed to fetch dashboard stats:', error);
      // Return fallback stats from riwayat data
      return {
        total_pengajuan: 0, // Will be updated when pengajuan API is ready
        total_persetujuan: 0, // Will be updated when persetujuan API is ready
        total_riwayat: stats.total,
        total_pengguna: 0 // Will be updated when pengguna API is ready
      };
    }
  }, [stats.total]);

  // Filter data
  const filterData = useCallback((filters) => {
    let filtered = riwayatList;

    if (filters.startDate && filters.endDate) {
      filtered = filtered.filter(item => {
        const itemDate = new Date(item.tanggalPengajuan);
        const startDate = new Date(filters.startDate);
        const endDate = new Date(filters.endDate);
        return itemDate >= startDate && itemDate <= endDate;
      });
    }

    if (filters.unit) {
      filtered = filtered.filter(item => 
        item.unit && item.unit.toLowerCase().includes(filters.unit.toLowerCase())
      );
    }

    if (filters.status) {
      filtered = filtered.filter(item => item.status === filters.status);
    }

    setFilteredList(filtered);
    return filtered;
  }, [riwayatList]);

  // Search data
  const searchData = useCallback((searchTerm) => {
    if (!searchTerm) {
      setFilteredList(riwayatList);
      return riwayatList;
    }

    const filtered = riwayatList.filter(item =>
      (item.unit && item.unit.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (item.pemohon && item.pemohon.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (item.jenis_request && item.jenis_request.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    setFilteredList(filtered);
    return filtered;
  }, [riwayatList]);

  // Export data
  const exportData = useCallback(() => {
    if (filteredList.length === 0) {
      throw new Error('Tidak ada data yang dapat diexport');
    }

    const exportData = filteredList.map(item => ({
      ID: item.id,
      'Jenis Request': item.jenis_request || '',
      Unit: item.unit || '',
      Pemohon: item.pemohon || '',
      'Tanggal Pengajuan': item.tanggalPengajuan || '',
      Status: item.status || '',
      Approver: item.approver || ''
    }));

    const headers = Object.keys(exportData[0]).join(',');
    const csvContent = [headers, ...exportData.map(row => Object.values(row).join(','))].join('\n');
    
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `riwayat-pengajuan-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
    
    return exportData.length;
  }, [filteredList]);

  // Load initial data
  useEffect(() => {
    loadRiwayatData();
  }, [loadRiwayatData]);

  const value = {
    // State
    riwayatList,
    filteredList,
    loading,
    error,
    stats,
    
    // Actions
    loadRiwayatData,
    refreshData,
    getDashboardStats,
    filterData,
    searchData,
    exportData,
    
    // Setters
    setFilteredList,
    setError
  };

  return (
    <RiwayatContext.Provider value={value}>
      {children}
    </RiwayatContext.Provider>
  );
};

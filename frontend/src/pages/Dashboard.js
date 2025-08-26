import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { useRiwayatContext } from '../contexts/RiwayatContext';
import api from '../services/api';
import { 
  FileText, 
  CheckCircle, 
  History, 
  Users, 
  Plus,
  Calendar,
  Building2,
  Loader2
} from 'lucide-react';

const Dashboard = () => {
  const { user } = useAuth();
  const { getDashboardStats } = useRiwayatContext();
  const [stats, setStats] = useState({
    pengajuan: 0,
    persetujuan: 0,
    riwayat: 0,
    pengguna: 0
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Fetch dashboard stats from RiwayatContext
    const fetchDashboardStats = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await getDashboardStats();
        setStats({
          pengajuan: response.total_pengajuan || 0,
          persetujuan: response.total_persetujuan || 0,
          riwayat: response.total_riwayat || 0,
          pengguna: response.total_pengguna || 0
        });
      } catch (error) {
        console.error('Failed to fetch dashboard stats:', error);
        setError('Gagal memuat data dashboard');
        // Fallback to default values
        setStats({
          pengajuan: 0,
          persetujuan: 0,
          riwayat: 0,
          pengguna: 0
        });
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchDashboardStats();
    }
  }, [user, getDashboardStats]);

  const StatCard = ({ title, value, icon: Icon, color, href }) => (
    <div className={`bg-white overflow-hidden shadow rounded-lg ${href ? 'cursor-pointer hover:shadow-md transition-shadow' : ''}`}>
      {href ? (
        <Link to={href} className="block p-5">
          <div className="flex items-center">
            <div className={`flex-shrink-0 rounded-md p-3 ${color}`}>
              <Icon className="h-6 w-6 text-white" />
            </div>
            <div className="ml-5 w-0 flex-1">
              <dl>
                <dt className="text-sm font-medium text-gray-500 truncate">{title}</dt>
                <dd className="text-lg font-medium text-gray-900">{value}</dd>
              </dl>
            </div>
          </div>
        </Link>
      ) : (
        <div className="p-5">
          <div className="flex items-center">
            <div className={`flex-shrink-0 rounded-md p-3 ${color}`}>
              <Icon className="h-6 w-6 text-white" />
            </div>
            <div className="ml-5 w-0 flex-1">
              <dl>
                <dt className="text-sm font-medium text-gray-500 truncate">{title}</dt>
                <dd className="text-lg font-medium text-gray-900">{value}</dd>
              </dl>
            </div>
          </div>
        </div>
      )}
    </div>
  );

  const QuickActionCard = ({ title, description, icon: Icon, href, color }) => (
    <Link to={href} className="block">
      <div className="bg-white overflow-hidden shadow rounded-lg hover:shadow-md transition-shadow">
        <div className="p-5">
          <div className="flex items-center">
            <div className={`flex-shrink-0 rounded-md p-3 ${color}`}>
              <Icon className="h-6 w-6 text-white" />
            </div>
            <div className="ml-5 w-0 flex-1">
              <h3 className="text-lg font-medium text-gray-900">{title}</h3>
              <p className="text-sm text-gray-500">{description}</p>
            </div>
            <div className="flex-shrink-0">
              <Plus className="h-5 w-5 text-gray-400" />
            </div>
          </div>
        </div>
      </div>
    </Link>
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-500">
          Selamat datang kembali, {user?.name}. Berikut adalah ringkasan aktivitas Anda.
        </p>
        
        {/* Loading and Error States */}
        {loading && (
          <div className="mt-4 flex items-center text-blue-600">
            <Loader2 className="h-4 w-4 animate-spin mr-2" />
            <span className="text-sm">Memuat data dashboard...</span>
          </div>
        )}
        
        {error && (
          <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-md">
            <p className="text-sm text-red-600">{error}</p>
          </div>
        )}
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Pengajuan"
          value={stats.pengajuan}
          icon={FileText}
          color="bg-blue-500"
          href="/pengajuan"
        />
        {user?.role === 'operator' && (
          <StatCard
            title="Total Persetujuan"
            value={stats.persetujuan}
            icon={CheckCircle}
            color="bg-green-500"
            href="/persetujuan"
          />
        )}
        <StatCard
          title="Total Riwayat"
          value={stats.riwayat}
          icon={History}
          color="bg-purple-500"
          href="/riwayat"
        />
        {user?.role === 'operator' && (
          <StatCard
            title="Total Pengguna"
            value={stats.pengguna}
            icon={Users}
            color="bg-indigo-500"
            href="/pengguna"
          />
        )}
      </div>

      {/* Quick Actions */}
      <div>
        <h2 className="text-lg font-medium text-gray-900 mb-4">Aksi Cepat</h2>
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <QuickActionCard
            title="Buat Pengajuan Baru"
            description="Ajukan permintaan kerja baru"
            icon={FileText}
            href="/pengajuan"
            color="bg-blue-500"
          />
          <QuickActionCard
            title="Lihat Riwayat"
            description="Cek status pengajuan sebelumnya"
            icon={History}
            href="/riwayat"
            color="bg-purple-500"
          />
          {user?.role === 'operator' && (
            <>
              <QuickActionCard
                title="Kelola Persetujuan"
                description="Review dan approve pengajuan"
                icon={CheckCircle}
                href="/persetujuan"
                color="bg-green-500"
              />
              <QuickActionCard
                title="Kelola Pengguna"
                description="Tambah dan update pengguna"
                icon={Users}
                href="/pengguna"
                color="bg-indigo-500"
              />
            </>
          )}
        </div>
      </div>

      {/* Recent Activity */}
      <div>
        <h2 className="text-lg font-medium text-gray-900 mb-4">Aktivitas Terbaru</h2>
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="space-y-4">
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center">
                    <FileText className="h-4 w-4 text-blue-600" />
                  </div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900">
                    Pengajuan baru dari {user?.unit}
                  </p>
                  <p className="text-sm text-gray-500">
                    Maintenance server - {new Date().toLocaleDateString('id-ID')}
                  </p>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 rounded-full bg-green-100 flex items-center justify-center">
                    <CheckCircle className="h-4 w-4 text-green-600" />
                  </div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900">
                    Pengajuan disetujui
                  </p>
                  <p className="text-sm text-gray-500">
                    Pembelian laptop - {new Date(Date.now() - 86400000).toLocaleDateString('id-ID')}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;

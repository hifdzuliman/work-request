import React, { useState, useEffect } from 'react';
import useNotification from '../hooks/useNotification';
import NotificationContainer from '../components/NotificationContainer';
import { useRiwayatContext } from '../contexts/RiwayatContext';
// import api from '../services/api'; // Uncomment when API is ready
import { 
  Eye, 
  Search, 
  Filter, 
  Calendar, 
  Building2,
  FileText,
  Package,
  Hash,
  User,
  X,
  CheckCircle,
  XCircle,
  Wrench,
  MapPin,
  Clock
} from 'lucide-react';

const Riwayat = () => {
  const { showSuccess, showInfo, showWarning } = useNotification();
  const { 
    riwayatList, 
    filteredList, 
    loading, 
    error,
    loadRiwayatData, 
    refreshData, 
    filterData, 
    searchData, 
    exportData,
    setFilteredList,
    setError
  } = useRiwayatContext();
  const [selectedRiwayat, setSelectedRiwayat] = useState(null);
  const [showDetail, setShowDetail] = useState(false);
  const [showFilter, setShowFilter] = useState(false);
  const [filters, setFilters] = useState({
    startDate: '',
    endDate: '',
    unit: '',
    status: ''
  });

  useEffect(() => {
    // Show notification for data loaded from context
    if (riwayatList.length > 0) {
      showSuccess(
        'Data Dimuat',
        `Berhasil memuat ${riwayatList.length} data riwayat pengajuan.`
      );
    } else if (!loading && !error) {
      showInfo(
        'Data Kosong',
        'Belum ada data riwayat pengajuan yang tersedia.'
      );
    }
    
    // Show error notification if there's an error
    if (error) {
      showWarning(
        'Gagal Memuat Data',
        error
      );
    }
  }, [riwayatList.length, loading, error, showSuccess, showInfo, showWarning]);

  const handleViewDetail = (riwayat) => {
    setSelectedRiwayat(riwayat);
    setShowDetail(true);
    
    // Show notification for viewing details
    showInfo(
      'Detail Dibuka',
      `Melihat detail pengajuan ${riwayat.jenis_request} dari unit ${riwayat.unit}`
    );
  };

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const applyFilters = () => {
    const filtered = filterData(filters);
    setShowFilter(false);
    
    // Show notification for filter results
    const resultCount = filtered.length;
    if (resultCount === 0) {
      showWarning(
        'Filter Diterapkan',
        'Tidak ada data yang sesuai dengan kriteria filter yang dipilih.'
      );
    } else {
      showInfo(
        'Filter Diterapkan',
        `Ditemukan ${resultCount} data yang sesuai dengan filter.`
      );
    }
  };

  const clearFilters = () => {
    setFilters({
      startDate: '',
      endDate: '',
      unit: '',
      status: ''
    });
    setFilteredList(riwayatList);
    
    // Show notification for cleared filters
    showSuccess(
      'Filter Dihapus',
      'Semua filter telah dihapus dan menampilkan semua data.'
    );
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'approved':
        return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'rejected':
        return <XCircle className="h-4 w-4 text-red-500" />;
      case 'pending':
        return <Clock className="h-4 w-4 text-yellow-500" />;
      default:
        return <Clock className="h-4 w-4 text-gray-500" />;
    }
  };

  const getStatusBadge = (status) => {
    const statusConfig = {
      'approved': { text: 'Disetujui', color: 'bg-green-100 text-green-800' },
      'rejected': { text: 'Ditolak', color: 'bg-red-100 text-red-800' },
      'pending': { text: 'Menunggu', color: 'bg-yellow-100 text-yellow-800' }
    };

    const config = statusConfig[status] || { text: 'Unknown', color: 'bg-gray-100 text-gray-800' };
    
    return (
      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${config.color}`}>
        {config.text}
      </span>
    );
  };

  const handleExportData = () => {
    try {
      const recordCount = exportData();
      
      showSuccess(
        'Export Berhasil',
        `Data berhasil diexport ke CSV dengan ${recordCount} records.`
      );
    } catch (error) {
      console.error('Export error:', error);
      showWarning(
        'Export Gagal',
        error.message || 'Terjadi kesalahan saat mengexport data. Silakan coba lagi.'
      );
    }
  };

  const handleRefreshData = async () => {
    try {
      await refreshData();
      
      showSuccess(
        'Data Diperbarui',
        'Data riwayat telah diperbarui dengan informasi terbaru.'
      );
    } catch (error) {
      console.error('Failed to refresh data:', error);
      showWarning(
        'Gagal Memperbarui Data',
        'Terjadi kesalahan saat memperbarui data. Silakan coba lagi.'
      );
    }
  };

  const getJenisRequestIcon = (jenis) => {
    switch (jenis) {
      case 'pengadaan':
        return <Package className="h-4 w-4" />;
      case 'perbaikan':
        return <Wrench className="h-4 w-4" />;
      case 'peminjaman':
        return <Calendar className="h-4 w-4" />;
      default:
        return <FileText className="h-4 w-4" />;
    }
  };

  const getJenisRequestColor = (jenis) => {
    switch (jenis) {
      case 'pengadaan':
        return 'bg-blue-500';
      case 'perbaikan':
        return 'bg-orange-500';
      case 'peminjaman':
        return 'bg-green-500';
      default:
        return 'bg-gray-500';
    }
  };

  return (
    <>
      <NotificationContainer />
      <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Riwayat Pengajuan</h1>
          <p className="mt-2 text-sm text-gray-600">
            Lihat dan kelola semua pengajuan yang telah dibuat
          </p>
        </div>

      {/* Filter and Search Bar */}
      <div className="mb-6 flex flex-col sm:flex-row gap-4">
        <div className="flex-1">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Cari berdasarkan unit, pemohon, atau kebutuhan..."
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
              onChange={(e) => {
                const searchTerm = e.target.value;
                const filtered = searchData(searchTerm);
                
                // Show search notification
                if (searchTerm && filtered.length > 0) {
                  showInfo(
                    'Pencarian Aktif',
                    `Ditemukan ${filtered.length} data yang sesuai dengan pencarian "${searchTerm}"`
                  );
                } else if (searchTerm && filtered.length === 0) {
                  showWarning(
                    'Pencarian Tidak Ditemukan',
                    `Tidak ada data yang sesuai dengan pencarian "${searchTerm}"`
                  );
                }
              }}
            />
          </div>
        </div>
        
        <button
          onClick={() => setShowFilter(true)}
          className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <Filter className="h-4 w-4 mr-2" />
          Filter
        </button>
        
        <button
          onClick={handleRefreshData}
          className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <Clock className="h-4 w-4 mr-2" />
          Refresh
        </button>
        
        <button
          onClick={handleExportData}
          className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <FileText className="h-4 w-4 mr-2" />
          Export CSV
        </button>
      </div>

      {/* Filter Modal */}
      {showFilter && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-md shadow-lg rounded-md bg-white">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">Filter Riwayat</h3>
              <button
                onClick={() => setShowFilter(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Rentang Tanggal</label>
                <div className="grid grid-cols-2 gap-2">
                  <input
                    type="date"
                    name="startDate"
                    value={filters.startDate}
                    onChange={handleFilterChange}
                    className="block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm"
                  />
                  <input
                    type="date"
                    name="endDate"
                    value={filters.endDate}
                    onChange={handleFilterChange}
                    className="block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm"
                  />
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Unit</label>
                <input
                  type="text"
                  name="unit"
                  value={filters.unit}
                  onChange={handleFilterChange}
                  placeholder="Masukkan nama unit"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Status</label>
                <select
                  name="status"
                  value={filters.status}
                  onChange={handleFilterChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm"
                >
                  <option value="">Semua Status</option>
                  <option value="pending">Menunggu</option>
                  <option value="approved">Disetujui</option>
                  <option value="rejected">Ditolak</option>
                </select>
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 mt-6">
              <button
                onClick={clearFilters}
                className="px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
              >
                Reset
              </button>
              <button
                onClick={applyFilters}
                className="px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700"
              >
                Terapkan
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Riwayat List */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Jenis
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Unit
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Pemohon
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Kebutuhan
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tanggal Pengajuan
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Approver
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Action
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredList.map((riwayat) => (
                  <tr key={riwayat.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center space-x-2">
                        <div className={`inline-flex h-6 w-6 rounded-full ${getJenisRequestColor(riwayat.jenis_request)} items-center justify-center text-white`}>
                          {getJenisRequestIcon(riwayat.jenis_request)}
                        </div>
                        <span className="text-sm font-medium text-gray-900 capitalize">
                          {riwayat.jenis_request}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {riwayat.unit}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {riwayat.pemohon}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {riwayat.jenis_request === 'pengadaan' && riwayat.nama_barang_array?.[0] 
                          ? riwayat.nama_barang_array[0]
                          : riwayat.jenis_request === 'perbaikan' && riwayat.nama_barang_array?.[0]
                          ? riwayat.nama_barang_array[0]
                          : riwayat.jenis_request === 'peminjaman' && riwayat.lokasi_array?.[0]
                          ? riwayat.lokasi_array[0]
                          : 'N/A'
                        }
                      </div>
                      {riwayat.jenis_request === 'pengadaan' && riwayat.nama_barang_array?.length > 1 && (
                        <div className="text-xs text-gray-400">
                          +{riwayat.nama_barang_array.length - 1} barang lainnya
                        </div>
                      )}
                      {riwayat.jenis_request === 'perbaikan' && riwayat.nama_barang_array?.length > 1 && (
                        <div className="text-xs text-gray-400">
                          +{riwayat.nama_barang_array.length - 1} barang lainnya
                        </div>
                      )}
                      {riwayat.jenis_request === 'peminjaman' && riwayat.lokasi_array?.length > 1 && (
                        <div className="text-xs text-gray-400">
                          +{riwayat.lokasi_array.length - 1} lokasi lainnya
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {new Date(riwayat.tanggalPengajuan).toLocaleDateString('id-ID')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center space-x-2">
                        {getStatusIcon(riwayat.status)}
                        {getStatusBadge(riwayat.status)}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {riwayat.approver || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <button
                        onClick={() => handleViewDetail(riwayat)}
                        className="text-primary-600 hover:text-primary-900 inline-flex items-center"
                      >
                        <Eye className="h-4 w-4 mr-1" />
                        Detail
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          
          {filteredList.length === 0 && (
            <div className="text-center py-8">
              <p className="text-gray-500">Tidak ada data yang ditemukan</p>
            </div>
          )}
        </div>
      </div>

      {/* Detail Riwayat Modal */}
      {showDetail && selectedRiwayat && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">Detail Riwayat</h3>
              <button
                onClick={() => setShowDetail(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>
            
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center space-x-2">
                  <div className={`inline-flex h-6 w-6 rounded-full ${getJenisRequestColor(selectedRiwayat.jenis_request)} items-center justify-center text-white`}>
                    {getJenisRequestIcon(selectedRiwayat.jenis_request)}
                  </div>
                  <span className="text-sm font-medium text-gray-500">Jenis:</span>
                  <span className="text-sm text-gray-900 capitalize">{selectedRiwayat.jenis_request}</span>
                </div>
                
                <div className="flex items-center space-x-2">
                  <Building2 className="h-4 w-4 text-gray-400" />
                  <span className="text-sm font-medium text-gray-500">Unit:</span>
                  <span className="text-sm text-gray-900">{selectedRiwayat.unit}</span>
                </div>
                
                <div className="flex items-center space-x-2">
                  <User className="h-4 w-4 text-gray-400" />
                  <span className="text-sm font-medium text-gray-500">Pemohon:</span>
                  <span className="text-sm text-gray-900">{selectedRiwayat.pemohon}</span>
                </div>
                
                <div className="flex items-center space-x-2">
                  <Calendar className="h-4 w-4 text-gray-400" />
                  <span className="text-sm font-medium text-gray-500">Tanggal Pengajuan:</span>
                  <span className="text-sm text-gray-900">
                    {new Date(selectedRiwayat.tanggalPengajuan).toLocaleDateString('id-ID')}
                  </span>
                </div>
                
                <div className="flex items-center space-x-2">
                  <User className="h-4 w-4 text-gray-400" />
                  <span className="text-sm font-medium text-gray-500">Approver:</span>
                  <span className="text-sm text-gray-900">{selectedRiwayat.approver || '-'}</span>
                </div>
              </div>

              {/* Activities Detail */}
              <div className="space-y-4">
                <h4 className="text-md font-medium text-gray-900">Detail Kebutuhan</h4>
                
                {selectedRiwayat.jenis_request === 'pengadaan' && (
                  <div className="space-y-3">
                    {selectedRiwayat.nama_barang_array?.map((item, itemIndex) => (
                      <div key={itemIndex} className="border border-gray-200 rounded-lg p-4 space-y-2">
                        <div className="grid grid-cols-3 gap-4 text-sm">
                          <div className="flex items-center space-x-2">
                            <Package className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Nama Barang:</span>
                            <span className="text-gray-900">{item}</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <Hash className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Jumlah:</span>
                            <span className="text-gray-900">{selectedRiwayat.jumlah_array?.[itemIndex] || '-'}</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <FileText className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Keterangan:</span>
                            <span className="text-gray-900">{selectedRiwayat.keterangan_array?.[itemIndex] || '-'}</span>
                          </div>
                        </div>
                        {selectedRiwayat.type_model_array?.[itemIndex] && (
                          <div className="text-sm text-gray-600">
                            <span className="font-medium">Type/Model:</span> {selectedRiwayat.type_model_array[itemIndex]}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}

                {selectedRiwayat.jenis_request === 'perbaikan' && (
                  <div className="space-y-3">
                    {selectedRiwayat.nama_barang_array?.map((item, itemIndex) => (
                      <div key={itemIndex} className="border border-gray-200 rounded-lg p-4 space-y-2">
                        <div className="grid grid-cols-3 gap-4 text-sm">
                          <div className="flex items-center space-x-2">
                            <Package className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Nama Barang:</span>
                            <span className="text-gray-900">{item}</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <Hash className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Jumlah:</span>
                            <span className="text-gray-900">{selectedRiwayat.jumlah_array?.[itemIndex] || '-'}</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <Wrench className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Jenis Pekerjaan:</span>
                            <span className="text-gray-900">{selectedRiwayat.jenis_pekerjaan_array?.[itemIndex] || '-'}</span>
                          </div>
                        </div>
                        {selectedRiwayat.type_model_array?.[itemIndex] && (
                          <div className="text-sm text-gray-600">
                            <span className="font-medium">Type/Model:</span> {selectedRiwayat.type_model_array[itemIndex]}
                          </div>
                        )}
                        {selectedRiwayat.lokasi_array?.[itemIndex] && (
                          <div className="text-sm text-gray-600">
                            <span className="font-medium">Lokasi:</span> {selectedRiwayat.lokasi_array[itemIndex]}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}

                {selectedRiwayat.jenis_request === 'peminjaman' && (
                  <div className="space-y-3">
                    {selectedRiwayat.lokasi_array?.map((item, itemIndex) => (
                      <div key={itemIndex} className="border border-gray-200 rounded-lg p-4 space-y-2">
                        <div className="grid grid-cols-2 gap-4 text-sm">
                          <div className="flex items-center space-x-2">
                            <MapPin className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Lokasi:</span>
                            <span className="text-gray-900">{item}</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <Calendar className="h-4 w-4 text-gray-400" />
                            <span className="text-gray-500">Tanggal:</span>
                            <span className="text-gray-900">
                              {selectedRiwayat.tgl_peminjaman_array?.[itemIndex] && selectedRiwayat.tgl_pengembalian_array?.[itemIndex] 
                                ? `${new Date(selectedRiwayat.tgl_peminjaman_array[itemIndex]).toLocaleDateString('id-ID')} - ${new Date(selectedRiwayat.tgl_pengembalian_array[itemIndex]).toLocaleDateString('id-ID')}`
                                : '-'
                              }
                            </span>
                          </div>
                        </div>
                        {selectedRiwayat.kegunaan_array?.[itemIndex] && (
                          <div className="text-sm text-gray-600">
                            <span className="font-medium">Kegunaan:</span> {selectedRiwayat.kegunaan_array[itemIndex]}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
              
              <div className="pt-4 border-t border-gray-200">
                <div className="flex items-center space-x-2">
                  <span className="text-sm font-medium text-gray-500">Status:</span>
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(selectedRiwayat.status)}
                    {getStatusBadge(selectedRiwayat.status)}
                  </div>
                </div>
              </div>

              {selectedRiwayat.catatan && (
                <div className="pt-4 border-t border-gray-200">
                  <div>
                    <span className="text-sm font-medium text-gray-500">Catatan Persetujuan:</span>
                    <p className="mt-1 text-sm text-gray-900">{selectedRiwayat.catatan}</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
      </div>
    </>
  );
};

export default Riwayat;

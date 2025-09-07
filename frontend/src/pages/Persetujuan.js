import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import useNotification from '../hooks/useNotification';
import NotificationContainer from '../components/NotificationContainer';
import api from '../services/api';
import { 
  CheckCircle, 
  XCircle, 
  Clock, 
  Package, 
  Wrench, 
  Calendar,
  Eye,
  Loader2
} from 'lucide-react';

const Persetujuan = () => {
  const { user } = useAuth();
  const { 
    showPengajuanApproved, 
    showPengajuanRejected, 
    showPengajuanProcessed, 
    showPengajuanCompleted,
    showError 
  } = useNotification();
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [showDetail, setShowDetail] = useState(false);
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    if (user?.role === 'operator') {
      loadRequests();
    }
  }, [user]);

  const loadRequests = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.getAllRequests();
      const data = response.data || response;
      setRequests(data);
    } catch (error) {
      setError('Gagal memuat data pengajuan');
      console.error('Failed to load requests:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (requestId, newStatus, keterangan = '') => {
    try {
      setUpdating(true);
      
      const updateData = {
        status_request: newStatus,
        approved_by: user?.name,
        keterangan: keterangan
      };

      await api.updateRequestStatus(requestId, updateData);
      
      // Show appropriate notification based on status
      const request = requests.find(r => r.id === requestId);
      if (request) {
        switch (newStatus) {
          case 'DISETUJUI':
            showPengajuanApproved(request.jenis_request, user?.name);
            break;
          case 'DITOLAK':
            showPengajuanRejected(request.jenis_request, user?.name, keterangan);
            break;
          case 'DIPROSES':
            showPengajuanProcessed(request.jenis_request, user?.name);
            break;
          case 'SELESAI':
            showPengajuanCompleted(request.jenis_request, user?.name);
            break;
          default:
            break;
        }
      }
      
      // Reload requests
      await loadRequests();
      
      // Close detail modal
      setShowDetail(false);
      setSelectedRequest(null);
      
    } catch (error) {
      console.error('Failed to update request status:', error);
      showError(
        'Gagal Mengupdate Status',
        'Terjadi kesalahan saat mengupdate status pengajuan. Silakan coba lagi.'
      );
    } finally {
      setUpdating(false);
    }
  };

  const getStatusBadge = (status) => {
    const statusConfig = {
      'DIAJUKAN': { color: 'bg-yellow-100 text-yellow-800', icon: Clock, text: 'Diajukan' },
      'DISETUJUI': { color: 'bg-green-100 text-green-800', icon: CheckCircle, text: 'Disetujui' },
      'DITOLAK': { color: 'bg-red-100 text-red-800', icon: XCircle, text: 'Ditolak' },
      'DIPROSES': { color: 'bg-blue-100 text-blue-800', icon: Clock, text: 'Diproses' },
      'SELESAI': { color: 'bg-gray-100 text-gray-800', icon: CheckCircle, text: 'Selesai' }
    };
    
    const config = statusConfig[status] || statusConfig['DIAJUKAN'];
    const Icon = config.icon;
    
    return (
      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${config.color}`}>
        <Icon className="h-3 w-3 mr-1" />
        {config.text}
      </span>
    );
  };

  const getJenisRequestIcon = (jenis) => {
    switch (jenis) {
      case 'pengadaan':
        return <Package className="h-5 w-5" />;
      case 'perbaikan':
        return <Wrench className="h-5 w-5" />;
      case 'peminjaman':
        return <Calendar className="h-5 w-5" />;
      default:
        return <Package className="h-5 w-5" />;
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

  const handleViewDetail = (request) => {
    setSelectedRequest(request);
    setShowDetail(true);
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('id-ID');
  };

  // Filter requests that need approval (DIAJUKAN status)
  const pendingRequests = Array.isArray(requests) ? requests.filter(req => req.status_request === 'DIAJUKAN') : [];
  
  // For debugging - show all requests
  const [showAllRequests, setShowAllRequests] = useState(false);
  const displayRequests = showAllRequests ? requests : pendingRequests;

  if (user?.role !== 'operator') {
    return (
      <div className="text-center py-12">
        <div className="mx-auto h-12 w-12 text-gray-400">
          <XCircle className="h-12 w-12" />
        </div>
        <h3 className="mt-2 text-sm font-medium text-gray-900">Akses Ditolak</h3>
        <p className="mt-1 text-sm text-gray-500">
          Halaman ini hanya dapat diakses oleh operator.
        </p>
      </div>
    );
  }

  return (
    <>
      <NotificationContainer />
      <div className="space-y-6">
        {/* Header */}
        <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Persetujuan Pengajuan</h1>
          <p className="mt-1 text-sm text-gray-500">
            Review dan approve pengajuan dari berbagai unit
          </p>
        </div>
          <div className="flex space-x-2">
            <button
              onClick={() => setShowAllRequests(!showAllRequests)}
              className={`px-3 py-1 text-xs font-medium rounded-md ${
                showAllRequests 
                  ? 'bg-blue-100 text-blue-800' 
                  : 'bg-gray-100 text-gray-800'
              }`}
            >
              {showAllRequests ? 'Show Pending Only' : 'Show All Requests'}
            </button>
          </div>
        </div>


      {/* Stats */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 rounded-full bg-yellow-100 flex items-center justify-center">
                  <Clock className="h-5 w-5 text-yellow-600" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Menunggu Persetujuan</dt>
                  <dd className="text-lg font-medium text-gray-900">{pendingRequests.length}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 rounded-full bg-green-100 flex items-center justify-center">
                  <CheckCircle className="h-5 w-5 text-green-600" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Total Disetujui</dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {Array.isArray(requests) ? requests.filter(req => req.status_request === 'DISETUJUI').length : 0}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 rounded-full bg-red-100 flex items-center justify-center">
                  <XCircle className="h-5 w-5 text-red-600" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Total Ditolak</dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {Array.isArray(requests) ? requests.filter(req => req.status_request === 'DITOLAK').length : 0}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-md">
          <p className="text-sm text-red-600">{error}</p>
        </div>
      )}

      {/* Requests List */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">
            {showAllRequests ? 'Semua Pengajuan' : 'Pengajuan Menunggu Persetujuan'}
          </h3>

          {loading ? (
            <div className="text-center py-8">
              <Loader2 className="mx-auto h-8 w-8 animate-spin text-gray-400" />
              <p className="mt-2 text-sm text-gray-500">Memuat data...</p>
            </div>
          ) : displayRequests.length === 0 ? (
            <div className="text-center py-8">
              <CheckCircle className="mx-auto h-12 w-12 text-green-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                {showAllRequests ? 'Tidak ada pengajuan' : 'Tidak ada pengajuan'}
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                {showAllRequests ? 'Belum ada pengajuan yang dibuat.' : 'Semua pengajuan telah diproses.'}
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Jenis Request
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Unit
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Nama Barang
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Pemohon
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Tanggal
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Action
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {displayRequests.map((request) => (
                    <tr key={request.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className={`flex-shrink-0 h-8 w-8 rounded-full ${getJenisRequestColor(request.jenis_request)} flex items-center justify-center text-white`}>
                            {getJenisRequestIcon(request.jenis_request)}
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900 capitalize">
                              {request.jenis_request}
                            </div>
                            <div className="text-sm text-gray-500">
                              {request.nama_barang}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {request.unit}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{request.nama_barang}</div>
                        {request.type_model && (
                          <div className="text-sm text-gray-500">{request.type_model}</div>
                        )}
                        <div className="text-sm text-gray-500">Jumlah: {request.jumlah}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {request.requested_by}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        {getStatusBadge(request.status_request)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {formatDate(request.tgl_request)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          onClick={() => handleViewDetail(request)}
                          className="text-blue-600 hover:text-blue-900 inline-flex items-center"
                        >
                          <Eye className="h-4 w-4 mr-1" />
                          Review
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Detail Modal */}
      {showDetail && selectedRequest && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-4xl shadow-lg rounded-md bg-white max-h-[80vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">Detail Pengajuan</h3>
              <button
                onClick={() => setShowDetail(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <XCircle className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-6">
              {/* Basic Info */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-500">Jenis Request</label>
                  <div className="mt-1 flex items-center">
                    <div className={`inline-flex h-6 w-6 rounded-full ${getJenisRequestColor(selectedRequest.jenis_request)} items-center justify-center text-white mr-2`}>
                      {getJenisRequestIcon(selectedRequest.jenis_request)}
                    </div>
                    <span className="text-sm font-medium text-gray-900 capitalize">
                      {selectedRequest.jenis_request}
                    </span>
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Status</label>
                  <div className="mt-1">
                    {getStatusBadge(selectedRequest.status_request)}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Unit</label>
                  <div className="mt-1 text-sm text-gray-900">{selectedRequest.unit}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Pemohon</label>
                  <div className="mt-1 text-sm text-gray-900">{selectedRequest.requested_by}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Tanggal Request</label>
                  <div className="mt-1 text-sm text-gray-900">{formatDate(selectedRequest.tgl_request)}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Lokasi</label>
                  <div className="mt-1 text-sm text-gray-900">{selectedRequest.lokasi}</div>
                </div>
              </div>

              {/* Item Details */}
              <div>
                <label className="block text-sm font-medium text-gray-500">Detail Barang</label>
                <div className="mt-1 space-y-4">
                  {/* Pengadaan Request */}
                  {selectedRequest.jenis_request === 'pengadaan' && (
                    <div className="bg-blue-50 p-4 rounded-md">
                      <h4 className="text-sm font-medium text-blue-700 mb-3">Detail Pengadaan</h4>
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <span className="text-sm font-medium text-gray-500">Nama Barang:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.nama_barang || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Type/Model:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.type_model || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Jumlah:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.jumlah || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Lokasi:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.lokasi || '-'}</div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Perbaikan Request */}
                  {selectedRequest.jenis_request === 'perbaikan' && (
                    <div className="bg-orange-50 p-4 rounded-md">
                      <h4 className="text-sm font-medium text-orange-700 mb-3">Detail Perbaikan</h4>
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <span className="text-sm font-medium text-gray-500">Nama Barang:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.nama_barang || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Type/Model:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.type_model || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Jumlah:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.jumlah || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Lokasi:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.lokasi || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Jenis Pekerjaan:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.jenis_pekerjaan || '-'}</div>
                </div>
              </div>
                    </div>
                  )}

                  {/* Peminjaman Request */}
                  {selectedRequest.jenis_request === 'peminjaman' && (
                    <div className="bg-green-50 p-4 rounded-md">
                      <h4 className="text-sm font-medium text-green-700 mb-3">Detail Peminjaman</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                          <span className="text-sm font-medium text-gray-500">Lokasi:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.lokasi || '-'}</div>
                        </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Tanggal Peminjaman:</span>
                          <div className="text-sm text-gray-900">{formatDate(selectedRequest.tgl_peminjaman)}</div>
                      </div>
                      <div>
                          <span className="text-sm font-medium text-gray-500">Tanggal Pengembalian:</span>
                          <div className="text-sm text-gray-900">{formatDate(selectedRequest.tgl_pengembalian)}</div>
                      </div>
                        <div>
                          <span className="text-sm font-medium text-gray-500">Kegunaan:</span>
                          <div className="text-sm text-gray-900">{selectedRequest.kegunaan || '-'}</div>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </div>


              {/* Keterangan */}
              <div>
                <label className="block text-sm font-medium text-gray-500">Keterangan</label>
                <div className="mt-1 text-sm text-gray-900">{selectedRequest.keterangan}</div>
              </div>

              {/* Approval Actions */}
              <div className="pt-4 border-t border-gray-200">
                <div className="flex justify-end space-x-3">
                  <button
                    onClick={() => handleStatusUpdate(selectedRequest.id, 'DITOLAK', 'Ditolak oleh operator')}
                    disabled={updating}
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50"
                  >
                    {updating ? (
                      <>
                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        Memproses...
                      </>
                    ) : (
                      <>
                        <XCircle className="h-4 w-4 mr-2" />
                        Tolak
                      </>
                    )}
                  </button>
                  <button
                    onClick={() => handleStatusUpdate(selectedRequest.id, 'DISETUJUI', 'Disetujui oleh operator')}
                    disabled={updating}
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
                  >
                    {updating ? (
                      <>
                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        Memproses...
                      </>
                    ) : (
                      <>
                        <CheckCircle className="h-4 w-4 mr-2" />
                        Setujui
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
      </div>
    </>
  );
};

export default Persetujuan;

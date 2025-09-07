import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import { 
  FileText, 
  Package, 
  Wrench, 
  Calendar,
  MapPin,
  User,
  Save,
  X,
  Plus,
  Trash2
} from 'lucide-react';

const Pengajuan = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  const [formData, setFormData] = useState({
    jenis_request: 'pengadaan',
    // For pengadaan: array fields
    nama_barang_array: [''],
    type_model_array: [''],
    jumlah_array: [1],
    keterangan_array: [''],
    // For perbaikan: array fields (updated to support multiple items)
    nama_barang_perbaikan_array: [''],
    type_model_perbaikan_array: [''],
    jumlah_perbaikan_array: [1],
    jenis_pekerjaan_array: [''],
    lokasi_perbaikan_array: [''],
    // For peminjaman: array fields (updated to support multiple items)
    lokasi_peminjaman_array: [''],
    kegunaan_array: [''],
    tgl_peminjaman_array: [''],
    tgl_pengembalian_array: [''],
    // Legacy single fields for backward compatibility
    nama_barang: '',
    type_model: '',
    jumlah: 1,
    jenis_pekerjaan: '',
    lokasi: '',
    kegunaan: '',
    tgl_peminjaman: '',
    tgl_pengembalian: '',
    keterangan: ''
  });

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  // Handle array field changes for pengadaan
  const handleArrayFieldChange = (field, index, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: prev[field].map((item, i) => i === index ? value : item)
    }));
  };

  // Add new item row for pengadaan
  const addItemRow = () => {
    setFormData(prev => ({
      ...prev,
      nama_barang_array: [...prev.nama_barang_array, ''],
      type_model_array: [...prev.type_model_array, ''],
      jumlah_array: [...prev.jumlah_array, 1],
      keterangan_array: [...prev.keterangan_array, '']
    }));
  };

  // Remove item row for pengadaan
  const removeItemRow = (index) => {
    if (formData.nama_barang_array.length > 1) {
      setFormData(prev => ({
        ...prev,
        nama_barang_array: prev.nama_barang_array.filter((_, i) => i !== index),
        type_model_array: prev.type_model_array.filter((_, i) => i !== index),
        jumlah_array: prev.jumlah_array.filter((_, i) => i !== index),
        keterangan_array: prev.keterangan_array.filter((_, i) => i !== index)
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(false);

    try {
      // Prepare request data based on jenis_request
      let requestData = {
        jenis_request: formData.jenis_request,
        unit: user?.unit || '', // Auto-fill from logged in user
        tgl_request: new Date().toISOString().split('T')[0], // Auto-fill current date
        keterangan: formData.keterangan
      };

      if (formData.jenis_request === 'pengadaan') {
        // For pengadaan: use array fields AND single fields for backward compatibility
        const filteredNamaBarang = formData.nama_barang_array.filter(item => item.trim() !== '');
        const filteredTypeModel = formData.type_model_array.filter(item => item.trim() !== '');
        const filteredJumlah = formData.jumlah_array.filter((item, index) => formData.nama_barang_array[index].trim() !== '');
        const filteredKeterangan = formData.keterangan_array.filter(item => item.trim() !== '');
        
        requestData = {
          ...requestData,
          // Array fields
          nama_barang_array: filteredNamaBarang,
          type_model_array: filteredTypeModel,
          jumlah_array: filteredJumlah,
          keterangan_array: filteredKeterangan,
          // Single fields for backward compatibility (use first item from arrays)
          nama_barang: filteredNamaBarang[0] || '',
          type_model: filteredTypeModel[0] || '',
          jumlah: filteredJumlah[0] || 1,
          lokasi: '' // Pengadaan doesn't have lokasi field
        };
      } else if (formData.jenis_request === 'perbaikan') {
        // For perbaikan: use array fields (new approach)
        requestData = {
          ...requestData,
          nama_barang_array: formData.nama_barang_perbaikan_array.filter(item => item.trim() !== ''),
          type_model_array: formData.type_model_perbaikan_array.filter(item => item.trim() !== ''),
          jumlah_array: formData.jumlah_perbaikan_array.filter((item, index) => formData.nama_barang_perbaikan_array[index].trim() !== ''),
          jenis_pekerjaan_array: formData.jenis_pekerjaan_array.filter(item => item.trim() !== ''),
          lokasi_array: formData.lokasi_perbaikan_array.filter(item => item.trim() !== ''),
          // Legacy fields for backward compatibility
          nama_barang: formData.nama_barang_perbaikan_array[0] || '',
          type_model: formData.type_model_perbaikan_array[0] || '',
          jumlah: formData.jumlah_perbaikan_array[0] || 1,
          jenis_pekerjaan: formData.jenis_pekerjaan_array[0] || '',
          lokasi: formData.lokasi_perbaikan_array[0] || ''
        };
      } else if (formData.jenis_request === 'peminjaman') {
        // For peminjaman: use array fields (new approach)
        requestData = {
          ...requestData,
          lokasi_array: formData.lokasi_peminjaman_array.filter(item => item.trim() !== ''),
          kegunaan_array: formData.kegunaan_array.filter(item => item.trim() !== ''),
          tgl_peminjaman_array: formData.tgl_peminjaman_array.filter(item => item.trim() !== ''),
          tgl_pengembalian_array: formData.tgl_pengembalian_array.filter(item => item.trim() !== ''),
          // Legacy fields for backward compatibility
          lokasi: formData.lokasi_peminjaman_array[0] || '',
          kegunaan: formData.kegunaan_array[0] || '',
          tgl_peminjaman: formData.tgl_peminjaman_array[0] || null,
          tgl_pengembalian: formData.tgl_pengembalian_array[0] || null
        };
      }

      const response = await api.createRequest(requestData);
      
      if (response.success) {
        setSuccess(true);
        // Reset form
        setFormData({
          jenis_request: 'pengadaan',
          nama_barang_array: [''],
          type_model_array: [''],
          jumlah_array: [1],
          keterangan_array: [''],
          nama_barang_perbaikan_array: [''],
          type_model_perbaikan_array: [''],
          jumlah_perbaikan_array: [1],
          jenis_pekerjaan_array: [''],
          lokasi_perbaikan_array: [''],
          lokasi_peminjaman_array: [''],
          kegunaan_array: [''],
          tgl_peminjaman_array: [''],
          tgl_pengembalian_array: [''],
          nama_barang: '',
          type_model: '',
          jumlah: 1,
          jenis_pekerjaan: '',
          lokasi: '',
          kegunaan: '',
          tgl_peminjaman: '',
          tgl_pengembalian: '',
          keterangan: ''
        });
        
        // Redirect to riwayat after 2 seconds
        setTimeout(() => {
          navigate('/riwayat');
        }, 2000);
      }
    } catch (error) {
      setError(error.message || 'Gagal membuat pengajuan');
    } finally {
      setLoading(false);
    }
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
        return <FileText className="h-5 w-5" />;
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
    <div className="max-w-4xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Buat Pengajuan Baru</h1>
        <p className="mt-2 text-sm text-gray-600">
          Isi form di bawah untuk membuat pengajuan baru
        </p>
      </div>

      {/* Success Message */}
      {success && (
        <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-md">
          <div className="flex">
            <div className="flex-shrink-0">
              <Save className="h-5 w-5 text-green-400" />
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-green-800">
                Pengajuan berhasil dibuat! Redirecting ke halaman riwayat...
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md">
          <div className="flex">
            <div className="flex-shrink-0">
              <X className="h-5 w-5 text-red-400" />
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-red-800">{error}</p>
            </div>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Request Type Selection */}
        <div className="bg-white shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Jenis Pengajuan</h3>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            {['pengadaan', 'perbaikan', 'peminjaman'].map((jenis) => (
              <label key={jenis} className="relative flex cursor-pointer rounded-lg border border-gray-300 bg-white p-4 shadow-sm focus:outline-none">
                <input
                  type="radio"
                  name="jenis_request"
                  value={jenis}
                  checked={formData.jenis_request === jenis}
                  onChange={handleInputChange}
                  className="sr-only"
                />
                <div className={`flex flex-1 ${formData.jenis_request === jenis ? 'border-2 border-blue-500' : ''}`}>
                  <div className="flex flex-col">
                    <div className={`inline-flex h-8 w-8 rounded-full ${getJenisRequestColor(jenis)} items-center justify-center text-white mr-3`}>
                      {getJenisRequestIcon(jenis)}
                    </div>
                    <span className="block text-sm font-medium text-gray-900 capitalize">
                      {jenis}
                    </span>
                  </div>
                </div>
              </label>
            ))}
          </div>
        </div>

        {/* Auto-filled Information Display */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h3 className="text-sm font-medium text-blue-900 mb-2">Informasi Otomatis</h3>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 text-sm">
            <div>
              <span className="font-medium text-blue-700">Unit/Departemen:</span>
              <span className="ml-2 text-blue-900">{user?.unit || 'Tidak tersedia'}</span>
            </div>
            <div>
              <span className="font-medium text-blue-700">Tanggal Request:</span>
              <span className="ml-2 text-blue-900">{new Date().toLocaleDateString('id-ID')}</span>
            </div>
          </div>
        </div>

        {/* Conditional Fields Based on Request Type */}
        {formData.jenis_request === 'pengadaan' && (
          <div className="bg-white shadow rounded-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">Daftar Barang yang Diajukan</h3>
              <button
                type="button"
                onClick={addItemRow}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                <Plus className="h-4 w-4 mr-2" />
                Tambah Barang
              </button>
            </div>
            
            <div className="space-y-4">
              {formData.nama_barang_array.map((item, index) => (
                <div key={index} className="border border-gray-200 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-sm font-medium text-gray-900">Barang #{index + 1}</h4>
                    {formData.nama_barang_array.length > 1 && (
                      <button
                        type="button"
                        onClick={() => removeItemRow(index)}
                        className="text-red-600 hover:text-red-800"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                  
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Nama Barang *
                      </label>
                      <input
                        type="text"
                        value={item}
                        onChange={(e) => handleArrayFieldChange('nama_barang_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Laptop Dell"
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Type/Model
                      </label>
                      <input
                        type="text"
                        value={formData.type_model_array[index]}
                        onChange={(e) => handleArrayFieldChange('type_model_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Dell Latitude 5520"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Jumlah *
                      </label>
                      <input
                        type="number"
                        value={formData.jumlah_array[index]}
                        onChange={(e) => handleArrayFieldChange('jumlah_array', index, parseInt(e.target.value) || 1)}
                        min="1"
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Keterangan
                      </label>
                      <input
                        type="text"
                        value={formData.keterangan_array[index]}
                        onChange={(e) => handleArrayFieldChange('keterangan_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Untuk developer team"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {formData.jenis_request === 'perbaikan' && (
          <div className="bg-white shadow rounded-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">Daftar Perbaikan yang Diajukan</h3>
              <button
                type="button"
                onClick={() => {
                  setFormData(prev => ({
                    ...prev,
                    nama_barang_perbaikan_array: [...prev.nama_barang_perbaikan_array, ''],
                    type_model_perbaikan_array: [...prev.type_model_perbaikan_array, ''],
                    jumlah_perbaikan_array: [...prev.jumlah_perbaikan_array, 1],
                    jenis_pekerjaan_array: [...prev.jenis_pekerjaan_array, ''],
                    lokasi_perbaikan_array: [...prev.lokasi_perbaikan_array, '']
                  }));
                }}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                <Plus className="h-4 w-4 mr-2" />
                Tambah Perbaikan
              </button>
            </div>
            
            <div className="space-y-4">
              {formData.nama_barang_perbaikan_array.map((item, index) => (
                <div key={index} className="border border-gray-200 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-sm font-medium text-gray-900">Perbaikan #{index + 1}</h4>
                    {formData.nama_barang_perbaikan_array.length > 1 && (
                      <button
                        type="button"
                        onClick={() => {
                          setFormData(prev => ({
                            ...prev,
                            nama_barang_perbaikan_array: prev.nama_barang_perbaikan_array.filter((_, i) => i !== index),
                            type_model_perbaikan_array: prev.type_model_perbaikan_array.filter((_, i) => i !== index),
                            jumlah_perbaikan_array: prev.jumlah_perbaikan_array.filter((_, i) => i !== index),
                            jenis_pekerjaan_array: prev.jenis_pekerjaan_array.filter((_, i) => i !== index),
                            lokasi_perbaikan_array: prev.lokasi_perbaikan_array.filter((_, i) => i !== index)
                          }));
                        }}
                        className="text-red-600 hover:text-red-800"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                  
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Nama Barang *
                      </label>
                      <input
                        type="text"
                        value={item}
                        onChange={(e) => handleArrayFieldChange('nama_barang_perbaikan_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Printer HP"
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Type/Model
                      </label>
                      <input
                        type="text"
                        value={formData.type_model_perbaikan_array[index]}
                        onChange={(e) => handleArrayFieldChange('type_model_perbaikan_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: HP LaserJet Pro"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Jumlah *
                      </label>
                      <input
                        type="number"
                        value={formData.jumlah_perbaikan_array[index]}
                        onChange={(e) => handleArrayFieldChange('jumlah_perbaikan_array', index, parseInt(e.target.value) || 1)}
                        min="1"
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Jenis Pekerjaan
                      </label>
                      <input
                        type="text"
                        value={formData.jenis_pekerjaan_array[index]}
                        onChange={(e) => handleArrayFieldChange('jenis_pekerjaan_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Ganti cartridge, service"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Lokasi *
                      </label>
                      <input
                        type="text"
                        value={formData.lokasi_perbaikan_array[index]}
                        onChange={(e) => handleArrayFieldChange('lokasi_perbaikan_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Ruang IT, Lantai 2"
                        required
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {formData.jenis_request === 'peminjaman' && (
          <div className="bg-white shadow rounded-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">Daftar Peminjaman yang Diajukan</h3>
              <button
                type="button"
                onClick={() => {
                  setFormData(prev => ({
                    ...prev,
                    lokasi_peminjaman_array: [...prev.lokasi_peminjaman_array, ''],
                    kegunaan_array: [...prev.kegunaan_array, ''],
                    tgl_peminjaman_array: [...prev.tgl_peminjaman_array, ''],
                    tgl_pengembalian_array: [...prev.tgl_pengembalian_array, '']
                  }));
                }}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                <Plus className="h-4 w-4 mr-2" />
                Tambah Peminjaman
              </button>
            </div>
            
            <div className="space-y-4">
              {formData.lokasi_peminjaman_array.map((item, index) => (
                <div key={index} className="border border-gray-200 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-sm font-medium text-gray-900">Peminjaman #{index + 1}</h4>
                    {formData.lokasi_peminjaman_array.length > 1 && (
                      <button
                        type="button"
                        onClick={() => {
                          setFormData(prev => ({
                            ...prev,
                            lokasi_peminjaman_array: prev.lokasi_peminjaman_array.filter((_, i) => i !== index),
                            kegunaan_array: prev.kegunaan_array.filter((_, i) => i !== index),
                            tgl_peminjaman_array: prev.tgl_peminjaman_array.filter((_, i) => i !== index),
                            tgl_pengembalian_array: prev.tgl_pengembalian_array.filter((_, i) => i !== index)
                          }));
                        }}
                        className="text-red-600 hover:text-red-800"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                  
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Lokasi *
                      </label>
                      <input
                        type="text"
                        value={item}
                        onChange={(e) => handleArrayFieldChange('lokasi_peminjaman_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Ruang Meeting, Kantor Pusat"
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Tanggal Peminjaman
                      </label>
                      <input
                        type="date"
                        value={formData.tgl_peminjaman_array[index]}
                        onChange={(e) => handleArrayFieldChange('tgl_peminjaman_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Tanggal Pengembalian
                      </label>
                      <input
                        type="date"
                        value={formData.tgl_pengembalian_array[index]}
                        onChange={(e) => handleArrayFieldChange('tgl_pengembalian_array', index, e.target.value)}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Kegunaan
                      </label>
                      <textarea
                        value={formData.kegunaan_array[index]}
                        onChange={(e) => handleArrayFieldChange('kegunaan_array', index, e.target.value)}
                        rows={3}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                        placeholder="Contoh: Meeting dengan client, presentasi project"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* General Keterangan */}
        <div className="bg-white shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Keterangan Umum</h3>
          <div>
            <label className="block text-sm font-medium text-gray-700">
              Keterangan Tambahan
            </label>
            <textarea
              name="keterangan"
              value={formData.keterangan}
              onChange={handleInputChange}
              rows={4}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              placeholder="Tambahkan keterangan atau catatan tambahan jika diperlukan..."
            />
          </div>
        </div>

        {/* Submit Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            disabled={loading}
            className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            {loading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Memproses...
              </>
            ) : (
              <>
                <Save className="h-4 w-4 mr-2" />
                Buat Pengajuan
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default Pengajuan;

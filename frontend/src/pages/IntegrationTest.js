import React, { useState, useEffect } from 'react';
import api from '../services/api';

const IntegrationTest = () => {
  const [healthStatus, setHealthStatus] = useState(null);
  const [testResult, setTestResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const testHealthCheck = async () => {
    setLoading(true);
    try {
      const result = await api.healthCheck();
      setHealthStatus({ success: true, data: result });
    } catch (error) {
      setHealthStatus({ success: false, error: error.message });
    } finally {
      setLoading(false);
    }
  };

  const testLogin = async () => {
    setLoading(true);
    try {
      const result = await api.login('test', 'test');
      setTestResult({ success: true, data: result });
    } catch (error) {
      setTestResult({ success: false, error: error.message });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    testHealthCheck();
  }, []);

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Integration Test</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Health Check */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-semibold mb-4">Backend Health Check</h2>
          <div className="mb-4">
            <button
              onClick={testHealthCheck}
              disabled={loading}
              className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded disabled:opacity-50"
            >
              {loading ? 'Testing...' : 'Test Health Check'}
            </button>
          </div>
          
          {healthStatus && (
            <div className={`p-3 rounded ${healthStatus.success ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
              {healthStatus.success ? (
                <div>
                  <p className="font-semibold">✅ Backend is running!</p>
                  <pre className="mt-2 text-sm">{JSON.stringify(healthStatus.data, null, 2)}</pre>
                </div>
              ) : (
                <div>
                  <p className="font-semibold">❌ Backend connection failed</p>
                  <p className="text-sm">{healthStatus.error}</p>
                </div>
              )}
            </div>
          )}
        </div>

        {/* API Test */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-semibold mb-4">API Test</h2>
          <div className="mb-4">
            <button
              onClick={testLogin}
              disabled={loading}
              className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded disabled:opacity-50"
            >
              {loading ? 'Testing...' : 'Test Login API'}
            </button>
          </div>
          
          {testResult && (
            <div className={`p-3 rounded ${testResult.success ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
              {testResult.success ? (
                <div>
                  <p className="font-semibold">✅ API call successful!</p>
                  <pre className="mt-2 text-sm">{JSON.stringify(testResult.data, null, 2)}</pre>
                </div>
              ) : (
                <div>
                  <p className="font-semibold">❌ API call failed</p>
                  <p className="text-sm">{testResult.error}</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Connection Info */}
      <div className="mt-8 bg-gray-50 p-6 rounded-lg">
        <h2 className="text-xl font-semibold mb-4">Connection Information</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
          <div>
            <p><strong>Frontend URL:</strong> {window.location.origin}</p>
            <p><strong>Backend API:</strong> {process.env.REACT_APP_API_URL || 'http://localhost:8080/api'}</p>
          </div>
          <div>
            <p><strong>Proxy:</strong> Enabled (package.json)</p>
            <p><strong>CORS:</strong> Configured in backend</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default IntegrationTest;


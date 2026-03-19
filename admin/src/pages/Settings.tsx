import { useState, useEffect } from 'react';
import { Save, Shield, Globe, Database } from 'lucide-react';
import api from '../lib/api';

export function Settings() {
  const [settings, setSettings] = useState({
    maintenanceMode: false,
    platformName: 'Loading...',
    require2FA: false,
    openRouterKeyConfigured: false
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchSettings = async () => {
      try {
        setLoading(true);
        const response = await api.get('/admin/settings');
        if (response.data.success) {
          setSettings(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching settings:", error);
        setSettings({
          maintenanceMode: false,
          platformName: 'KonnectMedia',
          require2FA: true,
          openRouterKeyConfigured: false
        });
      } finally {
        setLoading(false);
      }
    };
    fetchSettings();
  }, []);

  if (loading) return <div className="p-6 text-gray-500">Loading settings...</div>;

  return (
    <div className="space-y-6 max-w-4xl">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Platform Settings</h1>
        <button className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded shadow-sm text-sm font-medium transition-colors">
          <Save className="w-4 h-4" /> Save Changes
        </button>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 divide-y divide-gray-100">
        
        {/* General Settings */}
        <div className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Globe className="w-5 h-5 text-indigo-600" />
            <h2 className="text-lg font-bold text-gray-900">Global Configuration</h2>
          </div>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-medium text-gray-900">Maintenance Mode</h3>
                <p className="text-sm text-gray-500 mt-1">Disables user access to the app while active.</p>
              </div>
              <button aria-checked={settings.maintenanceMode} className={`${settings.maintenanceMode ? 'bg-indigo-600' : 'bg-gray-200'} relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2`}>
                <span className={`${settings.maintenanceMode ? 'translate-x-5' : 'translate-x-0'} pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out`}></span>
              </button>
            </div>
            <hr className="border-gray-100" />
            <div className="flex justify-between items-start">
              <div className="w-2/3">
                <h3 className="text-sm font-medium text-gray-900">Platform Name</h3>
                <input type="text" defaultValue={settings.platformName} className="mt-2 w-full max-w-md rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 px-3" />
              </div>
            </div>
          </div>
        </div>

        {/* Security & Access */}
        <div className="p-6 bg-gray-50/50">
          <div className="flex items-center gap-2 mb-4">
            <Shield className="w-5 h-5 text-indigo-600" />
            <h2 className="text-lg font-bold text-gray-900">Security & Roles</h2>
          </div>
          <div className="space-y-4">
            <div className="flex items-center justify-between mt-4">
              <div>
                <h3 className="text-sm font-medium text-gray-900">Two-Factor Authentication (Admin)</h3>
                <p className="text-sm text-gray-500 mt-1">Require 2FA for all admin dashboard logins.</p>
              </div>
              <button aria-checked={settings.require2FA} className={`${settings.require2FA ? 'bg-indigo-600' : 'bg-gray-200'} relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2`}>
                <span className={`${settings.require2FA ? 'translate-x-5' : 'translate-x-0'} pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out`}></span>
              </button>
            </div>
             <hr className="border-gray-200" />
            <div>
                <h3 className="text-sm font-medium text-gray-900 mb-2">Admin Accounts list</h3>
                <ul className="space-y-2 border border-gray-200 rounded-md p-3 bg-white max-w-md">
                   <li className="flex justify-between text-sm"><span className="font-medium text-gray-900">Master Admin</span><span className="text-gray-500">admin@konnect.com</span></li>
                   <li className="flex justify-between text-sm"><span className="font-medium text-gray-900">Support Staff</span><span className="text-gray-500">support@konnect.com</span></li>
                </ul>
            </div>
          </div>
        </div>

        {/* Services & Integrations */}
        <div className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Database className="w-5 h-5 text-indigo-600" />
            <h2 className="text-lg font-bold text-gray-900">External API Integrations</h2>
          </div>
          <p className="text-sm text-gray-500 mb-4">Configure credentials for platform integrations. Keys should be kept secure.</p>
          
          <div className="space-y-3 max-w-lg">
             <div className="flex border border-gray-200 rounded-md overflow-hidden bg-white">
                <span className="flex items-center px-4 bg-gray-50 border-r border-gray-200 text-sm font-semibold text-gray-700 w-32 shrink-0">OpenRouter</span>
                <input type="password" value={settings.openRouterKeyConfigured ? "************************" : "NOT CONFIGURED"} readOnly className={`flex-1 px-3 py-2 text-sm ${settings.openRouterKeyConfigured ? 'text-gray-600' : 'text-red-500 font-bold'} bg-transparent focus:outline-none`} />
                <button className="px-4 text-xs font-medium text-indigo-600 hover:bg-gray-50 border-l border-gray-200">Edit</button>
             </div>
             <div className="flex border border-gray-200 rounded-md overflow-hidden bg-white">
                <span className="flex items-center px-4 bg-gray-50 border-r border-gray-200 text-sm font-semibold text-gray-700 w-32 shrink-0">SMTP Mail</span>
                <input type="password" value="mailgun-key-abc12345" readOnly className="flex-1 px-3 py-2 text-sm text-gray-600 bg-transparent focus:outline-none" />
                <button className="px-4 text-xs font-medium text-indigo-600 hover:bg-gray-50 border-l border-gray-200">Edit</button>
             </div>
          </div>
        </div>

      </div>
    </div>
  );
}

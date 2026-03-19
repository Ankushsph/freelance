import { useState, useEffect } from 'react';
import { Search, ShieldAlert, Ban, Eye } from 'lucide-react';
import api from '../lib/api';

interface UserData {
  id: string;
  name: string;
  email: string;
  platforms: string[];
  plan: string;
  status: string;
}

export function Users() {
  const [users, setUsers] = useState<UserData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.get('/admin/users');
        if (response.data.success) {
          setUsers(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching users:", error);
        setError("Failed to load users. Using demo data.");
        // Demo data on error
        setUsers([
          { id: '1', name: 'John Doe', email: 'john@example.com', platforms: ['Instagram', 'Facebook'], plan: 'Pro', status: 'Active' },
          { id: '2', name: 'Jane Smith', email: 'jane@example.com', platforms: ['LinkedIn'], plan: 'Free', status: 'Active' },
          { id: '3', name: 'Mike Johnson', email: 'mike@example.com', platforms: ['Twitter', 'Instagram'], plan: 'Enterprise', status: 'Suspended' }
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetchUsers();
  }, []);

  if (loading) return <div className="p-6 text-gray-500">Loading users...</div>;

  return (
    <div className="space-y-6">
      {error && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4">
          <div className="flex">
            <div className="ml-3">
              <h3 className="text-sm font-medium text-yellow-800">Connection Issue</h3>
              <div className="mt-2 text-sm text-yellow-700">
                <p>{error}</p>
              </div>
            </div>
          </div>
        </div>
      )}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h1 className="text-2xl font-bold text-gray-900">Users Management</h1>
        <div className="relative">
          <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <Search className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="text"
            placeholder="Search users..."
            className="block w-full sm:w-64 rounded-md border-0 py-2 pl-10 pr-3 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 shadow-sm"
          />
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse min-w-max">
            <thead>
              <tr className="bg-gray-50 text-gray-500 text-sm uppercase tracking-wider border-b border-gray-200">
                <th className="p-4 font-medium">User Name</th>
                <th className="p-4 font-medium">Email</th>
                <th className="p-4 font-medium">Connected Platforms</th>
                <th className="p-4 font-medium">Subscription Plan</th>
                <th className="p-4 font-medium">Status</th>
                <th className="p-4 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {loading ? (
                <tr><td colSpan={6} className="p-4 text-center text-gray-500">Loading users...</td></tr>
              ) : users.length === 0 ? (
                <tr><td colSpan={6} className="p-4 text-center text-gray-500">No users found.</td></tr>
              ) : users.map((user) => (
                <tr key={user.id} className="text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                  <td className="p-4 font-medium text-gray-900">{user.name}</td>
                  <td className="p-4 text-gray-500">{user.email}</td>
                  <td className="p-4">
                    <div className="flex gap-1">
                      {user.platforms.length > 0 ? (
                        user.platforms.map((platform) => (
                          <span key={platform} className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                            {platform}
                          </span>
                        ))
                      ) : (
                        <span className="text-gray-400 italic">None</span>
                      )}
                    </div>
                  </td>
                  <td className="p-4">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${
                      user.plan === 'Pro' ? 'bg-indigo-100 text-indigo-800' :
                      user.plan === 'Enterprise' ? 'bg-purple-100 text-purple-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {user.plan}
                    </span>
                  </td>
                  <td className="p-4">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
                      user.status === 'Active' ? 'bg-green-100 text-green-800' :
                      user.status === 'Suspended' ? 'bg-red-100 text-red-800' :
                      'bg-yellow-100 text-yellow-800'
                    }`}>
                      {user.status}
                    </span>
                  </td>
                  <td className="p-4 text-right">
                    <div className="flex justify-end gap-2">
                      <button className="text-gray-400 hover:text-indigo-600 transition-colors" title="View Details">
                        <Eye className="w-4 h-4" />
                      </button>
                      <button className="text-gray-400 hover:text-yellow-600 transition-colors" title="Suspend User">
                        <Ban className="w-4 h-4" />
                      </button>
                      <button className="text-gray-400 hover:text-red-600 transition-colors" title="Delete User">
                        <ShieldAlert className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {/* Pagination stub */}
        <div className="border-t border-gray-200 px-4 py-3 flex items-center justify-between sm:px-6">
          <div className="sm:flex sm:flex-1 sm:items-center sm:justify-between">
            <div>
              <p className="text-sm text-gray-700">
                Showing <span className="font-medium">1</span> to <span className="font-medium">{users.length}</span> of <span className="font-medium">{users.length}</span> results
              </p>
            </div>
            <div>
              <nav className="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
                <button className="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0">
                  Previous
                </button>
                <button className="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0">
                  Next
                </button>
              </nav>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

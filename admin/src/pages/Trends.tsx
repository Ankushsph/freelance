import { useState, useEffect } from 'react';
import { Search, Plus, TrendingUp, TrendingDown, Minus, Edit2, Trash2 } from 'lucide-react';
import api from '../lib/api';

interface TrendData {
  _id: string;
  name: string;
  category: string;
  volume: string | number;
  sentiment: 'positive' | 'negative' | 'neutral';
  status: 'Active' | 'Promoted' | 'Inactive';
}

export function Trends() {
  const [trends, setTrends] = useState<TrendData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchTrends = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.get('/admin/trends');
        if (response.data.success) {
          setTrends(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching trends:", error);
        setError("Failed to load trends. Using demo data.");
        // Demo data on error
        setTrends([
          { _id: '1', name: '#socialmedia', volume: 15420, category: 'Marketing', sentiment: 'positive', status: 'Active' },
          { _id: '2', name: '#contentcreator', volume: 8930, category: 'Creator', sentiment: 'negative', status: 'Active' },
          { _id: '3', name: '#digitalmarketing', volume: 12100, category: 'Marketing', sentiment: 'positive', status: 'Promoted' }
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetchTrends();
  }, []);

  if (loading) return <div className="p-6 text-gray-500">Loading trends...</div>;
  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h1 className="text-2xl font-bold text-gray-900">Trends Management</h1>
        <div className="flex items-center gap-3">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
              <Search className="h-4 w-4 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search trends..."
              className="block w-full sm:w-64 rounded-md border-0 py-2 pl-10 pr-3 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 shadow-sm"
            />
          </div>
          <button className="inline-flex items-center gap-2 bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition-colors shadow-sm font-medium text-sm whitespace-nowrap">
            <Plus className="w-4 h-4" />
            Add Trend
          </button>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse min-w-max">
            <thead>
              <tr className="bg-gray-50 text-gray-500 text-sm uppercase tracking-wider border-b border-gray-200">
                <th className="p-4 font-medium">Trend Hashtag</th>
                <th className="p-4 font-medium">Category</th>
                <th className="p-4 font-medium">Global Volume</th>
                <th className="p-4 font-medium">Sentiment</th>
                <th className="p-4 font-medium">Status</th>
                <th className="p-4 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {loading ? (
                <tr><td colSpan={6} className="p-4 text-center text-gray-500">Loading trends...</td></tr>
              ) : trends.length === 0 ? (
                <tr><td colSpan={6} className="p-4 text-center text-gray-500">No trends found.</td></tr>
              ) : trends.map((trend) => (
                <tr key={trend._id} className="text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                  <td className="p-4 font-bold text-indigo-600">{trend.name}</td>
                  <td className="p-4 text-gray-600">{trend.category}</td>
                  <td className="p-4 font-medium">{trend.volume}</td>
                  <td className="p-4">
                    <span className={`inline-flex items-center gap-1 ${
                      trend.sentiment === 'positive' ? 'text-green-600' :
                      trend.sentiment === 'negative' ? 'text-red-600' :
                      'text-gray-500'
                    }`}>
                      {trend.sentiment === 'positive' && <TrendingUp className="w-4 h-4" />}
                      {trend.sentiment === 'negative' && <TrendingDown className="w-4 h-4" />}
                      {trend.sentiment === 'neutral' && <Minus className="w-4 h-4" />}
                      <span className="capitalize">{trend.sentiment}</span>
                    </span>
                  </td>
                  <td className="p-4">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
                      trend.status === 'Promoted' ? 'bg-purple-100 text-purple-800' :
                      trend.status === 'Active' ? 'bg-green-100 text-green-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {trend.status}
                    </span>
                  </td>
                  <td className="p-4 text-right">
                    <div className="flex justify-end gap-3">
                      <button className="text-gray-400 hover:text-indigo-600 transition-colors" title="Edit Trend">
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button className="text-gray-400 hover:text-red-600 transition-colors" title="Delete Trend">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

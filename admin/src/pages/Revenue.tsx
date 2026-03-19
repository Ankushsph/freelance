import { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { DollarSign, Activity, ArrowUpRight } from 'lucide-react';
import api from '../lib/api';

const revenueData = [
  { name: 'Jan', revenue: 2400 }, { name: 'Feb', revenue: 3398 }, { name: 'Mar', revenue: 4200 },
  { name: 'Apr', revenue: 5800 }, { name: 'May', revenue: 6500 }, { name: 'Jun', revenue: 8900 },
  { name: 'Jul', revenue: 9500 }, { name: 'Aug', revenue: 10200 }, { name: 'Sep', revenue: 12500 },
];

const transactions = [
  { id: 'TXN-001', user: 'johndoe@email.com', plan: 'Pro', amount: '$29.99', status: 'Completed', date: '2023-10-25' },
  { id: 'TXN-002', user: 'sarah.k@work.com', plan: 'Basic', amount: '$9.99', status: 'Completed', date: '2023-10-25' },
  { id: 'TXN-003', user: 'mike.t@agency.com', plan: 'Enterprise', amount: '$99.99', status: 'Pending', date: '2023-10-24' },
  { id: 'TXN-004', user: 'emily@brand.co', plan: 'Pro', amount: '$29.99', status: 'Failed', date: '2023-10-23' },
  { id: 'TXN-005', user: 'alex@startup.io', plan: 'Basic (Annual)', amount: '$99.99', status: 'Completed', date: '2023-10-22' },
];

export function Revenue() {
  const [data, setData] = useState({
    totalRevenueYtd: 0,
    mrr: 0,
    activePaidSubs: 0
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchRevenue = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.get('/admin/revenue');
        if (response.data.success) {
          setData(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching revenue:", error);
        setError("Failed to load revenue data. Using demo data.");
        // Demo data on error
        setData({
          totalRevenueYtd: 125000,
          mrr: 15000,
          activePaidSubs: 450
        });
      } finally {
        setLoading(false);
      }
    };
    fetchRevenue();
  }, []);

  if (loading) return <div className="p-6 text-gray-500">Loading revenue data...</div>;

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
      <h1 className="text-2xl font-bold text-gray-900">Revenue Tracking</h1>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-gray-500">Total Revenue (YTD)</p>
            <div className="flex items-baseline gap-2 mt-1">
              <p className="text-3xl font-bold text-gray-900">${data.totalRevenueYtd.toLocaleString()}</p>
              <span className="flex items-center text-sm font-medium text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
                <ArrowUpRight className="w-3 h-3 mr-1" /> +24%
              </span>
            </div>
          </div>
          <div className="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center">
            <DollarSign className="w-6 h-6 text-emerald-600" />
          </div>
        </div>
        
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-gray-500">Monthly Recurring Revenue (MRR)</p>
            <div className="flex items-baseline gap-2 mt-1">
              <p className="text-3xl font-bold text-gray-900">${data.mrr.toLocaleString()}</p>
              <span className="flex items-center text-sm font-medium text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
                <ArrowUpRight className="w-3 h-3 mr-1" /> +8%
              </span>
            </div>
          </div>
          <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center">
            <DollarSign className="w-6 h-6 text-blue-600" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-gray-500">Active Paid Subscriptions</p>
            <div className="flex items-baseline gap-2 mt-1">
              <p className="text-3xl font-bold text-gray-900">{data.activePaidSubs.toLocaleString()}</p>
              <span className="flex items-center text-sm font-medium text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
                <ArrowUpRight className="w-3 h-3 mr-1" /> +12%
              </span>
            </div>
          </div>
          <div className="w-12 h-12 rounded-full bg-purple-100 flex items-center justify-center">
            <Activity className="w-6 h-6 text-purple-600" />
          </div>
        </div>
      </div>

      {/* Chart */}
      <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
        <h2 className="text-lg font-bold text-gray-900 mb-6">Revenue Trend (Last 9 Months)</h2>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={revenueData}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E7EB" />
              <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#6B7280'}} dy={10} />
              <YAxis axisLine={false} tickLine={false} tick={{fill: '#6B7280'}} tickFormatter={(value) => `$${value/1000}k`} dx={-10} />
              <Tooltip 
                formatter={(value: any) => [`$${value}`, 'Revenue']}
                contentStyle={{borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)'}}
              />
              <Line type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={3} dot={{r: 4, fill: '#10b981', strokeWidth: 2, stroke: '#fff'}} activeDot={{r: 6, strokeWidth: 0}} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Transactions Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden flex flex-col">
        <div className="p-5 border-b border-gray-100 flex justify-between items-center">
          <h2 className="text-lg font-bold text-gray-900">Recent Transactions</h2>
          <button className="text-sm text-indigo-600 font-medium hover:text-indigo-800">View All</button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-50 text-gray-500 text-sm uppercase tracking-wider">
                <th className="p-4 font-medium">Transaction ID</th>
                <th className="p-4 font-medium">User</th>
                <th className="p-4 font-medium">Plan</th>
                <th className="p-4 font-medium">Amount</th>
                <th className="p-4 font-medium">Status</th>
                <th className="p-4 font-medium">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {transactions.map((row) => (
                <tr key={row.id} className="text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                  <td className="p-4 font-mono text-gray-500">{row.id}</td>
                  <td className="p-4 font-medium text-gray-900">{row.user}</td>
                  <td className="p-4">{row.plan}</td>
                  <td className="p-4 font-medium">{row.amount}</td>
                  <td className="p-4">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      row.status === 'Completed' ? 'bg-green-100 text-green-800' : 
                      row.status === 'Pending' ? 'bg-yellow-100 text-yellow-800' : 
                      'bg-red-100 text-red-800'
                    }`}>
                      {row.status}
                    </span>
                  </td>
                  <td className="p-4 text-gray-500">{row.date}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

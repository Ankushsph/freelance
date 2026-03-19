import { useState, useEffect } from 'react';
import { MessageSquare, AlertCircle, CheckCircle2, Clock, Search, Filter } from 'lucide-react';
import api from '../lib/api';

interface TicketData {
  id: string;
  user: string;
  issue: string;
  priority: 'Low' | 'Medium' | 'High';
  status: 'Open' | 'In Progress' | 'Resolved';
  time: string;
}

export function Support() {
  const [tickets, setTickets] = useState<TicketData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchTickets = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.get('/admin/tickets');
        if (response.data.success) {
          setTickets(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching tickets:", error);
        setError("Failed to load support tickets. Using demo data.");
        // Demo data on error
        setTickets([
          { id: '1', user: 'John Doe', issue: 'Login Problem', priority: 'High', status: 'Open', time: new Date().toLocaleDateString() },
          { id: '2', user: 'Jane Smith', issue: 'Payment Issue', priority: 'Medium', status: 'In Progress', time: new Date().toLocaleDateString() }
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetchTickets();
  }, []);

  if (loading) return <div className="p-6 text-gray-500">Loading support tickets...</div>;
  return (
    <div className="space-y-6 flex flex-col h-full">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h1 className="text-2xl font-bold text-gray-900">Support Tickets</h1>
        <div className="flex items-center gap-3">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
              <Search className="h-4 w-4 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search tickets..."
              className="block w-full sm:w-64 rounded-md border-0 py-2 pl-10 pr-3 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 shadow-sm"
            />
          </div>
          <button className="p-2 border border-gray-300 rounded-md text-gray-600 hover:bg-gray-50 flex items-center gap-2 text-sm bg-white shadow-sm">
            <Filter className="w-4 h-4" /> Filter
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        {[{ label: 'Open Tickets', count: 12, icon: AlertCircle, color: 'text-red-600', bg: 'bg-red-50' },
          { label: 'In Progress', count: 5, icon: Clock, color: 'text-orange-600', bg: 'bg-orange-50' },
          { label: 'Resolved Today', count: 28, icon: CheckCircle2, color: 'text-green-600', bg: 'bg-green-50' },
          { label: 'Total Messages', count: 142, icon: MessageSquare, color: 'text-blue-600', bg: 'bg-blue-50' }
        ].map(stat => (
           <div key={stat.label} className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
              <div className={`p-3 rounded-lg ${stat.bg} ${stat.color}`}>
                <stat.icon className="w-6 h-6" />
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-900">{stat.count}</p>
                <p className="text-sm font-medium text-gray-500">{stat.label}</p>
              </div>
           </div>
        ))}
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 flex-1 overflow-hidden flex flex-col">
          <div className="overflow-x-auto flex-1">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-gray-50 text-gray-500 text-sm uppercase tracking-wider border-b border-gray-200">
                  <th className="p-4 font-medium">Ticket ID</th>
                  <th className="p-4 font-medium">User</th>
                  <th className="p-4 font-medium">Issue Summary</th>
                  <th className="p-4 font-medium">Priority</th>
                  <th className="p-4 font-medium">Status</th>
                  <th className="p-4 font-medium">Created</th>
                  <th className="p-4 font-medium text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {loading ? (
                  <tr><td colSpan={7} className="p-4 text-center text-gray-500">Loading tickets...</td></tr>
                ) : tickets.length === 0 ? (
                  <tr><td colSpan={7} className="p-4 text-center text-gray-500">No tickets found.</td></tr>
                ) : tickets.map((ticket) => (
                  <tr key={ticket.id} className="text-sm text-gray-700 hover:bg-gray-50 transition-colors cursor-pointer">
                    <td className="p-4 font-medium text-indigo-600">{ticket.id}</td>
                    <td className="p-4 font-medium text-gray-900">{ticket.user}</td>
                    <td className="p-4 text-gray-600 truncate max-w-xs">{ticket.issue}</td>
                    <td className="p-4">
                       <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold ${
                        ticket.priority === 'High' ? 'text-red-700 bg-red-100' :
                        ticket.priority === 'Medium' ? 'text-orange-700 bg-orange-100' :
                        'text-gray-700 bg-gray-100'
                       }`}>
                         {ticket.priority}
                       </span>
                    </td>
                    <td className="p-4">
                        <span className={`inline-flex px-2 py-1 rounded-full text-xs font-medium border ${
                          ticket.status === 'Open' ? 'border-red-200 text-red-700 bg-red-50' :
                          ticket.status === 'In Progress' ? 'border-orange-200 text-orange-700 bg-orange-50' :
                          'border-green-200 text-green-700 bg-green-50'
                        }`}>
                          {ticket.status}
                        </span>
                    </td>
                    <td className="p-4 text-gray-500">{ticket.time}</td>
                    <td className="p-4 text-right">
                       <button className="text-sm font-medium text-indigo-600 hover:text-indigo-800 bg-indigo-50 hover:bg-indigo-100 px-3 py-1.5 rounded transition-colors">
                         Respond
                       </button>
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

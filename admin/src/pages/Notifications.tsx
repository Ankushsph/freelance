import { useState, useEffect } from 'react';
import { BellRing, Send, Info, AlertTriangle, AlertCircle } from 'lucide-react';
import api from '../lib/api';

interface AnnouncementData {
  _id: string;
  title: string;
  type: 'Info' | 'Warning' | 'Alert';
  date: string;
  audience: string;
  createdAt: string;
}

export function Notifications() {
  const [announcements, setAnnouncements] = useState<AnnouncementData[]>([]);
  const [loading, setLoading] = useState(true);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');

  useEffect(() => {
    const fetchAnnouncements = async () => {
      try {
        setLoading(true);
        const response = await api.get('/admin/notifications');
        if (response.data.success) {
          setAnnouncements(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching announcements:", error);
        // Demo data on error
        setAnnouncements([
          { _id: '1', title: 'System Maintenance', type: 'Info', audience: 'All Users', createdAt: new Date().toISOString(), date: new Date().toLocaleDateString() }
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetchAnnouncements();
  }, []);

  const handleSend = async (e: any) => {
    e.preventDefault();
    if (!title || !body) return alert("Title and body required");
    try {
      const res = await api.post('/admin/notifications', { 
        title, 
        body,
        type: 'Info', 
        audience: 'All Users' 
      });
      if (res.data.success) {
        setAnnouncements([res.data.data, ...announcements]);
        setTitle('');
        setBody('');
        alert("Sent!");
      }
    } catch (err) {
      alert("Error sending announcement");
    }
  };
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Notifications & Announcements</h1>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Create Announcement Form */}
        <div className="lg:col-span-1 bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center gap-2 mb-6">
            <BellRing className="w-5 h-5 text-indigo-600" />
            <h2 className="text-lg font-bold text-gray-900">New Announcement</h2>
          </div>
          
          <form className="space-y-4" onSubmit={handleSend}>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
              <input type="text" value={title} onChange={e => setTitle(e.target.value)} className="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm border p-2" placeholder="Announcement Title" />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Message Body</label>
              <textarea rows={4} value={body} onChange={e => setBody(e.target.value)} className="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm border p-2" placeholder="Type your message here..."></textarea>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Target Audience</label>
              <select className="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm border p-2 bg-white">
                <option>All Users</option>
                <option>Paid Subscribers Only</option>
                <option>Free Users</option>
                <option>Users with specific platforms</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Notification Type</label>
              <div className="flex gap-4">
                <label className="flex items-center gap-2 text-sm text-gray-600">
                  <input type="radio" name="type" className="text-indigo-600 focus:ring-indigo-500" defaultChecked /> Info
                </label>
                <label className="flex items-center gap-2 text-sm text-gray-600">
                  <input type="radio" name="type" className="text-yellow-600 focus:ring-yellow-500" /> Warning
                </label>
                <label className="flex items-center gap-2 text-sm text-gray-600">
                  <input type="radio" name="type" className="text-red-600 focus:ring-red-500" /> Alert
                </label>
              </div>
            </div>

            <button type="submit" className="w-full mt-4 flex justify-center items-center gap-2 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
              <Send className="w-4 h-4" /> Send Announcement
            </button>
          </form>
        </div>

        {/* History Log */}
        <div className="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden flex flex-col">
          <div className="p-6 border-b border-gray-100">
            <h2 className="text-lg font-bold text-gray-900">Announcement History</h2>
          </div>
          <div className="flex-1 divide-y divide-gray-100">
            {loading ? (
               <div className="p-6 text-center text-gray-500">Loading history...</div>
            ) : announcements.length === 0 ? (
               <div className="p-6 text-center text-gray-500">No announcements sent yet.</div>
            ) : announcements.map((log) => {
              const IconComp = log.type === 'Alert' ? AlertCircle : log.type === 'Warning' ? AlertTriangle : Info;
              const bgColor = log.type === 'Alert' ? 'bg-red-50' : log.type === 'Warning' ? 'bg-yellow-50' : 'bg-blue-50';
              const textColor = log.type === 'Alert' ? 'text-red-500' : log.type === 'Warning' ? 'text-yellow-500' : 'text-blue-500';
              
              return (
              <div key={log._id} className="p-6 hover:bg-gray-50 transition-colors">
                <div className="flex items-start gap-4">
                  <div className={`p-2 rounded-lg ${bgColor} ${textColor} shrink-0`}>
                    <IconComp className="w-6 h-6" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-start mb-1">
                      <h3 className="text-sm font-bold text-gray-900 truncate">{log.title}</h3>
                      <span className="text-xs text-gray-500 shrink-0 ml-2">{new Date(log.createdAt).toLocaleDateString()}</span>
                    </div>
                    <div className="flex flex-wrap gap-2 mt-2">
                      <span className="inline-flex py-0.5 px-2 rounded bg-gray-100 text-gray-600 text-xs font-medium">Type: {log.type}</span>
                      <span className="inline-flex py-0.5 px-2 rounded bg-indigo-50 text-indigo-700 text-xs font-medium">Audience: {log.audience}</span>
                    </div>
                  </div>
                </div>
              </div>
            )})}
          </div>
        </div>

      </div>
    </div>
  );
}

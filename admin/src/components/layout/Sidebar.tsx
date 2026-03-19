import { Link, useLocation } from 'react-router-dom';
import { 
  LayoutDashboard, Users, CreditCard, DollarSign, 
  Activity, TrendingUp, Bell, HeadphonesIcon, Settings 
} from 'lucide-react';
import clsx from 'clsx';

const NAVIGATION = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Users', href: '/users', icon: Users },
  { name: 'Subscriptions', href: '/subscriptions', icon: CreditCard },
  { name: 'Revenue', href: '/revenue', icon: DollarSign },
  { name: 'Platform Activity', href: '/activity', icon: Activity },
  { name: 'Trends', href: '/trends', icon: TrendingUp },
  { name: 'Notifications', href: '/notifications', icon: Bell },
  { name: 'Support', href: '/support', icon: HeadphonesIcon },
  { name: 'Settings', href: '/settings', icon: Settings },
];

export function Sidebar() {
  const location = useLocation();

  return (
    <div className="hidden md:flex flex-col w-64 bg-white border-r border-gray-200">
      <div className="h-16 flex items-center px-6 border-b border-gray-200">
        <div className="flex items-center gap-2 text-indigo-600 font-bold text-xl">
          <LayoutDashboard className="w-6 h-6" />
          <span>KonnectAdmin</span>
        </div>
      </div>
      <nav className="flex-1 overflow-y-auto py-4">
        <ul className="space-y-1 px-3">
          {NAVIGATION.map((item) => {
            const isActive = location.pathname === item.href;
            return (
              <li key={item.name}>
                <Link
                  to={item.href}
                  className={clsx(
                    'flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors',
                    isActive 
                      ? 'bg-indigo-50 text-indigo-700' 
                      : 'text-gray-700 hover:bg-gray-100'
                  )}
                >
                  <item.icon className={clsx("w-5 h-5", isActive ? "text-indigo-600" : "text-gray-400")} />
                  {item.name}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>
    </div>
  );
}

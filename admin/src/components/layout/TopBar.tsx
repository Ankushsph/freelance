import { Search } from 'lucide-react';
import { NotificationDropdown } from '../NotificationDropdown';
import { ProfileDropdown } from '../ProfileDropdown';

export function TopBar() {
  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6 shadow-sm z-10">
      <div className="flex-1 max-w-xl flex items-center">
        <div className="relative w-full">
          <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <Search className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="text"
            placeholder="Search..."
            className="block w-full rounded-md border-0 py-1.5 pl-10 pr-3 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
          />
        </div>
      </div>
      
      <div className="ml-4 flex items-center gap-4">
        <NotificationDropdown />
        
        <div className="border-l border-gray-200 pl-4">
          <ProfileDropdown />
        </div>
      </div>
    </header>
  );
}

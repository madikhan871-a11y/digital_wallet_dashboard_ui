import React from 'react';
import { NavLink } from 'react-router-dom';

const navItems = [
  { path: '/', icon: 'dashboard', label: 'Dashboard' },
  { path: '/customers', icon: 'group', label: 'Customers' },
  { path: '/packages', icon: 'inventory_2', label: 'Packages' },
  { path: '/subscriptions', icon: 'event_repeat', label: 'Subscriptions' },
  { path: '/billing', icon: 'receipt_long', label: 'Bills' },
  { path: '/payments', icon: 'payments', label: 'Payments' },
  { path: '/complaints', icon: 'emergency_home', label: 'Complaints' },
  { path: '/announcements', icon: 'campaign', label: 'Announcements' },
  { path: '/notifications', icon: 'notifications', label: 'Notifications' },
  { path: '/reports', icon: 'bar_chart', label: 'Reports' },
  { path: '/settings', icon: 'settings', label: 'Settings' },
];

export const Sidebar: React.FC = () => {
  return (
    <aside className="fixed left-0 top-0 h-full w-72 bg-surface-container-lowest z-50 flex flex-col shadow-[1px_0_8px_rgba(0,0,0,0.02)]">
      <div className="h-16 flex items-center px-lg gap-sm mb-base">
        <div className="w-8 h-8 rounded-full bg-primary-container flex items-center justify-center">
          <span className="material-symbols-outlined text-on-primary-container text-[20px]">router</span>
        </div>
        <span className="text-title-md font-title-md text-primary truncate">BroadNet Admin</span>
      </div>

      <nav className="flex-1 px-sm overflow-y-auto space-y-xs">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center px-md py-sm rounded-lg transition-all group ${
                isActive
                  ? 'bg-secondary-container text-on-secondary-container font-bold'
                  : 'text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface'
              }`
            }
          >
            <span className="material-symbols-outlined mr-md">{item.icon}</span>
            <span className="text-label-lg font-label-lg">{item.label}</span>
          </NavLink>
        ))}
      </nav>

      <div className="px-sm mt-auto border-t border-outline-variant pt-sm pb-md">
        <button className="flex w-full items-center px-md py-sm rounded-lg text-error hover:bg-error-container hover:text-on-error-container transition-all">
          <span className="material-symbols-outlined mr-md">logout</span>
          <span className="text-label-lg font-label-lg">Logout</span>
        </button>
      </div>
    </aside>
  );
};

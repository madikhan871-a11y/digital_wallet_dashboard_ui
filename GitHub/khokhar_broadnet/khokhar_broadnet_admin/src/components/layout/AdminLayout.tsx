import React from 'react';
import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Header } from './Header';

export const AdminLayout: React.FC = () => {
  return (
    <div className="min-h-screen bg-surface">
      <Sidebar />
      <div className="pl-72">
        <Header />
        <main className="relative pt-16 min-h-screen bg-surface px-xl py-xl">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

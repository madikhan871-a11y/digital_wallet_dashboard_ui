import React from 'react';

export const Header: React.FC = () => {
  return (
    <header className="fixed top-0 left-72 right-0 h-16 bg-surface/80 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)] z-40 flex items-center justify-between px-xl">
      <div className="flex items-center gap-md">
        <span className="material-symbols-outlined text-on-surface-variant cursor-pointer">menu</span>
        <div className="h-8 w-[1px] bg-outline-variant"></div>
        <nav className="flex gap-md text-on-surface-variant font-label-md text-label-md">
          <a className="hover:text-primary transition-colors" href="#">Infrastructure</a>
          <a className="hover:text-primary transition-colors" href="#">Node Health</a>
        </nav>
      </div>

      <div className="flex items-center gap-lg">
        <div className="relative flex items-center bg-surface-container px-sm py-xs rounded-full group focus-within:ring-2 focus-within:ring-primary">
          <span className="material-symbols-outlined text-on-surface-variant text-body-md">search</span>
          <input
            className="bg-transparent border-none outline-none px-base text-body-md text-on-surface w-48 focus:w-64 transition-all"
            placeholder="Search network..."
            type="text"
          />
        </div>

        <button className="material-symbols-outlined text-on-surface-variant hover:text-primary">help</button>

        <div className="flex items-center gap-sm pl-md border-l border-outline-variant">
          <div className="text-right hidden sm:block">
            <p className="text-label-md font-title-md text-on-surface leading-tight">BroadNet Admin</p>
            <p className="text-[10px] text-on-surface-variant uppercase tracking-wider">Superuser</p>
          </div>
          <div className="w-9 h-9 rounded-full bg-surface-container-high overflow-hidden ring-2 ring-surface-container-high">
             <span className="material-symbols-outlined w-full h-full flex items-center justify-center text-on-surface-variant">person</span>
          </div>
        </div>
      </div>
    </header>
  );
};

import React from 'react';
import { useLocation } from 'react-router-dom';

export const Placeholder: React.FC = () => {
  const location = useLocation();
  const name = location.pathname.substring(1).charAt(0).toUpperCase() + location.pathname.substring(2);

  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] gap-md text-on-surface-variant">
      <span className="material-symbols-outlined text-[64px]">construction</span>
      <h1 className="font-headline-md text-headline-md text-on-surface">{name || 'Page'} Module</h1>
      <p className="font-body-lg text-body-lg">This module is scheduled for implementation in a future phase.</p>
    </div>
  );
};

import React from 'react';

export const LoadingState: React.FC = () => {
  return (
    <div className="w-full py-xl flex flex-col justify-center items-center gap-md">
      <span className="material-symbols-outlined animate-spin text-primary text-[48px]">autorenew</span>
      <p className="font-label-lg text-label-lg text-on-surface-variant">Loading data...</p>
    </div>
  );
};

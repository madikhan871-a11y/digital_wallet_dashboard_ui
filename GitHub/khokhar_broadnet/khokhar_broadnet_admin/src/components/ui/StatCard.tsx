import React from 'react';

interface StatCardProps {
  label: string;
  value: string | number;
  subValue?: string;
  trend?: {
    value: string;
    isUp: boolean;
  };
  icon: string;
  variant?: 'primary' | 'secondary' | 'tertiary' | 'error';
  progress?: number;
}

export const StatCard: React.FC<StatCardProps> = ({
  label,
  value,
  subValue,
  trend,
  icon,
  variant = 'primary',
  progress,
}) => {
  const iconVariants = {
    primary: 'bg-primary-fixed text-on-primary-fixed',
    secondary: 'bg-secondary-fixed text-on-secondary-fixed',
    tertiary: 'bg-tertiary-fixed text-on-tertiary-fixed',
    error: 'bg-error-container text-on-error-container',
  };

  const blurVariants = {
    primary: 'bg-primary-container/10 group-hover:bg-primary-container/20',
    secondary: 'bg-surface-tint/10 group-hover:bg-surface-tint/20',
    tertiary: 'bg-tertiary-container/10 group-hover:bg-tertiary-container/20',
    error: 'bg-error-container/10 group-hover:bg-error-container/20',
  };

  return (
    <div className="bg-surface-container-lowest rounded-xl p-lg shadow-sm flex flex-col justify-between group hover:shadow-md transition-all relative overflow-hidden">
      <div className={`absolute -right-4 -top-4 w-24 h-24 rounded-full blur-xl transition-all ${blurVariants[variant]}`}></div>

      <div className="flex justify-between items-start mb-lg relative z-10">
        <div>
          <p className="font-label-md text-label-md text-on-surface-variant uppercase tracking-wider">{label}</p>
          <div className="flex items-baseline gap-sm mt-xs">
            <h3 className={`font-headline-lg text-headline-lg ${variant === 'error' ? 'text-error' : 'text-on-surface'}`}>{value}</h3>
            {subValue && <span className="font-title-md text-title-md text-on-surface-variant">{subValue}</span>}
          </div>
        </div>
        <div className={`w-10 h-10 rounded-full flex items-center justify-center ${iconVariants[variant]}`}>
          <span className="material-symbols-outlined">{icon}</span>
        </div>
      </div>

      {progress !== undefined ? (
        <div className="mt-auto relative z-10">
          <div className="w-full bg-surface-container-high rounded-full h-1.5">
            <div
              className={`h-1.5 rounded-full ${variant === 'secondary' ? 'bg-surface-tint' : 'bg-primary'}`}
              style={{ width: `${progress}%` }}
            ></div>
          </div>
          <p className="font-label-md text-label-md text-on-surface-variant mt-sm">{progress}% active rate</p>
        </div>
      ) : trend ? (
        <div className="flex items-center gap-sm relative z-10">
          <div className={`flex items-center px-sm py-xs rounded-full ${trend.isUp ? 'text-on-primary-container bg-primary-container/10' : 'text-error bg-error-container/50'}`}>
            <span className="material-symbols-outlined text-[16px]">{trend.isUp ? 'trending_up' : 'trending_down'}</span>
            <span className="font-label-md text-label-md ml-xs">{trend.value}</span>
          </div>
          <span className="font-label-md text-label-md text-on-surface-variant">vs last month</span>
        </div>
      ) : null}
    </div>
  );
};

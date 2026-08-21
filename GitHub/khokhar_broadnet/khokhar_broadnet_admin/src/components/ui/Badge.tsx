import React from 'react';

type BadgeVariant = 'success' | 'pending' | 'error' | 'info';

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
}

export const Badge: React.FC<BadgeProps> = ({ children, variant = 'info' }) => {
  const variants = {
    success: 'bg-primary-container/10 text-primary-container',
    pending: 'bg-tertiary-container/10 text-tertiary-container',
    error: 'bg-error-container/10 text-error',
    info: 'bg-secondary-container/10 text-secondary-container',
  };

  return (
    <span className={`inline-flex items-center px-sm py-xs rounded-full font-label-md ${variants[variant]}`}>
      {children}
    </span>
  );
};

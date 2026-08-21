import React from 'react';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'error' | 'ghost';
  isLoading?: boolean;
  icon?: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  isLoading = false,
  icon,
  className = '',
  ...props
}) => {
  const baseStyles = 'inline-flex items-center justify-center gap-sm px-lg py-sm rounded-lg font-label-lg transition-all duration-200 shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed';

  const variants = {
    primary: 'bg-primary text-on-primary hover:bg-primary-container',
    secondary: 'bg-secondary-container text-on-secondary-container hover:bg-secondary-fixed-dim',
    error: 'bg-error text-on-error hover:bg-error-container hover:text-on-error-container',
    ghost: 'bg-transparent text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface shadow-none hover:shadow-none',
  };

  return (
    <button
      className={`${baseStyles} ${variants[variant]} ${className}`}
      disabled={isLoading || props.disabled}
      {...props}
    >
      {isLoading ? (
        <span className="material-symbols-outlined animate-spin text-[20px]">autorenew</span>
      ) : (
        <>
          {children}
          {icon && <span className="material-symbols-outlined text-[20px]">{icon}</span>}
        </>
      )}
    </button>
  );
};

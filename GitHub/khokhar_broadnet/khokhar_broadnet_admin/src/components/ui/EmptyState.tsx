import React from 'react';
import { Button } from './Button';

interface EmptyStateProps {
  icon: string;
  title: string;
  description: string;
  actionLabel?: string;
  onAction?: () => void;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  icon,
  title,
  description,
  actionLabel,
  onAction
}) => {
  return (
    <div className="w-full py-xl flex flex-col justify-center items-center gap-md text-on-surface-variant text-center max-w-md mx-auto">
      <span className="material-symbols-outlined text-[64px] opacity-20">{icon}</span>
      <div>
        <h3 className="font-headline-sm text-headline-sm text-on-surface">{title}</h3>
        <p className="font-body-md text-body-md mt-xs">{description}</p>
      </div>
      {actionLabel && onAction && (
        <Button onClick={onAction} variant="secondary" className="mt-sm">
          {actionLabel}
        </Button>
      )}
    </div>
  );
};

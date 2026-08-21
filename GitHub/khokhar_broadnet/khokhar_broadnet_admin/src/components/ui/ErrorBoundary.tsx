import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children?: ReactNode;
}

interface State {
  hasError: boolean;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false
  };

  public static getDerivedStateFromError(_: Error): State {
    return { hasError: true };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Uncaught error:', error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex flex-col items-center justify-center p-xl bg-surface text-center">
          <span className="material-symbols-outlined text-[64px] text-error mb-md">report</span>
          <h1 className="text-headline-md font-bold mb-sm">Something went wrong</h1>
          <p className="text-on-surface-variant mb-lg max-w-md">
            The application encountered an unexpected error. Please try refreshing the page.
          </p>
          <button
            onClick={() => window.location.reload()}
            className="bg-primary text-on-primary px-lg py-sm rounded-lg font-bold shadow-md hover:shadow-lg transition-all"
          >
            Refresh Dashboard
          </button>
        </div>
      );
    }

    return this.children;
  }
}

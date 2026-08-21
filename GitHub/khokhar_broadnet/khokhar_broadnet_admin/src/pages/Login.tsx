import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '../components/ui/Button';

export const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    // Simulate login for Phase 1
    setTimeout(() => {
      setIsLoading(false);
      navigate('/');
    }, 1500);
  };

  return (
    <main className="w-full flex items-center justify-center min-h-screen bg-surface relative overflow-hidden">
      {/* Decorative Background Elements */}
      <div className="absolute inset-0 pointer-events-none z-0">
        <svg className="absolute w-full h-full opacity-10 text-primary mix-blend-multiply" height="100%" width="100%" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern height="40" id="gridPattern" patternUnits="userSpaceOnUse" width="40">
              <path d="M 40 0 L 0 0 0 40" fill="none" stroke="currentColor" strokeWidth="0.5"></path>
            </pattern>
          </defs>
          <rect fill="url(#gridPattern)" height="100%" width="100%"></rect>
        </svg>
        <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] rounded-full bg-gradient-to-br from-primary/10 to-transparent blur-3xl mix-blend-multiply"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-gradient-to-tl from-secondary/10 to-transparent blur-3xl mix-blend-multiply"></div>
      </div>

      {/* Login Card */}
      <div className="z-10 w-full max-w-md px-lg py-xl bg-surface-container-lowest shadow-xl rounded-xl relative overflow-hidden flex flex-col gap-xl">
        {/* Logo Header */}
        <div className="flex flex-col items-center justify-center gap-sm">
          <div className="w-16 h-16 rounded-full bg-primary-container flex items-center justify-center shadow-md">
            <span className="material-symbols-outlined text-on-primary-container text-[32px]">router</span>
          </div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface text-center">Khokhar BroadNet</h1>
          <p className="font-body-md text-body-md text-on-surface-variant text-center">Infrastructure Management Portal</p>
        </div>

        {/* Form */}
        <form className="flex flex-col gap-lg w-full" onSubmit={handleSubmit}>
          {/* Email Input */}
          <div className="flex flex-col gap-xs w-full relative">
            <label className="font-label-md text-label-md text-on-surface-variant uppercase tracking-wider ml-1" htmlFor="email">Email Address</label>
            <div className="relative w-full flex items-center bg-surface-container-low rounded-lg focus-within:ring-2 focus-within:ring-primary focus-within:bg-surface-container-lowest transition-all duration-200">
              <span className="material-symbols-outlined text-on-surface-variant ml-sm absolute">mail</span>
              <input
                autoComplete="email"
                className="w-full bg-transparent font-body-md text-body-md text-on-surface pl-10 pr-sm py-sm focus:outline-none placeholder:text-on-surface-variant/50"
                id="email"
                placeholder="admin@khokhar.net"
                required
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
          </div>

          {/* Password Input */}
          <div className="flex flex-col gap-xs w-full relative">
            <div className="flex justify-between items-center w-full ml-1">
              <label className="font-label-md text-label-md text-on-surface-variant uppercase tracking-wider" htmlFor="password">Password</label>
              <a className="font-label-md text-label-md text-primary hover:text-primary-container transition-colors" href="#">Forgot?</a>
            </div>
            <div className="relative w-full flex items-center bg-surface-container-low rounded-lg focus-within:ring-2 focus-within:ring-primary focus-within:bg-surface-container-lowest transition-all duration-200">
              <span className="material-symbols-outlined text-on-surface-variant ml-sm absolute">lock</span>
              <input
                autoComplete="current-password"
                className="w-full bg-transparent font-body-md text-body-md text-on-surface pl-10 pr-10 py-sm focus:outline-none placeholder:text-on-surface-variant/50"
                id="password"
                placeholder="••••••••"
                required
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              <button
                className="absolute right-sm text-on-surface-variant hover:text-on-surface transition-colors focus:outline-none"
                type="button"
                onClick={() => setShowPassword(!showPassword)}
              >
                <span className="material-symbols-outlined text-[20px]">
                  {showPassword ? 'visibility' : 'visibility_off'}
                </span>
              </button>
            </div>
          </div>

          {/* Remember Me */}
          <div className="flex items-center gap-sm">
            <div className="relative flex items-center cursor-pointer">
              <input className="peer sr-only" id="remember" type="checkbox"/>
              <div className="w-5 h-5 bg-surface-container-low rounded peer-checked:bg-primary transition-colors flex items-center justify-center">
                <span className="material-symbols-outlined text-on-primary text-[16px] opacity-0 peer-checked:opacity-100 transition-opacity" style={{ fontVariationSettings: "'FILL' 1" }}>check</span>
              </div>
            </div>
            <label className="font-body-md text-body-md text-on-surface-variant cursor-pointer select-none" htmlFor="remember">Remember this device</label>
          </div>

          {/* Submit Button */}
          <Button
            type="submit"
            className="w-full"
            isLoading={isLoading}
            icon="arrow_forward"
          >
            Secure Login
          </Button>

          {/* System Status */}
          <div className="mt-xs flex items-center justify-center gap-xs bg-surface-container rounded-full py-xs px-sm self-center">
            <div className="w-2 h-2 rounded-full bg-tertiary animate-pulse"></div>
            <span className="font-label-md text-label-md text-on-surface-variant">System Optimal</span>
          </div>
        </form>
      </div>

      <div className="absolute bottom-lg text-center w-full z-10">
        <p className="font-label-md text-label-md text-on-surface-variant/70">© 2024 Khokhar BroadNet. All rights reserved.</p>
      </div>
    </main>
  );
};

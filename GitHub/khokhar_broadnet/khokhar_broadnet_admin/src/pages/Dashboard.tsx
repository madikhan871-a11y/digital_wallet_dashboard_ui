import React from 'react';
import { StatCard } from '../components/ui/StatCard';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';

export const Dashboard: React.FC = () => {
  const recentPayments = [
    { id: 1, customer: 'John Doe', initials: 'JD', amount: '$85.00', status: 'success', date: 'Today, 10:42 AM' },
    { id: 2, customer: 'Alice Smith', initials: 'AS', amount: '$120.00', status: 'pending', date: 'Today, 09:15 AM' },
    { id: 3, customer: 'Robert Jones', initials: 'RJ', amount: '$45.00', status: 'error', date: 'Yesterday, 14:30' },
  ];

  const paymentColumns = [
    {
      header: 'Customer',
      accessor: (item: any) => (
        <div className="flex items-center gap-sm">
          <div className="w-8 h-8 rounded-full bg-primary-container/10 flex items-center justify-center font-title-md text-primary-container">
            {item.initials}
          </div>
          <span className="font-title-md">{item.customer}</span>
        </div>
      ),
    },
    { header: 'Amount', accessor: 'amount', className: 'font-title-md' },
    {
      header: 'Status',
      accessor: (item: any) => (
        <Badge variant={item.status as any}>
          {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
        </Badge>
      ),
    },
    { header: 'Date', accessor: 'date', align: 'right' as const, className: 'text-on-surface-variant' },
  ];

  return (
    <div className="flex flex-col w-full gap-xl pb-xl">
      <div className="flex items-center justify-between mb-md">
        <div>
          <h1 className="font-headline-lg text-headline-lg text-on-surface">Network Overview</h1>
          <p className="font-body-md text-body-md text-on-surface-variant mt-xs">Real-time infrastructure and subscriber metrics</p>
        </div>
        <div className="flex items-center gap-md">
          <div className="flex items-center bg-surface-container-high rounded-full px-sm py-xs">
            <span className="w-2 h-2 rounded-full bg-surface-tint animate-pulse mr-sm"></span>
            <span className="font-label-md text-label-md text-on-surface-variant">Live Sync</span>
          </div>
          <Button icon="download">Export Report</Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-md">
        <StatCard
          label="Total Customers"
          value="14,295"
          trend={{ value: '+4.2%', isUp: true }}
          icon="group"
          variant="primary"
        />
        <StatCard
          label="Active Customers"
          value="13,842"
          progress={96.8}
          icon="check_circle"
          variant="secondary"
        />
        <StatCard
          label="Pending / Suspended"
          value="128"
          subValue="/ 325"
          icon="pending_actions"
          variant="tertiary"
        />
        <StatCard
          label="Unpaid Bills"
          value="$42.5K"
          trend={{ value: '+1.2%', isUp: false }}
          icon="account_balance_wallet"
          variant="error"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-md">
        <div className="lg:col-span-2 bg-surface-container-lowest rounded-xl p-lg shadow-sm">
          <div className="flex justify-between items-center mb-xl">
            <h2 className="font-title-lg text-title-lg text-on-surface">Revenue Overview</h2>
            <select className="bg-surface-container text-on-surface font-label-md text-label-md px-md py-xs rounded-lg outline-none border-none cursor-pointer">
              <option>Last 6 Months</option>
              <option>This Year</option>
              <option>All Time</option>
            </select>
          </div>
          <div className="h-64 w-full relative">
            <svg className="w-full h-full text-surface-tint" preserveAspectRatio="none" viewBox="0 0 800 200">
              <defs>
                <linearGradient id="chart-gradient" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0%" stopColor="currentColor" stopOpacity="0.2"></stop>
                  <stop offset="100%" stopColor="currentColor" stopOpacity="0"></stop>
                </linearGradient>
              </defs>
              <path d="M0,150 L100,120 L200,140 L300,90 L400,110 L500,60 L600,80 L700,30 L800,50 L800,200 L0,200 Z" fill="url(#chart-gradient)"></path>
              <path d="M0,150 L100,120 L200,140 L300,90 L400,110 L500,60 L600,80 L700,30 L800,50" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="3"></path>
            </svg>
          </div>
        </div>

        <div className="bg-surface-container-lowest rounded-xl p-lg shadow-sm flex flex-col">
          <div className="flex justify-between items-center mb-lg">
            <h2 className="font-title-lg text-title-lg text-on-surface">Active Packages</h2>
            <span className="material-symbols-outlined text-on-surface-variant cursor-pointer hover:text-primary transition-colors">more_vert</span>
          </div>
          <div className="flex-1 flex items-center justify-center relative">
            <svg className="w-48 h-48 transform -rotate-90" viewBox="0 0 100 100">
              <circle className="text-surface-container-high" cx="50" cy="50" fill="transparent" r="40" stroke="currentColor" strokeWidth="12"></circle>
              <circle className="text-primary" cx="50" cy="50" fill="transparent" r="40" stroke="currentColor" strokeDasharray="251.2" strokeDashoffset="62.8" strokeWidth="12"></circle>
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
              <span className="font-headline-md text-headline-md text-on-surface">12</span>
              <span className="font-label-md text-label-md text-on-surface-variant">Plans</span>
            </div>
          </div>
          <div className="space-y-sm mt-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-sm">
                <span className="w-3 h-3 rounded-full bg-primary"></span>
                <span className="font-body-md text-body-md text-on-surface">Fiber 100Mbps</span>
              </div>
              <span className="font-title-md text-title-md text-on-surface">45%</span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-sm">
                <span className="w-3 h-3 rounded-full bg-tertiary"></span>
                <span className="font-body-md text-body-md text-on-surface">Fiber 50Mbps</span>
              </div>
              <span className="font-title-md text-title-md text-on-surface">30%</span>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-md">
        <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex flex-col">
          <div className="p-lg flex justify-between items-center bg-surface-container-lowest border-b border-surface-container-high">
            <h2 className="font-title-lg text-title-lg text-on-surface flex items-center gap-sm">
              <span className="material-symbols-outlined text-surface-tint">payments</span>
              Recent Payments
            </h2>
            <Button variant="ghost">View All</Button>
          </div>
          <Table columns={paymentColumns} data={recentPayments} />
        </div>

        <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex flex-col">
          <div className="p-lg flex justify-between items-center bg-surface-container-lowest border-b border-surface-container-high">
            <h2 className="font-title-lg text-title-lg text-on-surface flex items-center gap-sm">
              <span className="material-symbols-outlined text-error">emergency_home</span>
              Open Complaints
            </h2>
            <span className="bg-error text-on-error font-label-md text-label-md px-sm py-xs rounded-full">14 Active</span>
          </div>
          <div className="p-md space-y-sm overflow-y-auto max-h-[300px]">
            {[1, 2].map((i) => (
              <div key={i} className="bg-surface p-md rounded-lg flex items-start gap-md hover:bg-surface-container transition-colors cursor-pointer border border-transparent hover:border-surface-variant">
                <div className={`w-10 h-10 rounded-full flex-shrink-0 flex items-center justify-center ${i === 1 ? 'bg-error-container/20' : 'bg-tertiary-container/20'}`}>
                  <span className={`material-symbols-outlined ${i === 1 ? 'text-error' : 'text-tertiary-container'}`}>
                    {i === 1 ? 'wifi_off' : 'speed'}
                  </span>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-start mb-xs">
                    <h4 className="font-title-md text-title-md text-on-surface truncate">
                      {i === 1 ? 'Complete Outage - Sector 4' : 'Slow Speeds - Evening Peak'}
                    </h4>
                    <span className="font-label-md text-label-md text-on-surface-variant flex-shrink-0">{i}h ago</span>
                  </div>
                  <p className="font-body-md text-body-md text-on-surface-variant line-clamp-1">
                    {i === 1 ? 'Multiple users reporting no connectivity in the northern block.' : 'Customer getting 10Mbps on 50Mbps plan during evening hours.'}
                  </p>
                  <div className="flex items-center gap-md mt-sm">
                    <span className={`font-label-md text-label-md flex items-center gap-xs ${i === 1 ? 'text-error' : 'text-tertiary-container'}`}>
                      <span className="material-symbols-outlined text-[16px]">{i === 1 ? 'priority_high' : 'warning'}</span>
                      {i === 1 ? 'High Priority' : 'Medium Priority'}
                    </span>
                    <span className="font-label-md text-label-md text-on-surface-variant">Ticket #89{42-i}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

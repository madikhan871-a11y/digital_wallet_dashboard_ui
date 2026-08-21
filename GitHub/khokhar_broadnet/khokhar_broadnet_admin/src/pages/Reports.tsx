import React, { useEffect, useState } from 'react';
import { reportService } from '../services/reportService';
import { AnalyticsReport } from '../types/report';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { Button } from '../components/ui/Button';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';

export const Reports: React.FC = () => {
  const [report, setReport] = useState<AnalyticsReport | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dateFilter, setDateFilter] = useState('This Month');

  const fetchReport = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await reportService.getAnalyticsSummary();
      setReport(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch analytics report');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReport();
  }, [dateFilter]);

  if (loading) return <LoadingState />;

  if (error || !report) {
    return (
      <div className="p-xl text-center text-error">
        <span className="material-symbols-outlined text-[48px] mb-md">analytics</span>
        <p>{error || 'No report data available'}</p>
        <Button onClick={fetchReport} className="mt-md">Retry</Button>
      </div>
    );
  }

  const { overview, revenueAnalytics, areaDistribution, packagePerformance, paymentBreakdown, complaintBreakdown } = report;

  return (
    <div className="flex flex-col w-full h-full gap-lg pb-xl">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-md mb-md">
        <div className="flex flex-col">
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Reports & Analytics</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Comprehensive business insights and performance metrics.</p>
        </div>
        <div className="flex items-center gap-sm">
          <select
            className="bg-surface-container hover:bg-surface-container-high text-on-surface font-label-lg text-label-lg py-sm px-md rounded-lg outline-none cursor-pointer transition-colors"
            value={dateFilter}
            onChange={(e) => setDateFilter(e.target.value)}
          >
            <option>Today</option>
            <option>This Week</option>
            <option>This Month</option>
            <option>Last Month</option>
            <option>Last 3 Months</option>
          </select>
          <Button variant="ghost" icon="download">Export CSV</Button>
        </div>
      </div>

      {/* Overview Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-md">
        <StatCard label="Total Revenue" value={`Rs. ${overview.monthlyRevenue.toLocaleString()}`} icon="payments" variant="primary" />
        <StatCard label="Outstanding" value={`Rs. ${overview.outstandingBills.toLocaleString()}`} icon="receipt_long" variant="error" />
        <StatCard label="Active Subs" value={overview.activeSubscriptions} icon="event_repeat" variant="secondary" />
        <StatCard label="Open Tickets" value={overview.openTickets} icon="support_agent" variant="tertiary" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-lg mt-md">
        {/* Revenue Trends */}
        <div className="bg-surface-container-lowest rounded-2xl p-lg shadow-sm">
          <h3 className="text-title-lg font-bold mb-lg flex items-center gap-sm">
            <span className="material-symbols-outlined text-primary">bar_chart</span>
            Revenue Trends (Last 6 Months)
          </h3>
          <div className="space-y-md">
            {revenueAnalytics.map((item, idx) => {
              const maxVal = Math.max(...revenueAnalytics.map(r => r.total), 1);
              const paidPercent = (item.paid / maxVal) * 100;
              const unpaidPercent = (item.unpaid / maxVal) * 100;

              return (
                <div key={idx} className="flex flex-col gap-xs">
                  <div className="flex justify-between text-label-md">
                    <span className="font-bold">{item.period}</span>
                    <span>Rs. {item.total.toLocaleString()}</span>
                  </div>
                  <div className="h-4 w-full bg-surface-container rounded-full overflow-hidden flex">
                    <div style={{ width: `${paidPercent}%` }} className="bg-primary h-full" title={`Paid: Rs. ${item.paid.toLocaleString()}`}></div>
                    <div style={{ width: `${unpaidPercent}%` }} className="bg-error/40 h-full" title={`Unpaid: Rs. ${item.unpaid.toLocaleString()}`}></div>
                  </div>
                  <div className="flex justify-between text-[10px] text-on-surface-variant italic">
                    <span>Paid: Rs. {item.paid.toLocaleString()}</span>
                    <span>Unpaid: Rs. {item.unpaid.toLocaleString()}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Area Distribution */}
        <div className="bg-surface-container-lowest rounded-2xl p-lg shadow-sm">
          <h3 className="text-title-lg font-bold mb-lg flex items-center gap-sm">
            <span className="material-symbols-outlined text-secondary">location_on</span>
            Customer Area Distribution
          </h3>
          <div className="max-h-[350px] overflow-y-auto">
            <Table
              columns={[
                { header: 'Area Name', accessor: 'area' },
                { header: 'Customers', accessor: 'count', align: 'right' },
                {
                  header: '% Share',
                  align: 'right',
                  accessor: (item) => (
                    <span className="text-on-surface-variant font-mono">
                      {Math.round((item.count / overview.totalCustomers) * 100)}%
                    </span>
                  )
                }
              ]}
              data={areaDistribution}
            />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-lg mt-md">
        {/* Package Performance */}
        <div className="lg:col-span-2 bg-surface-container-lowest rounded-2xl p-lg shadow-sm">
          <h3 className="text-title-lg font-bold mb-lg flex items-center gap-sm">
            <span className="material-symbols-outlined text-tertiary">inventory_2</span>
            Package Performance
          </h3>
          <Table
            columns={[
              { header: 'Package Name', accessor: 'packageName' },
              { header: 'Active Users', accessor: 'activeSubscribers', align: 'center' },
              {
                header: 'Est. Monthly Revenue',
                align: 'right',
                accessor: (item) => `Rs. ${item.revenue.toLocaleString()}`
              }
            ]}
            data={packagePerformance}
          />
        </div>

        {/* Complaint Categories */}
        <div className="bg-surface-container-lowest rounded-2xl p-lg shadow-sm">
          <h3 className="text-title-lg font-bold mb-lg flex items-center gap-sm">
            <span className="material-symbols-outlined text-error">report_problem</span>
            Complaint Categories
          </h3>
          <div className="space-y-lg pt-md">
            {complaintBreakdown.map((item, idx) => {
              const maxCount = Math.max(...complaintBreakdown.map(c => c.count), 1);
              const percent = (item.count / maxCount) * 100;
              return (
                <div key={idx} className="space-y-xs">
                  <div className="flex justify-between font-label-lg">
                    <span>{item.category}</span>
                    <span className="text-primary">{item.count} tickets</span>
                  </div>
                  <div className="h-2 w-full bg-surface-container rounded-full">
                    <div style={{ width: `${percent}%` }} className="bg-error h-full rounded-full"></div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Payment Methods */}
      <div className="bg-surface-container-lowest rounded-2xl p-lg shadow-sm mt-md">
        <h3 className="text-title-lg font-bold mb-lg flex items-center gap-sm">
          <span className="material-symbols-outlined text-primary">account_balance_wallet</span>
          Payment Method Analysis
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-lg">
          {paymentBreakdown.map((item, idx) => (
            <div key={idx} className="bg-surface-container-low p-md rounded-xl border border-surface-container-high">
              <p className="text-label-sm text-on-surface-variant uppercase font-bold tracking-wider">{item.method}</p>
              <h4 className="text-headline-sm font-bold mt-xs">{item.count} <span className="text-body-sm font-normal">txns</span></h4>
              <p className="text-primary font-bold mt-sm">Rs. {item.amount.toLocaleString()}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

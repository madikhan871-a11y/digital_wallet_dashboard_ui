import { supabase } from './supabase';
import {
  AnalyticsReport,
  DashboardOverview,
  RevenueData,
  CustomerAreaDistribution,
  PackagePerformance,
  PaymentMethodBreakdown,
  ComplaintCategoryBreakdown
} from '../types/report';

export const reportService = {
  async getAnalyticsSummary(startDate?: string, endDate?: string): Promise<AnalyticsReport> {
    // Overview queries
    const [
      customersCount,
      activeCustomersCount,
      subsCount,
      activeSubsCount,
      bills,
      pendingPaymentsCount,
      openTicketsCount
    ] = await Promise.all([
      supabase.from('customers').select('*', { count: 'exact', head: true }),
      supabase.from('customers').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabase.from('subscriptions').select('*', { count: 'exact', head: true }),
      supabase.from('subscriptions').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabase.from('bills').select('*'),
      supabase.from('payments').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
      supabase.from('complaints').select('*', { count: 'exact', head: true }).or('status.eq.open,status.eq.in_progress')
    ]);

    const paidBills = bills.data?.filter(b => b.status === 'paid') || [];
    const unpaidBills = bills.data?.filter(b => b.status === 'unpaid' || b.status === 'overdue') || [];

    const monthlyRevenue = paidBills.reduce((sum, b) => sum + b.total_amount, 0);
    const outstandingBills = unpaidBills.reduce((sum, b) => sum + b.total_amount, 0);

    const overview: DashboardOverview = {
      totalCustomers: customersCount.count || 0,
      activeCustomers: activeCustomersCount.count || 0,
      totalSubscriptions: subsCount.count || 0,
      activeSubscriptions: activeSubsCount.count || 0,
      monthlyRevenue,
      outstandingBills,
      pendingPayments: pendingPaymentsCount.count || 0,
      openTickets: openTicketsCount.count || 0
    };

    // Revenue Analytics (grouped by billing_period_start month)
    const revenueMap = new Map<string, RevenueData>();
    bills.data?.forEach(bill => {
      const date = new Date(bill.billing_period_start);
      const period = `${date.toLocaleString('default', { month: 'short' })} ${date.getFullYear()}`;

      const current = revenueMap.get(period) || { period, paid: 0, unpaid: 0, total: 0 };
      if (bill.status === 'paid') {
        current.paid += bill.total_amount;
      } else {
        current.unpaid += bill.total_amount;
      }
      current.total += bill.total_amount;
      revenueMap.set(period, current);
    });
    const revenueAnalytics = Array.from(revenueMap.values()).slice(-6);

    // Customer Area Distribution
    const { data: customers } = await supabase.from('customers').select('area');
    const areaMap = new Map<string, number>();
    customers?.forEach(c => {
      areaMap.set(c.area, (areaMap.get(c.area) || 0) + 1);
    });
    const areaDistribution: CustomerAreaDistribution[] = Array.from(areaMap.entries())
      .map(([area, count]) => ({ area, count }))
      .sort((a, b) => b.count - a.count);

    // Package Performance
    const { data: subDetails } = await supabase
      .from('subscriptions')
      .select('*, package:packages(*)');

    const pkgMap = new Map<string, PackagePerformance>();
    subDetails?.forEach(sub => {
      if (!sub.package) return;
      const current = pkgMap.get(sub.package.name) || {
        packageName: sub.package.name,
        activeSubscribers: 0,
        revenue: 0
      };
      if (sub.status === 'active') {
        current.activeSubscribers += 1;
        current.revenue += sub.price_override || sub.package.price_per_month;
      }
      pkgMap.set(sub.package.name, current);
    });
    const packagePerformance = Array.from(pkgMap.values()).sort((a, b) => b.activeSubscribers - a.activeSubscribers);

    // Payment Breakdown
    const { data: payments } = await supabase.from('payments').select('*');
    const payMap = new Map<string, PaymentMethodBreakdown>();
    payments?.forEach(p => {
      const current = payMap.get(p.payment_method) || { method: p.payment_method, count: 0, amount: 0 };
      current.count += 1;
      if (p.status === 'approved') {
        current.amount += p.amount;
      }
      payMap.set(p.payment_method, current);
    });
    const paymentBreakdown = Array.from(payMap.values());

    // Complaint Breakdown
    const { data: complaints } = await supabase.from('complaints').select('category');
    const compMap = new Map<string, number>();
    complaints?.forEach(c => {
      compMap.set(c.category, (compMap.get(c.category) || 0) + 1);
    });
    const complaintBreakdown: ComplaintCategoryBreakdown[] = Array.from(compMap.entries())
      .map(([category, count]) => ({ category, count }));

    return {
      overview,
      revenueAnalytics,
      areaDistribution,
      packagePerformance,
      paymentBreakdown,
      complaintBreakdown
    };
  }
};

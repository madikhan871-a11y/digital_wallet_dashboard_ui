export interface DashboardOverview {
  totalCustomers: number;
  activeCustomers: number;
  totalSubscriptions: number;
  activeSubscriptions: number;
  monthlyRevenue: number;
  outstandingBills: number;
  pendingPayments: number;
  openTickets: number;
}

export interface RevenueData {
  period: string;
  paid: number;
  unpaid: number;
  total: number;
}

export interface CustomerAreaDistribution {
  area: string;
  count: number;
}

export interface PackagePerformance {
  packageName: string;
  activeSubscribers: number;
  revenue: number;
}

export interface PaymentMethodBreakdown {
  method: string;
  count: number;
  amount: number;
}

export interface ComplaintCategoryBreakdown {
  category: string;
  count: number;
}

export interface AnalyticsReport {
  overview: DashboardOverview;
  revenueAnalytics: RevenueData[];
  areaDistribution: CustomerAreaDistribution[];
  packagePerformance: PackagePerformance[];
  paymentBreakdown: PaymentMethodBreakdown[];
  complaintBreakdown: ComplaintCategoryBreakdown[];
}

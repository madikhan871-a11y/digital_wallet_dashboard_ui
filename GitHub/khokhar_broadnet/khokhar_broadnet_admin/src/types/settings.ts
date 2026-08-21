export interface SystemSetting {
  key: string;
  value: any;
  category: 'business' | 'billing' | 'notifications' | 'security';
  description?: string;
  updated_at?: string;
}

export interface ISPInfo {
  name: string;
  supportPhone: string;
  whatsappNumber: string;
  email: string;
  address: string;
}

export interface BillingSettings {
  taxPercentage: number;
  currency: string;
  defaultDueDateDays: number;
}

export interface AdminProfile {
  id: string;
  name: string;
  email: string;
  avatarUrl?: string;
}

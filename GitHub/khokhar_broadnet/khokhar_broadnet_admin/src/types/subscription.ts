import { Customer } from './customer';
import { Package } from './package';

export type SubscriptionStatus = 'active' | 'pending' | 'expired' | 'suspended';

export interface Subscription {
  id: string;
  customer_id: string;
  package_id: string;
  status: SubscriptionStatus;
  start_date: string;
  expiry_date: string;
  price_override?: number;
  notes?: string;
  created_at: string;

  // Joined data
  customer?: Customer;
  package?: Package;
}

export interface SubscriptionWithDetails extends Subscription {
  customer: Customer;
  package: Package;
}

export interface CreateSubscriptionInput {
  customer_id: string;
  package_id: string;
  status: SubscriptionStatus;
  start_date: string;
  expiry_date: string;
  price_override?: number;
  notes?: string;
}

export interface UpdateSubscriptionInput extends Partial<CreateSubscriptionInput> {}

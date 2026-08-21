import { Customer } from './customer';
import { Bill } from './bill';

export type PaymentStatus = 'pending' | 'approved' | 'rejected';

export interface Payment {
  id: string;
  customer_id: string;
  bill_id?: string;
  amount: number;
  payment_method: string;
  transaction_id: string;
  screenshot_url?: string;
  status: PaymentStatus;
  rejection_reason?: string;
  verified_at?: string;
  verified_by?: string;
  created_at: string;

  // Joined data
  customer?: Customer;
  bill?: Bill;
}

export interface PaymentWithDetails extends Payment {
  customer: Customer;
  bill?: Bill;
}

export interface VerifyPaymentInput {
  status: 'approved' | 'rejected';
  rejection_reason?: string;
}

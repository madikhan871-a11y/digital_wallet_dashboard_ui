import { Customer } from './customer';

export type BillStatus = 'unpaid' | 'paid' | 'overdue' | 'cancelled';

export interface Bill {
  id: string;
  invoice_number: string;
  customer_id: string;
  subscription_id?: string;
  billing_period_start: string;
  billing_period_end: string;
  base_amount: number;
  tax_amount: number;
  previous_balance: number;
  total_amount: number;
  due_date: string;
  status: BillStatus;
  paid_at?: string;
  payment_method?: string;
  notes?: string;
  created_at: string;

  // Joined data
  customer?: Customer;
}

export interface BillWithDetails extends Bill {
  customer: Customer;
}

export interface CreateBillInput {
  customer_id: string;
  subscription_id?: string;
  billing_period_start: string;
  billing_period_end: string;
  base_amount: number;
  tax_amount: number;
  previous_balance: number;
  total_amount: number;
  due_date: string;
  status: BillStatus;
  notes?: string;
}

export interface UpdateBillInput extends Partial<CreateBillInput> {
  paid_at?: string;
  payment_method?: string;
}

import { Customer } from './customer';

export type ComplaintStatus = 'open' | 'in_progress' | 'resolved' | 'closed';
export type ComplaintCategory = 'Technical' | 'Billing' | 'Service';

export interface Complaint {
  id: string;
  ticket_number: string;
  customer_id: string;
  category: ComplaintCategory;
  subject: string;
  description: string;
  status: ComplaintStatus;
  attachment_url?: string;
  admin_response?: string;
  resolved_at?: string;
  created_at: string;
  updated_at: string;

  // Joined data
  customer?: Customer;
}

export interface ComplaintWithDetails extends Complaint {
  customer: Customer;
}

export interface UpdateComplaintInput {
  status?: ComplaintStatus;
  admin_response?: string;
  resolved_at?: string;
}

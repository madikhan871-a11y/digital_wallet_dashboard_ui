import { Customer } from './customer';

export interface Notification {
  id: string;
  customer_id: string;
  title: string;
  body: string;
  is_read: boolean;
  created_at: string;

  // Joined data
  customer?: Customer;
}

export interface NotificationWithDetails extends Notification {
  customer: Customer;
}

export interface CreateNotificationInput {
  customer_id: string;
  title: string;
  body: string;
}

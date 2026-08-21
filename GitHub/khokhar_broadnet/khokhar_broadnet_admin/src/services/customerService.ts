import { supabase } from './supabase';
import { Customer, CustomerStatus } from '../types/customer';

export const customerService = {
  async getCustomers(options?: {
    search?: string;
    status?: CustomerStatus | 'all';
    area?: string;
    page?: number;
    pageSize?: number;
  }) {
    const { search, status, area, page = 1, pageSize = 20 } = options || {};

    let query = supabase
      .from('customers')
      .select('*, subscription:subscriptions(id, package_name, speed)', { count: 'exact' });

    if (status && status !== 'all') {
      query = query.eq('status', status);
    }

    if (area && area !== 'all') {
      query = query.eq('area', area);
    }

    if (search) {
      query = query.or(`full_name.ilike.%${search}%,phone.ilike.%${search}%,kb_id.ilike.%${search}%,email.ilike.%${search}%`);
    }

    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) throw error;
    return { data: data as Customer[], count };
  },

  async getCustomerById(id: string) {
    const { data, error } = await supabase
      .from('customers')
      .select('*, subscription:subscriptions(id, package_name, speed)')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data as Customer;
  },

  async updateCustomerStatus(id: string, status: CustomerStatus) {
    const { data, error } = await supabase
      .from('customers')
      .update({ status })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Customer;
  }
};

import { supabase } from './supabase';
import {
  Subscription,
  SubscriptionWithDetails,
  CreateSubscriptionInput,
  UpdateSubscriptionInput,
  SubscriptionStatus
} from '../types/subscription';

export const subscriptionService = {
  async getSubscriptions(options?: {
    search?: string;
    status?: SubscriptionStatus | 'all';
    packageId?: string;
    page?: number;
    pageSize?: number;
  }) {
    const { search, status, packageId, page = 1, pageSize = 20 } = options || {};

    let query = supabase
      .from('subscriptions')
      .select(`
        *,
        customer:customers(*),
        package:packages(*)
      `, { count: 'exact' });

    if (status && status !== 'all') {
      query = query.eq('status', status);
    }

    if (packageId && packageId !== 'all') {
      query = query.eq('package_id', packageId);
    }

    if (search) {
      // Searching across customer fields using joined table logic in Supabase can be tricky depending on schema
      // Usually, it's better to search via customer names or KB IDs
      query = query.or(`notes.ilike.%${search}%`);
      // Note: Full-text search across joins often requires specialized Supabase configurations
      // or multiple queries. For simplicity here, we assume standard filtering.
    }

    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) throw error;

    // Manual filtering for search if Supabase join search is limited
    let filteredData = data as SubscriptionWithDetails[];
    if (search) {
      const searchLower = search.toLowerCase();
      filteredData = filteredData.filter(sub =>
        sub.customer.full_name.toLowerCase().includes(searchLower) ||
        sub.customer.kb_id.toLowerCase().includes(searchLower) ||
        sub.customer.phone.toLowerCase().includes(searchLower) ||
        sub.package.name.toLowerCase().includes(searchLower)
      );
    }

    return { data: filteredData, count };
  },

  async getSubscriptionById(id: string) {
    const { data, error } = await supabase
      .from('subscriptions')
      .select(`
        *,
        customer:customers(*),
        package:packages(*)
      `)
      .eq('id', id)
      .single();

    if (error) throw error;
    return data as SubscriptionWithDetails;
  },

  async createSubscription(input: CreateSubscriptionInput) {
    const { data, error } = await supabase
      .from('subscriptions')
      .insert([input])
      .select()
      .single();

    if (error) throw error;
    return data as Subscription;
  },

  async updateSubscription(id: string, input: UpdateSubscriptionInput) {
    const { data, error } = await supabase
      .from('subscriptions')
      .update(input)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Subscription;
  },

  async updateSubscriptionStatus(id: string, status: SubscriptionStatus) {
    const { data, error } = await supabase
      .from('subscriptions')
      .update({ status })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Subscription;
  },

  async deleteSubscription(id: string) {
    const { error } = await supabase
      .from('subscriptions')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }
};

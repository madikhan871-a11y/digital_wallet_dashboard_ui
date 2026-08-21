import { supabase } from './supabase';
import { Notification, NotificationWithDetails, CreateNotificationInput } from '../types/notification';

export const notificationService = {
  async getNotifications(options?: {
    search?: string;
    isRead?: boolean | 'all';
    page?: number;
    pageSize?: number;
  }) {
    const { search, isRead, page = 1, pageSize = 20 } = options || {};

    let query = supabase
      .from('notifications')
      .select('*, customer:customers(*)', { count: 'exact' });

    if (isRead !== undefined && isRead !== 'all') {
      query = query.eq('is_read', isRead);
    }

    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) throw error;

    let filteredData = data as NotificationWithDetails[];
    if (search) {
      const searchLower = search.toLowerCase();
      filteredData = filteredData.filter(notification =>
        notification.title.toLowerCase().includes(searchLower) ||
        notification.body.toLowerCase().includes(searchLower) ||
        notification.customer.full_name.toLowerCase().includes(searchLower) ||
        notification.customer.kb_id.toLowerCase().includes(searchLower)
      );
    }

    return { data: filteredData, count };
  },

  async createNotification(input: CreateNotificationInput) {
    const { data, error } = await supabase
      .from('notifications')
      .insert([input])
      .select()
      .single();

    if (error) throw error;
    return data as Notification;
  },

  async deleteNotification(id: string) {
    const { error } = await supabase
      .from('notifications')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }
};

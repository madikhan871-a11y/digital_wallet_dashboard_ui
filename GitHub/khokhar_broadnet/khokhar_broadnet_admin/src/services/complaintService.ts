import { supabase } from './supabase';
import { Complaint, ComplaintWithDetails, UpdateComplaintInput, ComplaintStatus, ComplaintCategory } from '../types/complaint';

export const complaintService = {
  async getComplaints(options?: {
    search?: string;
    status?: ComplaintStatus | 'all';
    category?: ComplaintCategory | 'all';
    page?: number;
    pageSize?: number;
  }) {
    const { search, status, category, page = 1, pageSize = 20 } = options || {};

    let query = supabase
      .from('complaints')
      .select('*, customer:customers(*)', { count: 'exact' });

    if (status && status !== 'all') {
      query = query.eq('status', status);
    }

    if (category && category !== 'all') {
      query = query.eq('category', category);
    }

    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) throw error;

    let filteredData = data as ComplaintWithDetails[];
    if (search) {
      const searchLower = search.toLowerCase();
      filteredData = filteredData.filter(complaint =>
        complaint.ticket_number.toLowerCase().includes(searchLower) ||
        complaint.subject.toLowerCase().includes(searchLower) ||
        complaint.customer.full_name.toLowerCase().includes(searchLower) ||
        complaint.customer.kb_id.toLowerCase().includes(searchLower) ||
        complaint.customer.phone.toLowerCase().includes(searchLower)
      );
    }

    return { data: filteredData, count };
  },

  async getComplaintById(id: string) {
    const { data, error } = await supabase
      .from('complaints')
      .select('*, customer:customers(*)')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data as ComplaintWithDetails;
  },

  async updateComplaint(id: string, input: UpdateComplaintInput) {
    const updateData: any = { ...input, updated_at: new Date().toISOString() };

    if (input.status === 'resolved' && !input.resolved_at) {
      updateData.resolved_at = new Date().toISOString();
    }

    const { data, error } = await supabase
      .from('complaints')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Complaint;
  }
};

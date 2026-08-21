import { supabase } from './supabase';
import { Bill, BillWithDetails, CreateBillInput, UpdateBillInput, BillStatus } from '../types/bill';

export const billService = {
  async getBills(options?: {
    search?: string;
    status?: BillStatus | 'all';
    startDate?: string;
    endDate?: string;
    page?: number;
    pageSize?: number;
  }) {
    const { search, status, startDate, endDate, page = 1, pageSize = 20 } = options || {};

    let query = supabase
      .from('bills')
      .select('*, customer:customers(*)', { count: 'exact' });

    if (status && status !== 'all') {
      query = query.eq('status', status);
    }

    if (startDate) {
      query = query.gte('billing_period_start', startDate);
    }

    if (endDate) {
      query = query.lte('billing_period_end', endDate);
    }

    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) throw error;

    let filteredData = data as BillWithDetails[];
    if (search) {
      const searchLower = search.toLowerCase();
      filteredData = filteredData.filter(bill =>
        bill.invoice_number.toLowerCase().includes(searchLower) ||
        bill.customer.full_name.toLowerCase().includes(searchLower) ||
        bill.customer.kb_id.toLowerCase().includes(searchLower) ||
        bill.customer.phone.toLowerCase().includes(searchLower)
      );
    }

    return { data: filteredData, count };
  },

  async getBillById(id: string) {
    const { data, error } = await supabase
      .from('bills')
      .select('*, customer:customers(*)')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data as BillWithDetails;
  },

  async createBill(input: CreateBillInput) {
    // Auto-generate invoice number if not provided (usually handled by DB but for robustness)
    const invoice_number = `INV-${Date.now().toString().slice(-8)}`;

    const { data, error } = await supabase
      .from('bills')
      .insert([{ ...input, invoice_number }])
      .select()
      .single();

    if (error) throw error;
    return data as Bill;
  },

  async updateBill(id: string, input: UpdateBillInput) {
    const { data, error } = await supabase
      .from('bills')
      .update(input)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Bill;
  },

  async markAsPaid(id: string, paymentMethod: string) {
    const { data, error } = await supabase
      .from('bills')
      .update({
        status: 'paid',
        paid_at: new Date().toISOString(),
        payment_method: paymentMethod
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Bill;
  },

  async deleteBill(id: string) {
    const { error } = await supabase
      .from('bills')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }
};

import { supabase } from './supabase';
import { Payment, PaymentWithDetails, VerifyPaymentInput, PaymentStatus } from '../types/payment';

export const paymentService = {
  async getPayments(options?: {
    search?: string;
    status?: PaymentStatus | 'all';
    method?: string | 'all';
    page?: number;
    pageSize?: number;
  }) {
    const { search, status, method, page = 1, pageSize = 20 } = options || {};

    let query = supabase
      .from('payments')
      .select('*, customer:customers(*), bill:bills(*)', { count: 'exact' });

    if (status && status !== 'all') {
      query = query.eq('status', status);
    }

    if (method && method !== 'all') {
      query = query.eq('payment_method', method);
    }

    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) throw error;

    let filteredData = data as PaymentWithDetails[];
    if (search) {
      const searchLower = search.toLowerCase();
      filteredData = filteredData.filter(payment =>
        payment.transaction_id?.toLowerCase().includes(searchLower) ||
        payment.customer.full_name.toLowerCase().includes(searchLower) ||
        payment.customer.kb_id.toLowerCase().includes(searchLower) ||
        payment.customer.phone.toLowerCase().includes(searchLower) ||
        payment.bill?.invoice_number.toLowerCase().includes(searchLower)
      );
    }

    return { data: filteredData, count };
  },

  async verifyPayment(id: string, input: VerifyPaymentInput) {
    const { data: payment, error: fetchError } = await supabase
      .from('payments')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError) throw fetchError;
    if (payment.status !== 'pending') {
      throw new Error('This payment has already been processed.');
    }

    const { data, error } = await supabase
      .from('payments')
      .update({
        status: input.status,
        rejection_reason: input.rejection_reason,
        verified_at: new Date().toISOString(),
        // verified_by would normally be the current user ID
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    // If approved, update the related bill
    if (input.status === 'approved' && payment.bill_id) {
      const { error: billError } = await supabase
        .from('bills')
        .update({
          status: 'paid',
          paid_at: new Date().toISOString(),
          payment_method: payment.payment_method
        })
        .eq('id', payment.bill_id);

      if (billError) throw billError;
    }

    return data as Payment;
  }
};

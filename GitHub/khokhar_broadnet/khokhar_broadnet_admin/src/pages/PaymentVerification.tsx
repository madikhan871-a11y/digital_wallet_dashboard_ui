import React, { useEffect, useState } from 'react';
import { paymentService } from '../services/paymentService';
import { PaymentWithDetails, PaymentStatus } from '../types/payment';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';

export const PaymentVerification: React.FC = () => {
  const [payments, setPayments] = useState<PaymentWithDetails[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<PaymentStatus | 'all'>('all');
  const [methodFilter, setMethodFilter] = useState<string>('all');

  // Modal states
  const [selectedPayment, setSelectedPayment] = useState<PaymentWithDetails | null>(null);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [isRejectModalOpen, setIsRejectModalOpen] = useState(false);
  const [rejectionReason, setRejectionReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const paymentMethods = ['all', 'EasyPaisa', 'JazzCash', 'Bank Transfer'];

  const fetchPayments = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await paymentService.getPayments({
        search,
        status: statusFilter,
        method: methodFilter,
      });
      setPayments(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch payments');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPayments();
  }, [search, statusFilter, methodFilter]);

  const handleVerify = async (status: 'approved' | 'rejected') => {
    if (!selectedPayment) return;

    if (status === 'approved' && !window.confirm('Are you sure you want to approve this payment? This will mark the related bill as paid.')) {
      return;
    }

    try {
      setIsSubmitting(true);
      await paymentService.verifyPayment(selectedPayment.id, {
        status,
        rejection_reason: status === 'rejected' ? rejectionReason : undefined,
      });

      setIsDetailsModalOpen(false);
      setIsRejectModalOpen(false);
      setRejectionReason('');
      fetchPayments();
    } catch (err: any) {
      alert(err.message || 'Failed to verify payment');
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusVariant = (status: PaymentStatus): 'success' | 'pending' | 'error' | 'info' => {
    switch (status) {
      case 'approved': return 'success';
      case 'pending': return 'pending';
      case 'rejected': return 'error';
      default: return 'info';
    }
  };

  const stats = {
    total: payments.length,
    pending: payments.filter(p => p.status === 'pending').length,
    approved: payments.filter(p => p.status === 'approved').length,
    rejected: payments.filter(p => p.status === 'rejected').length,
  };

  const columns = [
    {
      header: 'Customer',
      accessor: (item: PaymentWithDetails) => (
        <div className="flex flex-col">
          <span className="font-title-md text-on-surface">{item.customer.full_name}</span>
          <span className="text-[11px] text-on-surface-variant font-mono">{item.customer.kb_id}</span>
        </div>
      )
    },
    {
      header: 'Invoice',
      accessor: (item: PaymentWithDetails) => (
        <span className="font-mono text-primary font-bold">
          {item.bill?.invoice_number || 'N/A'}
        </span>
      )
    },
    {
      header: 'Amount',
      accessor: (item: PaymentWithDetails) => (
        <span className="font-label-lg">Rs. {item.amount.toLocaleString()}</span>
      )
    },
    {
      header: 'Method',
      accessor: (item: PaymentWithDetails) => (
        <div className="flex items-center gap-xs">
          <span className="material-symbols-outlined text-[18px] text-on-surface-variant">
            {item.payment_method.toLowerCase().includes('bank') ? 'account_balance' : 'smartphone'}
          </span>
          <span>{item.payment_method}</span>
        </div>
      )
    },
    {
      header: 'Transaction ID',
      accessor: (item: PaymentWithDetails) => (
        <span className="font-mono text-[12px]">{item.transaction_id}</span>
      )
    },
    {
      header: 'Submitted',
      accessor: (item: PaymentWithDetails) => (
        <span className="text-[12px] text-on-surface-variant">
          {new Date(item.created_at).toLocaleDateString()}
        </span>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: PaymentWithDetails) => (
        <Badge variant={getStatusVariant(item.status)}>
          {item.status.toUpperCase()}
        </Badge>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: PaymentWithDetails) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={(e) => { e.stopPropagation(); setSelectedPayment(item); setIsDetailsModalOpen(true); }}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="View Details"
          >
            <span className="material-symbols-outlined text-[20px]">visibility</span>
          </button>
          {item.status === 'pending' && (
            <>
              <button
                onClick={(e) => { e.stopPropagation(); setSelectedPayment(item); handleVerify('approved'); }}
                className="w-8 h-8 rounded-full hover:bg-success/10 flex items-center justify-center text-on-surface-variant hover:text-success transition-colors"
                title="Approve"
              >
                <span className="material-symbols-outlined text-[20px]">check_circle</span>
              </button>
              <button
                onClick={(e) => { e.stopPropagation(); setSelectedPayment(item); setIsRejectModalOpen(true); }}
                className="w-8 h-8 rounded-full hover:bg-error/10 flex items-center justify-center text-on-surface-variant hover:text-error transition-colors"
                title="Reject"
              >
                <span className="material-symbols-outlined text-[20px]">cancel</span>
              </button>
            </>
          )}
        </div>
      )
    }
  ];

  return (
    <div className="flex flex-col w-full h-full gap-lg">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-md mb-md">
        <div className="flex flex-col">
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Payment Verification</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Review and verify mobile app payment submissions.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-md mb-lg">
        <StatCard label="Total Submissions" value={stats.total} icon="payments" variant="primary" />
        <StatCard label="Pending" value={stats.pending} icon="pending_actions" variant="tertiary" />
        <StatCard label="Approved" value={stats.approved} icon="check_circle" variant="secondary" />
        <StatCard label="Rejected" value={stats.rejected} icon="cancel" variant="error" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search Trans ID, Customer, or Invoice..."
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <div className="flex w-full overflow-x-auto gap-sm">
          <select
            className="bg-surface-container hover:bg-surface-container-high text-on-surface font-label-lg text-label-lg py-sm px-md rounded-lg outline-none cursor-pointer transition-colors"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as any)}
          >
            <option value="all">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </select>

          <select
            className="bg-surface-container hover:bg-surface-container-high text-on-surface font-label-lg text-label-lg py-sm px-md rounded-lg outline-none cursor-pointer transition-colors"
            value={methodFilter}
            onChange={(e) => setMethodFilter(e.target.value)}
          >
            {paymentMethods.map(m => (
              <option key={m} value={m}>{m === 'all' ? 'All Methods' : m}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex-1 flex flex-col min-h-[400px]">
        {loading ? (
          <LoadingState />
        ) : error ? (
          <div className="p-xl text-center text-error">
            <span className="material-symbols-outlined text-[48px] mb-md">error</span>
            <p>{error}</p>
            <Button onClick={fetchPayments} className="mt-md">Retry</Button>
          </div>
        ) : payments.length === 0 ? (
          <EmptyState
            icon="payments"
            title="No Payments Found"
            description="No payment submissions match your criteria."
            actionLabel="Clear Filters"
            onAction={() => { setSearch(''); setStatusFilter('all'); setMethodFilter('all'); }}
          />
        ) : (
          <Table
            columns={columns}
            data={payments}
            onRowClick={(item) => { setSelectedPayment(item); setIsDetailsModalOpen(true); }}
          />
        )}
      </div>

      {/* Details Modal */}
      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Payment Verification Details"
        size="lg"
      >
        {selectedPayment && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-lg">
            <div className="flex flex-col gap-lg">
              <div className="bg-surface-container-low p-md rounded-xl space-y-md">
                <div className="flex justify-between items-start">
                  <div>
                    <h3 className="font-title-lg text-on-surface">{selectedPayment.customer.full_name}</h3>
                    <p className="text-body-sm text-on-surface-variant">{selectedPayment.customer.kb_id}</p>
                  </div>
                  <Badge variant={getStatusVariant(selectedPayment.status)}>{selectedPayment.status.toUpperCase()}</Badge>
                </div>

                <div className="grid grid-cols-2 gap-md">
                  <div>
                    <p className="text-label-md text-on-surface-variant uppercase">Amount</p>
                    <p className="font-bold text-title-md">Rs. {selectedPayment.amount.toLocaleString()}</p>
                  </div>
                  <div>
                    <p className="text-label-md text-on-surface-variant uppercase">Method</p>
                    <p className="font-bold">{selectedPayment.payment_method}</p>
                  </div>
                  <div className="col-span-2">
                    <p className="text-label-md text-on-surface-variant uppercase">Transaction ID</p>
                    <p className="font-mono bg-surface-container-high p-xs rounded">{selectedPayment.transaction_id}</p>
                  </div>
                </div>
              </div>

              {selectedPayment.bill && (
                <div className="bg-primary/5 p-md rounded-xl border border-primary/10">
                  <h4 className="font-label-lg text-primary uppercase mb-xs">Related Invoice</h4>
                  <div className="flex justify-between items-center">
                    <div>
                      <p className="font-bold">{selectedPayment.bill.invoice_number}</p>
                      <p className="text-[11px] text-on-surface-variant">Due: {new Date(selectedPayment.bill.due_date).toLocaleDateString()}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-bold">Rs. {selectedPayment.bill.total_amount.toLocaleString()}</p>
                      <Badge variant={selectedPayment.bill.status === 'paid' ? 'success' : 'pending'}>{selectedPayment.bill.status}</Badge>
                    </div>
                  </div>
                </div>
              )}

              {selectedPayment.status === 'rejected' && (
                <div className="bg-error/5 p-md rounded-xl border border-error/10">
                  <h4 className="font-label-lg text-error uppercase mb-xs">Rejection Reason</h4>
                  <p className="text-body-md italic">{selectedPayment.rejection_reason || 'No reason provided.'}</p>
                </div>
              )}

              {selectedPayment.status === 'pending' && (
                <div className="flex gap-md pt-md mt-auto">
                  <Button
                    className="flex-1"
                    variant="error"
                    icon="cancel"
                    onClick={() => setIsRejectModalOpen(true)}
                  >
                    Reject
                  </Button>
                  <Button
                    className="flex-1"
                    variant="primary"
                    icon="check_circle"
                    isLoading={isSubmitting}
                    onClick={() => handleVerify('approved')}
                  >
                    Approve
                  </Button>
                </div>
              )}
            </div>

            <div className="flex flex-col gap-sm">
              <h4 className="font-label-lg text-on-surface-variant uppercase">Payment Proof</h4>
              <div className="flex-1 bg-surface-container-high rounded-xl overflow-hidden min-h-[300px] flex items-center justify-center border-2 border-dashed border-outline-variant">
                {selectedPayment.screenshot_url ? (
                  <img
                    src={selectedPayment.screenshot_url}
                    alt="Payment Proof"
                    className="w-full h-full object-contain cursor-zoom-in"
                    onClick={() => window.open(selectedPayment.screenshot_url, '_blank')}
                  />
                ) : (
                  <div className="flex flex-col items-center gap-md text-on-surface-variant opacity-50">
                    <span className="material-symbols-outlined text-[64px]">image_not_supported</span>
                    <p>No screenshot attached</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </Modal>

      {/* Reject Modal */}
      <Modal
        isOpen={isRejectModalOpen}
        onClose={() => setIsRejectModalOpen(false)}
        title="Reject Payment"
        size="sm"
      >
        <div className="flex flex-col gap-lg">
          <p className="text-body-md text-on-surface-variant">
            Please provide a reason for rejecting this payment submission. This will be visible to the customer.
          </p>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Rejection Reason *</label>
            <textarea
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none min-h-[100px]"
              placeholder="e.g. Invalid transaction ID, Screenshot blurred..."
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
            />
          </div>
          <div className="flex justify-end gap-md">
            <Button variant="ghost" onClick={() => setIsRejectModalOpen(false)}>Cancel</Button>
            <Button
              variant="error"
              icon="cancel"
              isLoading={isSubmitting}
              disabled={!rejectionReason.trim()}
              onClick={() => handleVerify('rejected')}
            >
              Confirm Reject
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

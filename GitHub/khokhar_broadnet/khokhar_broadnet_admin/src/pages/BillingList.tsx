import React, { useEffect, useState } from 'react';
import { billService } from '../services/billService';
import { customerService } from '../services/customerService';
import { subscriptionService } from '../services/subscriptionService';
import { BillWithDetails, BillStatus, CreateBillInput, UpdateBillInput } from '../types/bill';
import { Customer } from '../types/customer';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';

export const BillingList: React.FC = () => {
  const [bills, setBills] = useState<BillWithDetails[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<BillStatus | 'all'>('all');

  const [customers, setCustomers] = useState<Customer[]>([]);

  // Modal states
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [isPaymentModalOpen, setIsPaymentModalOpen] = useState(false);
  const [selectedBill, setSelectedBill] = useState<BillWithDetails | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form states
  const [formData, setFormData] = useState<Partial<CreateBillInput>>({
    status: 'unpaid',
    tax_amount: 0,
    previous_balance: 0,
  });
  const [paymentMethod, setPaymentMethod] = useState('Cash');

  const fetchInitialData = async () => {
    try {
      const { data } = await customerService.getCustomers({ pageSize: 1000 });
      setCustomers(data);
    } catch (err) {
      console.error('Failed to fetch customers', err);
    }
  };

  const fetchBills = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await billService.getBills({
        search,
        status: statusFilter,
      });
      setBills(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch bills');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchInitialData();
  }, []);

  useEffect(() => {
    fetchBills();
  }, [search, statusFilter]);

  const handleCreateBill = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsSubmitting(true);
      await billService.createBill(formData as CreateBillInput);
      setIsFormModalOpen(false);
      fetchBills();
    } catch (err: any) {
      alert(err.message || 'Failed to create bill');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleMarkAsPaid = async () => {
    if (!selectedBill) return;
    try {
      setIsSubmitting(true);
      await billService.markAsPaid(selectedBill.id, paymentMethod);
      setIsPaymentModalOpen(false);
      fetchBills();
    } catch (err: any) {
      alert(err.message || 'Failed to process payment');
    } finally {
      setIsSubmitting(false);
    }
  };

  const openDetailsModal = (bill: BillWithDetails) => {
    setSelectedBill(bill);
    setIsDetailsModalOpen(true);
  };

  const openPaymentModal = (e: React.MouseEvent, bill: BillWithDetails) => {
    e.stopPropagation();
    setSelectedBill(bill);
    setIsPaymentModalOpen(true);
  };

  const getStatusVariant = (status: BillStatus): 'success' | 'pending' | 'error' | 'info' => {
    switch (status) {
      case 'paid': return 'success';
      case 'unpaid': return 'pending';
      case 'overdue': return 'error';
      case 'cancelled': return 'info';
      default: return 'info';
    }
  };

  const stats = {
    totalBills: bills.length,
    paid: bills.filter(b => b.status === 'paid').length,
    unpaid: bills.filter(b => b.status === 'unpaid').length,
    overdue: bills.filter(b => b.status === 'overdue').length,
    revenue: bills.filter(b => b.status === 'paid').reduce((acc, curr) => acc + curr.total_amount, 0),
  };

  const columns = [
    {
      header: 'Invoice #',
      accessor: (item: BillWithDetails) => (
        <span className="font-mono text-primary font-bold">{item.invoice_number}</span>
      )
    },
    {
      header: 'Customer',
      accessor: (item: BillWithDetails) => (
        <div className="flex flex-col">
          <span className="font-title-md text-on-surface">{item.customer.full_name}</span>
          <span className="text-[11px] text-on-surface-variant font-mono">{item.customer.kb_id}</span>
        </div>
      )
    },
    {
      header: 'Period',
      accessor: (item: BillWithDetails) => (
        <div className="text-[12px] text-on-surface-variant">
          {new Date(item.billing_period_start).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })} -
          {new Date(item.billing_period_end).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}
        </div>
      )
    },
    {
      header: 'Amount',
      accessor: (item: BillWithDetails) => (
        <span className="font-label-lg">Rs. {item.total_amount.toLocaleString()}</span>
      )
    },
    {
      header: 'Due Date',
      accessor: (item: BillWithDetails) => (
        <div className={`text-[12px] ${item.status === 'overdue' ? 'text-error font-bold' : 'text-on-surface-variant'}`}>
          {new Date(item.due_date).toLocaleDateString()}
        </div>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: BillWithDetails) => (
        <Badge variant={getStatusVariant(item.status)}>
          {item.status.toUpperCase()}
        </Badge>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: BillWithDetails) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => openDetailsModal(item)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="View Invoice"
          >
            <span className="material-symbols-outlined text-[20px]">visibility</span>
          </button>
          {item.status !== 'paid' && (
            <button
              onClick={(e) => openPaymentModal(e, item)}
              className="w-8 h-8 rounded-full hover:bg-success/10 flex items-center justify-center text-on-surface-variant hover:text-success transition-colors"
              title="Mark as Paid"
            >
              <span className="material-symbols-outlined text-[20px]">payments</span>
            </button>
          )}
        </div>
      )
    }
  ];

  return (
    <div className="flex flex-col w-full h-full gap-lg">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-md mb-md">
        <div className="flex flex-col">
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Billing & Invoices</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Manage customer invoices, track payments, and monitor revenue.</p>
        </div>
        <div className="flex items-center gap-md">
          <Button variant="ghost" icon="print">Bulk Print</Button>
          <Button icon="add" onClick={() => setIsFormModalOpen(true)}>Create Bill</Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-md mb-lg">
        <StatCard label="Total Bills" value={stats.totalBills} icon="receipt_long" variant="primary" />
        <StatCard label="Paid" value={stats.paid} icon="check_circle" variant="secondary" />
        <StatCard label="Unpaid" value={stats.unpaid} icon="pending_actions" variant="tertiary" />
        <StatCard label="Overdue" value={stats.overdue} icon="warning" variant="error" />
        <StatCard label="Revenue" value={`Rs. ${stats.revenue.toLocaleString()}`} icon="payments" variant="secondary" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search Invoice #, Customer, or Phone..."
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
            <option value="paid">Paid</option>
            <option value="unpaid">Unpaid</option>
            <option value="overdue">Overdue</option>
            <option value="cancelled">Cancelled</option>
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
            <Button onClick={fetchBills} className="mt-md">Retry</Button>
          </div>
        ) : bills.length === 0 ? (
          <EmptyState
            icon="receipt_long"
            title="No Invoices Found"
            description="No billing records match your current search or filters."
            actionLabel="Clear Filters"
            onAction={() => { setSearch(''); setStatusFilter('all'); }}
          />
        ) : (
          <Table
            columns={columns}
            data={bills}
            onRowClick={(item) => openDetailsModal(item)}
          />
        )}
      </div>

      {/* Create Modal */}
      <Modal
        isOpen={isFormModalOpen}
        onClose={() => setIsFormModalOpen(false)}
        title="Create New Invoice"
        size="lg"
      >
        <form onSubmit={handleCreateBill} className="flex flex-col gap-lg">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-md">
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Customer *</label>
              <select
                required
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
                onChange={(e) => setFormData({ ...formData, customer_id: e.target.value })}
              >
                <option value="">Select Customer</option>
                {customers.map(c => (
                  <option key={c.id} value={c.id}>{c.full_name} ({c.kb_id})</option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Status</label>
              <select
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
                value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value as BillStatus })}
              >
                <option value="unpaid">Unpaid</option>
                <option value="paid">Paid</option>
                <option value="overdue">Overdue</option>
              </select>
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Period Start</label>
              <input
                type="date"
                required
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
                onChange={(e) => setFormData({ ...formData, billing_period_start: e.target.value })}
              />
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Period End</label>
              <input
                type="date"
                required
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
                onChange={(e) => setFormData({ ...formData, billing_period_end: e.target.value })}
              />
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Base Amount (Rs.) *</label>
              <input
                type="number"
                required
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
                onChange={(e) => {
                  const base = Number(e.target.value);
                  setFormData({
                    ...formData,
                    base_amount: base,
                    total_amount: base + (formData.tax_amount || 0) + (formData.previous_balance || 0)
                  });
                }}
              />
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Due Date *</label>
              <input
                type="date"
                required
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
                onChange={(e) => setFormData({ ...formData, due_date: e.target.value })}
              />
            </div>
          </div>
          <div className="flex justify-end gap-md mt-md">
            <Button type="button" variant="ghost" onClick={() => setIsFormModalOpen(false)}>Cancel</Button>
            <Button type="submit" isLoading={isSubmitting}>Generate Invoice</Button>
          </div>
        </form>
      </Modal>

      {/* Details Modal */}
      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Invoice Details"
        size="md"
      >
        {selectedBill && (
          <div className="flex flex-col gap-lg">
            <div className="flex justify-between items-start border-b border-surface-container-high pb-md">
              <div>
                <h3 className="font-title-lg text-primary">{selectedBill.invoice_number}</h3>
                <p className="text-body-sm text-on-surface-variant">Issued: {new Date(selectedBill.created_at).toLocaleDateString()}</p>
              </div>
              <Badge variant={getStatusVariant(selectedBill.status)}>{selectedBill.status.toUpperCase()}</Badge>
            </div>

            <div className="grid grid-cols-2 gap-md">
              <div>
                <p className="text-label-md text-on-surface-variant uppercase mb-xs">Billed To</p>
                <p className="font-bold">{selectedBill.customer.full_name}</p>
                <p className="text-body-sm">{selectedBill.customer.address}</p>
                <p className="text-body-sm">{selectedBill.customer.phone}</p>
              </div>
              <div className="text-right">
                <p className="text-label-md text-on-surface-variant uppercase mb-xs">Due Date</p>
                <p className={`font-bold ${selectedBill.status === 'overdue' ? 'text-error' : ''}`}>
                  {new Date(selectedBill.due_date).toLocaleDateString(undefined, { dateStyle: 'long' })}
                </p>
              </div>
            </div>

            <div className="bg-surface-container-low p-md rounded-xl space-y-sm">
              <div className="flex justify-between">
                <span>Base Amount</span>
                <span>Rs. {selectedBill.base_amount.toLocaleString()}</span>
              </div>
              <div className="flex justify-between">
                <span>Tax</span>
                <span>Rs. {selectedBill.tax_amount.toLocaleString()}</span>
              </div>
              <div className="flex justify-between border-t border-surface-container-high pt-sm font-bold text-title-md">
                <span>Total Amount</span>
                <span>Rs. {selectedBill.total_amount.toLocaleString()}</span>
              </div>
            </div>

            {selectedBill.status === 'paid' && (
              <div className="bg-success/5 p-md rounded-xl border border-success/20">
                <p className="text-label-md text-success font-bold uppercase mb-xs">Payment Information</p>
                <div className="flex justify-between text-body-sm">
                  <span>Method: {selectedBill.payment_method}</span>
                  <span>Paid On: {new Date(selectedBill.paid_at!).toLocaleDateString()}</span>
                </div>
              </div>
            )}

            <div className="flex gap-md pt-md">
              <Button variant="ghost" className="flex-1" icon="print">Print</Button>
              {selectedBill.status !== 'paid' && (
                <Button variant="primary" className="flex-1" onClick={() => { setIsDetailsModalOpen(false); setIsPaymentModalOpen(true); }}>
                  Mark as Paid
                </Button>
              )}
            </div>
          </div>
        )}
      </Modal>

      {/* Payment Confirmation Modal */}
      <Modal
        isOpen={isPaymentModalOpen}
        onClose={() => setIsPaymentModalOpen(false)}
        title="Record Payment"
        size="sm"
      >
        <div className="flex flex-col gap-lg">
          <p className="text-body-md text-on-surface-variant">
            Are you sure you want to mark invoice <span className="font-bold text-on-surface">{selectedBill?.invoice_number}</span> as paid?
          </p>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Payment Method</label>
            <select
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              value={paymentMethod}
              onChange={(e) => setPaymentMethod(e.target.value)}
            >
              <option value="Cash">Cash</option>
              <option value="Bank Transfer">Bank Transfer</option>
              <option value="EasyPaisa">EasyPaisa</option>
              <option value="JazzCash">JazzCash</option>
              <option value="Credit Card">Credit Card</option>
            </select>
          </div>
          <div className="flex justify-end gap-md">
            <Button variant="ghost" onClick={() => setIsPaymentModalOpen(false)}>Cancel</Button>
            <Button variant="primary" icon="check" isLoading={isSubmitting} onClick={handleMarkAsPaid}>
              Confirm Payment
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

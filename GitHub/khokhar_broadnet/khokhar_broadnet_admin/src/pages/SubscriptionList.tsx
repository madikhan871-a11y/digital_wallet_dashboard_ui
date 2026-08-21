import React, { useEffect, useState } from 'react';
import { subscriptionService } from '../services/subscriptionService';
import { customerService } from '../services/customerService';
import { packageService } from '../services/packageService';
import { SubscriptionWithDetails, SubscriptionStatus, UpdateSubscriptionInput } from '../types/subscription';
import { Customer } from '../types/customer';
import { Package } from '../types/package';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';

export const SubscriptionList: React.FC = () => {
  const [subscriptions, setSubscriptions] = useState<SubscriptionWithDetails[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<SubscriptionStatus | 'all'>('all');
  const [packageFilter, setPackageFilter] = useState<string>('all');

  const [packages, setPackages] = useState<Package[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);

  // Modal states
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [selectedSub, setSelectedSub] = useState<SubscriptionWithDetails | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form states for edit
  const [editForm, setEditForm] = useState<UpdateSubscriptionInput>({});

  const fetchInitialData = async () => {
    try {
      const [pkgs, custs] = await Promise.all([
        packageService.getPackages(),
        customerService.getCustomers({ pageSize: 1000 })
      ]);
      setPackages(pkgs);
      setCustomers(custs.data);
    } catch (err) {
      console.error('Failed to fetch initial data', err);
    }
  };

  const fetchSubscriptions = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await subscriptionService.getSubscriptions({
        search,
        status: statusFilter,
        packageId: packageFilter
      });
      setSubscriptions(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch subscriptions');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchInitialData();
  }, []);

  useEffect(() => {
    fetchSubscriptions();
  }, [search, statusFilter, packageFilter]);

  const handleUpdateStatus = async (id: string, newStatus: SubscriptionStatus) => {
    if (!window.confirm(`Are you sure you want to change status to ${newStatus}?`)) return;
    try {
      await subscriptionService.updateSubscriptionStatus(id, newStatus);
      fetchSubscriptions();
      if (selectedSub?.id === id) {
        setIsDetailsModalOpen(false);
      }
    } catch (err: any) {
      alert(err.message || 'Failed to update status');
    }
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedSub) return;
    try {
      setIsSubmitting(true);
      await subscriptionService.updateSubscription(selectedSub.id, editForm);
      setIsEditModalOpen(false);
      fetchSubscriptions();
    } catch (err: any) {
      alert(err.message || 'Failed to update subscription');
    } finally {
      setIsSubmitting(false);
    }
  };

  const openEditModal = (sub: SubscriptionWithDetails) => {
    setSelectedSub(sub);
    setEditForm({
      package_id: sub.package_id,
      status: sub.status,
      start_date: sub.start_date.split('T')[0],
      expiry_date: sub.expiry_date.split('T')[0],
      price_override: sub.price_override,
      notes: sub.notes
    });
    setIsEditModalOpen(true);
  };

  const openDetailsModal = (sub: SubscriptionWithDetails) => {
    setSelectedSub(sub);
    setIsDetailsModalOpen(true);
  };

  const getStatusVariant = (status: SubscriptionStatus): 'success' | 'pending' | 'error' | 'info' => {
    switch (status) {
      case 'active': return 'success';
      case 'pending': return 'pending';
      case 'expired': return 'error';
      case 'suspended': return 'error';
      default: return 'info';
    }
  };

  const columns = [
    {
      header: 'Customer',
      accessor: (item: SubscriptionWithDetails) => (
        <div className="flex flex-col">
          <div className="font-title-md text-on-surface">{item.customer.full_name}</div>
          <div className="text-[11px] text-on-surface-variant font-mono uppercase tracking-tighter">{item.customer.kb_id}</div>
        </div>
      )
    },
    {
      header: 'Package',
      accessor: (item: SubscriptionWithDetails) => (
        <div className="flex flex-col">
          <div className="font-label-lg">{item.package.name}</div>
          <div className="text-[11px] text-on-surface-variant uppercase tracking-widest">{item.package.speed_mbps} Mbps</div>
        </div>
      )
    },
    {
      header: 'Billing',
      accessor: (item: SubscriptionWithDetails) => (
        <div className="flex flex-col">
          <span className="font-label-lg">Rs. {(item.price_override || item.package.price_per_month).toLocaleString()}</span>
          {item.price_override && <span className="text-[10px] text-primary italic">Overridden</span>}
        </div>
      )
    },
    {
      header: 'Duration',
      accessor: (item: SubscriptionWithDetails) => (
        <div className="flex flex-col text-[12px]">
          <div className="flex items-center gap-xs text-on-surface-variant">
            <span className="material-symbols-outlined text-[14px]">calendar_today</span>
            {new Date(item.start_date).toLocaleDateString()}
          </div>
          <div className="flex items-center gap-xs text-on-surface">
            <span className="material-symbols-outlined text-[14px]">event_busy</span>
            {new Date(item.expiry_date).toLocaleDateString()}
          </div>
        </div>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: SubscriptionWithDetails) => (
        <Badge variant={getStatusVariant(item.status)}>
          {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
        </Badge>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: SubscriptionWithDetails) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => openDetailsModal(item)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="View Details"
          >
            <span className="material-symbols-outlined text-[20px]">visibility</span>
          </button>
          <button
            onClick={() => openEditModal(item)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="Edit Subscription"
          >
            <span className="material-symbols-outlined text-[20px]">edit</span>
          </button>
        </div>
      )
    }
  ];

  const stats = {
    total: subscriptions.length,
    active: subscriptions.filter(s => s.status === 'active').length,
    pending: subscriptions.filter(s => s.status === 'pending').length,
    expired: subscriptions.filter(s => s.status === 'expired').length,
    suspended: subscriptions.filter(s => s.status === 'suspended').length,
  };

  return (
    <div className="flex flex-col w-full h-full gap-lg">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-md mb-md">
        <div className="flex flex-col">
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Subscription Management</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Monitor and manage active customer plans and billing cycles.</p>
        </div>
        <div className="flex items-center gap-md">
          <Button variant="ghost" icon="download">Export Report</Button>
          <Button icon="add">New Subscription</Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-md mb-lg">
        <StatCard label="Total" value={stats.total} icon="event_repeat" variant="primary" />
        <StatCard label="Active" value={stats.active} icon="check_circle" variant="secondary" />
        <StatCard label="Pending" value={stats.pending} icon="schedule" variant="tertiary" />
        <StatCard label="Expired" value={stats.expired} icon="event_busy" variant="error" />
        <StatCard label="Suspended" value={stats.suspended} icon="block" variant="error" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search by Customer, KB-ID, or Phone..."
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
            <option value="active">Active</option>
            <option value="pending">Pending</option>
            <option value="expired">Expired</option>
            <option value="suspended">Suspended</option>
          </select>

          <select
            className="bg-surface-container hover:bg-surface-container-high text-on-surface font-label-lg text-label-lg py-sm px-md rounded-lg outline-none cursor-pointer transition-colors"
            value={packageFilter}
            onChange={(e) => setPackageFilter(e.target.value)}
          >
            <option value="all">All Packages</option>
            {packages.map(pkg => (
              <option key={pkg.id} value={pkg.id}>{pkg.name}</option>
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
            <Button onClick={fetchSubscriptions} className="mt-md">Retry</Button>
          </div>
        ) : subscriptions.length === 0 ? (
          <EmptyState
            icon="event_busy"
            title="No Subscriptions Found"
            description="Try adjusting your filters to find specific records."
            actionLabel="Clear All Filters"
            onAction={() => { setSearch(''); setStatusFilter('all'); setPackageFilter('all'); }}
          />
        ) : (
          <Table
            columns={columns}
            data={subscriptions}
            onRowClick={(item) => openDetailsModal(item)}
          />
        )}
      </div>

      {/* Edit Modal */}
      <Modal
        isOpen={isEditModalOpen}
        onClose={() => setIsEditModalOpen(false)}
        title="Edit Subscription"
        size="lg"
      >
        <form onSubmit={handleEditSubmit} className="flex flex-col gap-lg">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-md">
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Package</label>
              <select
                value={editForm.package_id}
                onChange={(e) => setEditForm({ ...editForm, package_id: e.target.value })}
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              >
                {packages.map(pkg => (
                  <option key={pkg.id} value={pkg.id}>{pkg.name} ({pkg.speed_mbps} Mbps)</option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Status</label>
              <select
                value={editForm.status}
                onChange={(e) => setEditForm({ ...editForm, status: e.target.value as SubscriptionStatus })}
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              >
                <option value="active">Active</option>
                <option value="pending">Pending</option>
                <option value="expired">Expired</option>
                <option value="suspended">Suspended</option>
              </select>
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Start Date</label>
              <input
                type="date"
                value={editForm.start_date}
                onChange={(e) => setEditForm({ ...editForm, start_date: e.target.value })}
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              />
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Expiry Date</label>
              <input
                type="date"
                value={editForm.expiry_date}
                onChange={(e) => setEditForm({ ...editForm, expiry_date: e.target.value })}
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              />
            </div>
            <div className="flex flex-col gap-xs">
              <label className="text-label-md text-on-surface-variant">Price Override (Optional)</label>
              <input
                type="number"
                value={editForm.price_override || ''}
                onChange={(e) => setEditForm({ ...editForm, price_override: Number(e.target.value) || undefined })}
                className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
                placeholder="Leave blank for package default"
              />
            </div>
          </div>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Internal Notes</label>
            <textarea
              value={editForm.notes || ''}
              onChange={(e) => setEditForm({ ...editForm, notes: e.target.value })}
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none min-h-[100px]"
              placeholder="Add any specific details about this subscription..."
            />
          </div>
          <div className="flex justify-end gap-md mt-md">
            <Button type="button" variant="ghost" onClick={() => setIsEditModalOpen(false)}>Cancel</Button>
            <Button type="submit" isLoading={isSubmitting}>Save Changes</Button>
          </div>
        </form>
      </Modal>

      {/* Details Modal */}
      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Subscription Details"
        size="md"
        footer={
          <div className="flex gap-md w-full">
            <Button
              variant="secondary"
              className="flex-1"
              onClick={() => { setIsDetailsModalOpen(false); openEditModal(selectedSub!); }}
            >
              Edit Details
            </Button>
            <Button
              variant="ghost"
              className="flex-1"
              onClick={() => setIsDetailsModalOpen(false)}
            >
              Close
            </Button>
          </div>
        }
      >
        {selectedSub && (
          <div className="flex flex-col gap-lg">
            <div className="flex items-center gap-md p-md bg-secondary-container/10 rounded-2xl">
              <div className="w-12 h-12 rounded-full bg-secondary-container text-on-secondary-container flex items-center justify-center text-headline-sm">
                {selectedSub.customer.full_name.charAt(0)}
              </div>
              <div>
                <h3 className="font-title-lg text-on-surface">{selectedSub.customer.full_name}</h3>
                <p className="text-body-md text-on-surface-variant">{selectedSub.customer.kb_id} • {selectedSub.customer.phone}</p>
              </div>
              <div className="ml-auto">
                <Badge variant={getStatusVariant(selectedSub.status)}>{selectedSub.status.toUpperCase()}</Badge>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-md">
              <div className="bg-surface-container-low p-md rounded-xl">
                <div className="text-label-md text-on-surface-variant mb-xs">Package</div>
                <div className="text-title-md font-bold text-on-surface">{selectedSub.package.name}</div>
                <div className="text-body-sm text-on-surface-variant">{selectedSub.package.speed_mbps} Mbps</div>
              </div>
              <div className="bg-surface-container-low p-md rounded-xl">
                <div className="text-label-md text-on-surface-variant mb-xs">Monthly Billing</div>
                <div className="text-title-md font-bold text-on-surface">Rs. {(selectedSub.price_override || selectedSub.package.price_per_month).toLocaleString()}</div>
                {selectedSub.price_override && <div className="text-[10px] text-primary">Custom Pricing Active</div>}
              </div>
            </div>

            <div className="bg-surface-container-low p-md rounded-xl">
              <div className="text-label-lg font-bold mb-md">Timeline</div>
              <div className="space-y-sm">
                <div className="flex justify-between items-center">
                  <span className="text-body-md text-on-surface-variant">Start Date</span>
                  <span className="text-body-md font-medium">{new Date(selectedSub.start_date).toLocaleDateString(undefined, { dateStyle: 'long' })}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-body-md text-on-surface-variant">Expiry Date</span>
                  <span className="text-body-md font-medium text-error">{new Date(selectedSub.expiry_date).toLocaleDateString(undefined, { dateStyle: 'long' })}</span>
                </div>
                <div className="w-full bg-surface-container-high h-2 rounded-full mt-md overflow-hidden">
                  <div
                    className="bg-primary h-full rounded-full"
                    style={{
                      width: `${Math.min(100, Math.max(0,
                        (Date.now() - new Date(selectedSub.start_date).getTime()) /
                        (new Date(selectedSub.expiry_date).getTime() - new Date(selectedSub.start_date).getTime()) * 100
                      ))}%`
                    }}
                  />
                </div>
              </div>
            </div>

            {selectedSub.notes && (
              <div className="bg-surface-container-low p-md rounded-xl">
                <div className="text-label-md text-on-surface-variant mb-xs">Notes</div>
                <p className="text-body-md italic text-on-surface-variant">{selectedSub.notes}</p>
              </div>
            )}

            <div className="flex flex-wrap gap-sm pt-md border-t border-surface-container-high">
              {selectedSub.status !== 'active' && (
                <Button variant="secondary" onClick={() => handleUpdateStatus(selectedSub.id, 'active')}>Activate</Button>
              )}
              {selectedSub.status === 'active' && (
                <Button variant="error" onClick={() => handleUpdateStatus(selectedSub.id, 'suspended')}>Suspend</Button>
              )}
              {selectedSub.status !== 'expired' && (
                <Button variant="ghost" onClick={() => handleUpdateStatus(selectedSub.id, 'expired')}>Mark Expired</Button>
              )}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

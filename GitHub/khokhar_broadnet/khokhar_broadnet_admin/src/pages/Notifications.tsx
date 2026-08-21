import React, { useEffect, useState } from 'react';
import { notificationService } from '../services/notificationService';
import { customerService } from '../services/customerService';
import { NotificationWithDetails, CreateNotificationInput } from '../types/notification';
import { Customer } from '../types/customer';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';

export const Notifications: React.FC = () => {
  const [notifications, setNotifications] = useState<NotificationWithDetails[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [isReadFilter, setIsReadFilter] = useState<boolean | 'all'>('all');

  // Modal states
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [selectedNotification, setSelectedNotification] = useState<NotificationWithDetails | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form states
  const [formData, setFormData] = useState<CreateNotificationInput>({
    customer_id: '',
    title: '',
    body: '',
  });

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [notifs, custs] = await Promise.all([
        notificationService.getNotifications({ isRead: isReadFilter }),
        customerService.getCustomers({ pageSize: 1000 })
      ]);
      setNotifications(notifs.data);
      setCustomers(custs.data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [isReadFilter]);

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsSubmitting(true);
      await notificationService.createNotification(formData);
      setIsFormModalOpen(false);
      setFormData({ customer_id: '', title: '', body: '' });
      fetchData();
    } catch (err: any) {
      alert(err.message || 'Failed to send notification');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this notification record?')) return;
    try {
      await notificationService.deleteNotification(id);
      fetchData();
    } catch (err: any) {
      alert(err.message || 'Failed to delete notification');
    }
  };

  const openDetailsModal = (item: NotificationWithDetails) => {
    setSelectedNotification(item);
    setIsDetailsModalOpen(true);
  };

  const filteredNotifications = notifications.filter(n =>
    n.title.toLowerCase().includes(search.toLowerCase()) ||
    n.body.toLowerCase().includes(search.toLowerCase()) ||
    n.customer.full_name.toLowerCase().includes(search.toLowerCase()) ||
    n.customer.kb_id.toLowerCase().includes(search.toLowerCase())
  );

  const columns = [
    {
      header: 'Customer',
      accessor: (item: NotificationWithDetails) => (
        <div className="flex flex-col">
          <span className="font-title-md text-on-surface font-bold">{item.customer.full_name}</span>
          <span className="text-[11px] text-on-surface-variant font-mono">{item.customer.kb_id}</span>
        </div>
      )
    },
    {
      header: 'Title',
      accessor: (item: NotificationWithDetails) => (
        <span className="font-medium">{item.title}</span>
      )
    },
    {
      header: 'Body Preview',
      accessor: (item: NotificationWithDetails) => (
        <div className="max-w-[300px] truncate text-on-surface-variant">
          {item.body}
        </div>
      )
    },
    {
      header: 'Sent Date',
      accessor: (item: NotificationWithDetails) => (
        <span className="text-[12px] text-on-surface-variant">
          {new Date(item.created_at).toLocaleDateString()}
        </span>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: NotificationWithDetails) => (
        <Badge variant={item.is_read ? 'success' : 'pending'}>
          {item.is_read ? 'READ' : 'UNREAD'}
        </Badge>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: NotificationWithDetails) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => openDetailsModal(item)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="View Details"
          >
            <span className="material-symbols-outlined text-[20px]">visibility</span>
          </button>
          <button
            onClick={(e) => { e.stopPropagation(); handleDelete(item.id); }}
            className="w-8 h-8 rounded-full hover:bg-error/10 flex items-center justify-center text-on-surface-variant hover:text-error transition-colors"
            title="Delete"
          >
            <span className="material-symbols-outlined text-[20px]">delete</span>
          </button>
        </div>
      )
    }
  ];

  return (
    <div className="flex flex-col w-full h-full gap-lg">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-md mb-md">
        <div className="flex flex-col">
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Direct Notifications</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Send private alerts and personalized messages to specific customers.</p>
        </div>
        <Button icon="send" onClick={() => setIsFormModalOpen(true)}>Send Notification</Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-md mb-lg">
        <StatCard label="Total Sent" value={notifications.length} icon="mail" variant="primary" />
        <StatCard label="Unread by Customers" value={notifications.filter(n => !n.is_read).length} icon="mark_email_unread" variant="tertiary" />
        <StatCard label="Read Rate" value={notifications.length > 0 ? Math.round((notifications.filter(n => n.is_read).length / notifications.length) * 100) + '%' : '0%'} icon="done_all" variant="secondary" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search Customer, Title or Body..."
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <select
          className="bg-surface-container hover:bg-surface-container-high text-on-surface font-label-lg text-label-lg py-sm px-md rounded-lg outline-none cursor-pointer transition-colors"
          value={isReadFilter.toString()}
          onChange={(e) => setIsReadFilter(e.target.value === 'all' ? 'all' : e.target.value === 'true')}
        >
          <option value="all">All Notifications</option>
          <option value="false">Unread Only</option>
          <option value="true">Read Only</option>
        </select>
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex-1 flex flex-col min-h-[400px]">
        {loading ? (
          <LoadingState />
        ) : error ? (
          <div className="p-xl text-center text-error">
            <span className="material-symbols-outlined text-[48px] mb-md">error</span>
            <p>{error}</p>
            <Button onClick={fetchData} className="mt-md">Retry</Button>
          </div>
        ) : filteredNotifications.length === 0 ? (
          <EmptyState
            icon="notifications_off"
            title="No Notifications Found"
            description="Start by sending a direct message to a customer."
            actionLabel="Send Notification"
            onAction={() => setIsFormModalOpen(true)}
          />
        ) : (
          <Table
            columns={columns}
            data={filteredNotifications}
            onRowClick={(item) => openDetailsModal(item)}
          />
        )}
      </div>

      {/* Send Notification Modal */}
      <Modal
        isOpen={isFormModalOpen}
        onClose={() => setIsFormModalOpen(false)}
        title="Send Direct Notification"
        size="md"
      >
        <form onSubmit={handleFormSubmit} className="flex flex-col gap-lg">
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Select Customer *</label>
            <select
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              value={formData.customer_id}
              onChange={(e) => setFormData({ ...formData, customer_id: e.target.value })}
            >
              <option value="">Choose a customer...</option>
              {customers.map(c => (
                <option key={c.id} value={c.id}>{c.full_name} ({c.kb_id})</option>
              ))}
            </select>
          </div>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Title *</label>
            <input
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              placeholder="e.g. Payment Received"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            />
          </div>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Message Body *</label>
            <textarea
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none min-h-[150px]"
              placeholder="Enter your message..."
              value={formData.body}
              onChange={(e) => setFormData({ ...formData, body: e.target.value })}
            />
          </div>
          <div className="flex justify-end gap-md">
            <Button variant="ghost" onClick={() => setIsFormModalOpen(false)}>Cancel</Button>
            <Button type="submit" isLoading={isSubmitting} icon="send">Send Message</Button>
          </div>
        </form>
      </Modal>

      {/* Details Modal */}
      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Notification Details"
        size="md"
      >
        {selectedNotification && (
          <div className="flex flex-col gap-lg">
            <div className="bg-surface-container-low p-md rounded-xl">
              <div className="flex justify-between items-start mb-md">
                <div>
                  <h3 className="text-headline-sm font-bold text-on-surface">{selectedNotification.title}</h3>
                  <p className="text-label-md text-on-surface-variant mt-xs">
                    Sent to {selectedNotification.customer.full_name} ({selectedNotification.customer.kb_id})
                  </p>
                </div>
                <Badge variant={selectedNotification.is_read ? 'success' : 'pending'}>
                  {selectedNotification.is_read ? 'READ' : 'UNREAD'}
                </Badge>
              </div>
              <div className="text-body-md whitespace-pre-wrap text-on-surface border-t border-surface-container-high pt-md">
                {selectedNotification.body}
              </div>
            </div>
            <div className="flex justify-between items-center text-[12px] text-on-surface-variant">
              <span>Sent on: {new Date(selectedNotification.created_at).toLocaleString()}</span>
            </div>
            <div className="flex justify-end pt-md border-t border-surface-container-high">
              <Button variant="ghost" onClick={() => setIsDetailsModalOpen(false)}>Close</Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

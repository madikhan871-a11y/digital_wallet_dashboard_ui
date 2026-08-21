import React, { useEffect, useState } from 'react';
import { complaintService } from '../services/complaintService';
import { ComplaintWithDetails, ComplaintStatus, ComplaintCategory } from '../types/complaint';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';

export const SupportTickets: React.FC = () => {
  const [complaints, setComplaints] = useState<ComplaintWithDetails[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<ComplaintStatus | 'all'>('all');
  const [categoryFilter, setCategoryFilter] = useState<ComplaintCategory | 'all'>('all');

  // Modal states
  const [selectedTicket, setSelectedTicket] = useState<ComplaintWithDetails | null>(null);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [isResponseModalOpen, setIsResponseModalOpen] = useState(false);
  const [adminResponse, setAdminResponse] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchComplaints = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await complaintService.getComplaints({
        search,
        status: statusFilter,
        category: categoryFilter,
      });
      setComplaints(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch tickets');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchComplaints();
  }, [search, statusFilter, categoryFilter]);

  const handleUpdateStatus = async (id: string, newStatus: ComplaintStatus) => {
    const confirmMsg = newStatus === 'resolved'
      ? 'Are you sure you want to mark this ticket as RESOLVED?'
      : newStatus === 'closed'
      ? 'Are you sure you want to CLOSE this ticket?'
      : `Change status to ${newStatus.replace('_', ' ')}?`;

    if (!window.confirm(confirmMsg)) return;

    try {
      setIsSubmitting(true);
      await complaintService.updateComplaint(id, { status: newStatus });
      fetchComplaints();
      if (selectedTicket?.id === id) {
        setIsDetailsModalOpen(false);
      }
    } catch (err: any) {
      alert(err.message || 'Failed to update status');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleSaveResponse = async () => {
    if (!selectedTicket) return;
    try {
      setIsSubmitting(true);
      await complaintService.updateComplaint(selectedTicket.id, { admin_response: adminResponse });
      setIsResponseModalOpen(false);
      fetchComplaints();
    } catch (err: any) {
      alert(err.message || 'Failed to save response');
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusVariant = (status: ComplaintStatus): 'success' | 'pending' | 'error' | 'info' => {
    switch (status) {
      case 'resolved': return 'success';
      case 'open': return 'error';
      case 'in_progress': return 'pending';
      case 'closed': return 'info';
      default: return 'info';
    }
  };

  const stats = {
    total: complaints.length,
    open: complaints.filter(c => c.status === 'open').length,
    inProgress: complaints.filter(c => c.status === 'in_progress').length,
    resolved: complaints.filter(c => c.status === 'resolved').length,
    closed: complaints.filter(c => c.status === 'closed').length,
  };

  const columns = [
    {
      header: 'Ticket #',
      accessor: (item: ComplaintWithDetails) => (
        <span className="font-mono text-primary font-bold">{item.ticket_number}</span>
      )
    },
    {
      header: 'Customer',
      accessor: (item: ComplaintWithDetails) => (
        <div className="flex flex-col">
          <span className="font-title-md text-on-surface">{item.customer.full_name}</span>
          <span className="text-[11px] text-on-surface-variant font-mono">{item.customer.kb_id}</span>
        </div>
      )
    },
    {
      header: 'Category',
      accessor: (item: ComplaintWithDetails) => (
        <Badge variant="info">{item.category}</Badge>
      )
    },
    {
      header: 'Subject',
      accessor: (item: ComplaintWithDetails) => (
        <div className="max-w-[250px] truncate font-medium" title={item.subject}>
          {item.subject}
        </div>
      )
    },
    {
      header: 'Submitted',
      accessor: (item: ComplaintWithDetails) => (
        <div className="text-[12px] text-on-surface-variant">
          {new Date(item.created_at).toLocaleDateString()}
          <div className="text-[10px] opacity-70">{new Date(item.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</div>
        </div>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: ComplaintWithDetails) => (
        <Badge variant={getStatusVariant(item.status)}>
          {item.status.replace('_', ' ').toUpperCase()}
        </Badge>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: ComplaintWithDetails) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={(e) => { e.stopPropagation(); setSelectedTicket(item); setIsDetailsModalOpen(true); }}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="View Details"
          >
            <span className="material-symbols-outlined text-[20px]">visibility</span>
          </button>
          {item.status === 'open' && (
            <button
              onClick={(e) => { e.stopPropagation(); handleUpdateStatus(item.id, 'in_progress'); }}
              className="w-8 h-8 rounded-full hover:bg-pending/10 flex items-center justify-center text-on-surface-variant hover:text-pending transition-colors"
              title="Start Working"
            >
              <span className="material-symbols-outlined text-[20px]">play_circle</span>
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
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Support Tickets</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Manage customer complaints, technical issues, and billing queries.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-md mb-lg">
        <StatCard label="Total" value={stats.total} icon="confirmation_number" variant="primary" />
        <StatCard label="Open" value={stats.open} icon="fiber_new" variant="error" />
        <StatCard label="In Progress" value={stats.inProgress} icon="engineering" variant="tertiary" />
        <StatCard label="Resolved" value={stats.resolved} icon="task_alt" variant="secondary" />
        <StatCard label="Closed" value={stats.closed} icon="lock" variant="secondary" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search Ticket #, Customer, or Subject..."
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
            <option value="open">Open</option>
            <option value="in_progress">In Progress</option>
            <option value="resolved">Resolved</option>
            <option value="closed">Closed</option>
          </select>

          <select
            className="bg-surface-container hover:bg-surface-container-high text-on-surface font-label-lg text-label-lg py-sm px-md rounded-lg outline-none cursor-pointer transition-colors"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value as any)}
          >
            <option value="all">All Categories</option>
            <option value="Technical">Technical</option>
            <option value="Billing">Billing</option>
            <option value="Service">Service</option>
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
            <Button onClick={fetchComplaints} className="mt-md">Retry</Button>
          </div>
        ) : complaints.length === 0 ? (
          <EmptyState
            icon="support_agent"
            title="No Tickets Found"
            description="No support tickets match your current filters."
            actionLabel="Clear Filters"
            onAction={() => { setSearch(''); setStatusFilter('all'); setCategoryFilter('all'); }}
          />
        ) : (
          <Table
            columns={columns}
            data={complaints}
            onRowClick={(item) => { setSelectedTicket(item); setIsDetailsModalOpen(true); }}
          />
        )}
      </div>

      {/* Details Modal */}
      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Support Ticket Details"
        size="lg"
      >
        {selectedTicket && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-lg">
            <div className="flex flex-col gap-lg">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="font-title-lg text-primary">{selectedTicket.ticket_number}</h3>
                  <p className="text-body-sm text-on-surface-variant">Submitted: {new Date(selectedTicket.created_at).toLocaleString()}</p>
                </div>
                <Badge variant={getStatusVariant(selectedTicket.status)}>{selectedTicket.status.replace('_', ' ').toUpperCase()}</Badge>
              </div>

              <div className="bg-surface-container-low p-md rounded-xl space-y-md">
                <div>
                  <p className="text-label-md text-on-surface-variant uppercase">Customer</p>
                  <p className="font-bold">{selectedTicket.customer.full_name}</p>
                  <p className="text-body-sm">{selectedTicket.customer.kb_id} • {selectedTicket.customer.phone}</p>
                  <p className="text-body-sm">{selectedTicket.customer.address}</p>
                </div>
                <div>
                  <p className="text-label-md text-on-surface-variant uppercase">Category</p>
                  <p className="font-bold">{selectedTicket.category}</p>
                </div>
              </div>

              <div className="space-y-sm">
                <p className="text-label-md text-on-surface-variant uppercase">Subject</p>
                <p className="font-bold text-title-md">{selectedTicket.subject}</p>
                <p className="text-label-md text-on-surface-variant uppercase mt-md">Description</p>
                <div className="bg-surface-container-low p-md rounded-xl text-body-md whitespace-pre-wrap min-h-[100px]">
                  {selectedTicket.description}
                </div>
              </div>

              {selectedTicket.admin_response && (
                <div className="bg-primary/5 p-md rounded-xl border border-primary/10">
                  <p className="text-label-md text-primary font-bold uppercase mb-xs">Admin Response</p>
                  <p className="text-body-md whitespace-pre-wrap italic">{selectedTicket.admin_response}</p>
                </div>
              )}
            </div>

            <div className="flex flex-col gap-lg">
              <div className="flex flex-col gap-sm">
                <h4 className="font-label-lg text-on-surface-variant uppercase">Attachment</h4>
                <div className="bg-surface-container-high rounded-xl overflow-hidden min-h-[250px] flex items-center justify-center border-2 border-dashed border-outline-variant">
                  {selectedTicket.attachment_url ? (
                    <img
                      src={selectedTicket.attachment_url}
                      alt="Ticket Attachment"
                      className="w-full h-full object-contain cursor-zoom-in"
                      onClick={() => window.open(selectedTicket.attachment_url, '_blank')}
                    />
                  ) : (
                    <div className="flex flex-col items-center gap-md text-on-surface-variant opacity-50">
                      <span className="material-symbols-outlined text-[64px]">no_photography</span>
                      <p>No attachment provided</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="mt-auto space-y-md">
                <div className="flex flex-wrap gap-sm">
                  {selectedTicket.status === 'open' && (
                    <Button className="flex-1" variant="pending" onClick={() => handleUpdateStatus(selectedTicket.id, 'in_progress')}>Start Progress</Button>
                  )}
                  {selectedTicket.status === 'in_progress' && (
                    <Button className="flex-1" variant="secondary" onClick={() => handleUpdateStatus(selectedTicket.id, 'resolved')}>Mark Resolved</Button>
                  )}
                  {selectedTicket.status === 'resolved' && (
                    <Button className="flex-1" variant="ghost" onClick={() => handleUpdateStatus(selectedTicket.id, 'closed')}>Close Ticket</Button>
                  )}
                </div>
                <Button
                  className="w-full"
                  variant="primary"
                  icon="edit_note"
                  onClick={() => { setAdminResponse(selectedTicket.admin_response || ''); setIsResponseModalOpen(true); }}
                >
                  {selectedTicket.admin_response ? 'Edit Response' : 'Add Response'}
                </Button>
              </div>
            </div>
          </div>
        )}
      </Modal>

      {/* Response Modal */}
      <Modal
        isOpen={isResponseModalOpen}
        onClose={() => setIsResponseModalOpen(false)}
        title="Admin Response"
        size="sm"
      >
        <div className="flex flex-col gap-lg">
          <p className="text-body-md text-on-surface-variant">
            Enter a response to be shared with the customer regarding this ticket.
          </p>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Response Message *</label>
            <textarea
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none min-h-[150px]"
              placeholder="Explain the action taken or solution provided..."
              value={adminResponse}
              onChange={(e) => setAdminResponse(e.target.value)}
            />
          </div>
          <div className="flex justify-end gap-md">
            <Button variant="ghost" onClick={() => setIsResponseModalOpen(false)}>Cancel</Button>
            <Button
              variant="primary"
              icon="save"
              isLoading={isSubmitting}
              disabled={!adminResponse.trim()}
              onClick={handleSaveResponse}
            >
              Save Response
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

import React, { useEffect, useState } from 'react';
import { announcementService } from '../services/announcementService';
import { Announcement, CreateAnnouncementInput } from '../types/announcement';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';

export const Announcements: React.FC = () => {
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');

  // Modal states
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [selectedAnnouncement, setSelectedAnnouncement] = useState<Announcement | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form states
  const [formData, setFormData] = useState<CreateAnnouncementInput>({
    title: '',
    content: '',
  });

  const fetchAnnouncements = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await announcementService.getAnnouncements();
      setAnnouncements(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch announcements');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAnnouncements();
  }, []);

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsSubmitting(true);
      if (selectedAnnouncement) {
        await announcementService.updateAnnouncement(selectedAnnouncement.id, formData);
      } else {
        await announcementService.createAnnouncement(formData);
      }
      setIsFormModalOpen(false);
      setSelectedAnnouncement(null);
      fetchAnnouncements();
    } catch (err: any) {
      alert(err.message || 'Failed to save announcement');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this announcement?')) return;
    try {
      await announcementService.deleteAnnouncement(id);
      fetchAnnouncements();
    } catch (err: any) {
      alert(err.message || 'Failed to delete announcement');
    }
  };

  const openCreateModal = () => {
    setSelectedAnnouncement(null);
    setFormData({ title: '', content: '' });
    setIsFormModalOpen(true);
  };

  const openEditModal = (e: React.MouseEvent, item: Announcement) => {
    e.stopPropagation();
    setSelectedAnnouncement(item);
    setFormData({ title: item.title, content: item.content });
    setIsFormModalOpen(true);
  };

  const openDetailsModal = (item: Announcement) => {
    setSelectedAnnouncement(item);
    setIsDetailsModalOpen(true);
  };

  const filteredAnnouncements = announcements.filter(a =>
    a.title.toLowerCase().includes(search.toLowerCase()) ||
    a.content.toLowerCase().includes(search.toLowerCase())
  );

  const columns = [
    {
      header: 'Title',
      accessor: (item: Announcement) => (
        <span className="font-title-md text-on-surface font-bold">{item.title}</span>
      )
    },
    {
      header: 'Content Preview',
      accessor: (item: Announcement) => (
        <div className="max-w-[400px] truncate text-on-surface-variant">
          {item.content}
        </div>
      )
    },
    {
      header: 'Date Created',
      accessor: (item: Announcement) => (
        <span className="text-[12px] text-on-surface-variant">
          {new Date(item.created_at).toLocaleDateString(undefined, { dateStyle: 'long' })}
        </span>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: Announcement) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => openDetailsModal(item)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="View Details"
          >
            <span className="material-symbols-outlined text-[20px]">visibility</span>
          </button>
          <button
            onClick={(e) => openEditModal(e, item)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="Edit"
          >
            <span className="material-symbols-outlined text-[20px]">edit</span>
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
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">BroadNet Announcements</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Broadcast news and updates to all customers instantly.</p>
        </div>
        <Button icon="campaign" onClick={openCreateModal}>Create Announcement</Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-md mb-lg">
        <StatCard label="Total Announcements" value={announcements.length} icon="list_alt" variant="primary" />
        <StatCard label="Recent Updates (Last 30d)" value={announcements.filter(a => new Date(a.created_at) > new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)).length} icon="update" variant="secondary" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search title or content..."
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex-1 flex flex-col min-h-[400px]">
        {loading ? (
          <LoadingState />
        ) : error ? (
          <div className="p-xl text-center text-error">
            <span className="material-symbols-outlined text-[48px] mb-md">error</span>
            <p>{error}</p>
            <Button onClick={fetchAnnouncements} className="mt-md">Retry</Button>
          </div>
        ) : filteredAnnouncements.length === 0 ? (
          <EmptyState
            icon="campaign"
            title="No Announcements Found"
            description="Start by broadcasting your first update to customers."
            actionLabel="Create Announcement"
            onAction={openCreateModal}
          />
        ) : (
          <Table
            columns={columns}
            data={filteredAnnouncements}
            onRowClick={(item) => openDetailsModal(item)}
          />
        )}
      </div>

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isFormModalOpen}
        onClose={() => setIsFormModalOpen(false)}
        title={selectedAnnouncement ? 'Edit Announcement' : 'New Announcement'}
        size="md"
      >
        <form onSubmit={handleFormSubmit} className="flex flex-col gap-lg">
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Title *</label>
            <input
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none"
              placeholder="e.g. Scheduled Maintenance"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            />
          </div>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Content *</label>
            <textarea
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none min-h-[200px]"
              placeholder="Write your announcement here..."
              value={formData.content}
              onChange={(e) => setFormData({ ...formData, content: e.target.value })}
            />
          </div>
          <div className="flex justify-end gap-md">
            <Button variant="ghost" onClick={() => setIsFormModalOpen(false)}>Cancel</Button>
            <Button type="submit" isLoading={isSubmitting}>
              {selectedAnnouncement ? 'Update Announcement' : 'Publish Announcement'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Details Modal */}
      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Announcement Preview"
        size="md"
      >
        {selectedAnnouncement && (
          <div className="flex flex-col gap-lg">
            <div>
              <h3 className="text-headline-sm font-bold text-on-surface">{selectedAnnouncement.title}</h3>
              <p className="text-label-md text-on-surface-variant mt-xs">
                Published on {new Date(selectedAnnouncement.created_at).toLocaleString()}
              </p>
            </div>
            <div className="bg-surface-container-low p-md rounded-xl text-body-md whitespace-pre-wrap">
              {selectedAnnouncement.content}
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

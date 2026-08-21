import React, { useEffect, useState } from 'react';
import { coverageService } from '../services/coverageService';
import type { CoverageArea, CreateCoverageInput, UpdateCoverageInput } from '../types/coverage';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';
import { CoverageForm } from '../components/coverage/CoverageForm';

export const CoverageManagement: React.FC = () => {
  const [areas, setAreas] = useState<CoverageArea[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');

  // Modal states
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [selectedArea, setSelectedArea] = useState<CoverageArea | undefined>(undefined);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchAreas = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await coverageService.getCoverageAreas();
      setAreas(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch coverage areas');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAreas();
  }, []);

  const handleCreateArea = async (data: CreateCoverageInput) => {
    try {
      setIsSubmitting(true);
      await coverageService.createCoverageArea(data);
      setIsFormModalOpen(false);
      fetchAreas();
    } catch (err: any) {
      alert(err.message || 'Failed to add coverage area');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdateArea = async (data: CreateCoverageInput) => {
    if (!selectedArea) return;
    try {
      setIsSubmitting(true);
      await coverageService.updateCoverageArea(selectedArea.id, data as UpdateCoverageInput);
      setIsFormModalOpen(false);
      setSelectedArea(undefined);
      fetchAreas();
    } catch (err: any) {
      alert(err.message || 'Failed to update area');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleToggleStatus = async (area: CoverageArea) => {
    const action = area.is_active ? 'deactivate' : 'activate';
    if (!window.confirm(`Are you sure you want to ${action} coverage for "${area.name}"?`)) return;

    try {
      await coverageService.toggleCoverageStatus(area.id, !area.is_active);
      fetchAreas();
    } catch (err: any) {
      alert(err.message || 'Failed to update status');
    }
  };

  const handleDeleteArea = async (area: CoverageArea) => {
    if (!window.confirm(`Are you sure you want to delete the "${area.name}" area? This will remove it from the system.`)) return;

    try {
      await coverageService.deleteCoverageArea(area.id);
      fetchAreas();
    } catch (err: any) {
      alert(err.message || 'Failed to delete area');
    }
  };

  const openEditModal = (area: CoverageArea) => {
    setSelectedArea(area);
    setIsFormModalOpen(true);
  };

  const filteredAreas = areas.filter(area => {
    const matchesSearch = area.name.toLowerCase().includes(search.toLowerCase());
    const matchesStatus = statusFilter === 'all' ||
                         (statusFilter === 'active' ? area.is_active : !area.is_active);
    return matchesSearch && matchesStatus;
  });

  const columns = [
    {
      header: 'Area Name',
      accessor: (item: CoverageArea) => (
        <div className="flex items-center gap-sm">
          <span className="material-symbols-outlined text-primary">location_on</span>
          <span className="font-title-md text-on-surface">{item.name}</span>
        </div>
      )
    },
    {
      header: 'Description',
      accessor: (item: CoverageArea) => (
        <div className="text-on-surface-variant truncate max-w-[300px]">
          {item.description || 'No description provided'}
        </div>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: CoverageArea) => (
        <Badge variant={item.is_active ? 'success' : 'error'}>
          {item.is_active ? 'Active' : 'Inactive'}
        </Badge>
      )
    },
    {
      header: 'Created Date',
      accessor: (item: CoverageArea) => (
        <span className="text-[12px] text-on-surface-variant">
          {new Date(item.created_at).toLocaleDateString()}
        </span>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: CoverageArea) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => openEditModal(item)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="Edit Area"
          >
            <span className="material-symbols-outlined text-[20px]">edit</span>
          </button>
          <button
            onClick={() => handleToggleStatus(item)}
            className={`w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center transition-colors ${item.is_active ? 'text-on-surface-variant hover:text-error' : 'text-on-surface-variant hover:text-success'}`}
            title={item.is_active ? 'Deactivate' : 'Activate'}
          >
            <span className="material-symbols-outlined text-[20px]">{item.is_active ? 'block' : 'check_circle'}</span>
          </button>
          <button
            onClick={() => handleDeleteArea(item)}
            className="w-8 h-8 rounded-full hover:bg-error-container/20 flex items-center justify-center text-on-surface-variant hover:text-error transition-colors"
            title="Delete Area"
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
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Coverage Management</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Manage the areas where Khokhar BroadNet provides internet services.</p>
        </div>
        <Button icon="add_location" onClick={() => { setSelectedArea(undefined); setIsFormModalOpen(true); }}>
          Add New Area
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-md mb-lg">
        <StatCard label="Total Areas" value={areas.length} icon="map" variant="primary" />
        <StatCard label="Active Coverage" value={areas.filter(a => a.is_active).length} icon="check_circle" variant="secondary" />
        <StatCard label="Disabled Nodes" value={areas.filter(a => !a.is_active).length} icon="location_off" variant="error" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search by area name..."
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <select
          className="bg-surface-container hover:bg-surface-container-high text-on-surface font-label-lg text-label-lg py-sm px-md rounded-lg outline-none cursor-pointer transition-colors"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value as any)}
        >
          <option value="all">All Statuses</option>
          <option value="active">Active Only</option>
          <option value="inactive">Inactive Only</option>
        </select>
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex-1 flex flex-col min-h-[400px]">
        {loading ? (
          <LoadingState />
        ) : error ? (
          <div className="p-xl text-center text-error">
            <span className="material-symbols-outlined text-[48px] mb-md">error</span>
            <p>{error}</p>
            <Button onClick={fetchAreas} className="mt-md">Retry</Button>
          </div>
        ) : filteredAreas.length === 0 ? (
          <EmptyState
            icon="map"
            title="No Areas Found"
            description="Start by adding your first coverage area to provide services."
            actionLabel="Add New Area"
            onAction={() => setIsFormModalOpen(true)}
          />
        ) : (
          <Table
            columns={columns}
            data={filteredAreas}
          />
        )}
      </div>

      <Modal
        isOpen={isFormModalOpen}
        onClose={() => { setIsFormModalOpen(false); setSelectedArea(undefined); }}
        title={selectedArea ? 'Edit Coverage Area' : 'Add New Coverage Area'}
        size="md"
      >
        <CoverageForm
          initialData={selectedArea}
          onSubmit={selectedArea ? handleUpdateArea : handleCreateArea}
          onCancel={() => { setIsFormModalOpen(false); setSelectedArea(undefined); }}
          isLoading={isSubmitting}
        />
      </Modal>
    </div>
  );
};

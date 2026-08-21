import React, { useEffect, useState } from 'react';
import { packageService } from '../services/packageService';
import { Package, CreatePackageInput } from '../types/package';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';
import { LoadingState } from '../components/ui/LoadingState';
import { EmptyState } from '../components/ui/EmptyState';
import { Modal } from '../components/ui/Modal';
import { PackageForm } from '../components/packages/PackageForm';

export const PackageList: React.FC = () => {
  const [packages, setPackages] = useState<Package[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');

  // Modal states
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [selectedPackage, setSelectedPackage] = useState<Package | undefined>(undefined);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchPackages = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await packageService.getPackages();
      setPackages(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch packages');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPackages();
  }, []);

  const handleCreatePackage = async (data: CreatePackageInput) => {
    try {
      setIsSubmitting(true);
      await packageService.createPackage(data);
      setIsFormModalOpen(false);
      fetchPackages();
    } catch (err: any) {
      alert(err.message || 'Failed to create package');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdatePackage = async (data: CreatePackageInput) => {
    if (!selectedPackage) return;
    try {
      setIsSubmitting(true);
      await packageService.updatePackage(selectedPackage.id, data);
      setIsFormModalOpen(false);
      setSelectedPackage(undefined);
      fetchPackages();
    } catch (err: any) {
      alert(err.message || 'Failed to update package');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleToggleStatus = async (pkg: Package) => {
    const action = pkg.is_active ? 'deactivate' : 'activate';
    if (!window.confirm(`Are you sure you want to ${action} the "${pkg.name}" package?`)) return;

    try {
      await packageService.togglePackageStatus(pkg.id, !pkg.is_active);
      fetchPackages();
    } catch (err: any) {
      alert(err.message || 'Failed to update status');
    }
  };

  const handleDeletePackage = async (pkg: Package) => {
    if (!window.confirm(`Are you sure you want to delete the "${pkg.name}" package? This action cannot be undone.`)) return;

    try {
      await packageService.deletePackage(pkg.id);
      fetchPackages();
    } catch (err: any) {
      alert(err.message || 'Failed to delete package');
    }
  };

  const openEditModal = (pkg: Package) => {
    setSelectedPackage(pkg);
    setIsFormModalOpen(true);
  };

  const openDetailsModal = (pkg: Package) => {
    setSelectedPackage(pkg);
    setIsDetailsModalOpen(true);
  };

  const filteredPackages = packages.filter(pkg => {
    const matchesSearch = pkg.name.toLowerCase().includes(search.toLowerCase()) ||
                         pkg.tag?.toLowerCase().includes(search.toLowerCase());
    const matchesStatus = statusFilter === 'all' ||
                         (statusFilter === 'active' ? pkg.is_active : !pkg.is_active);
    return matchesSearch && matchesStatus;
  });

  const columns = [
    {
      header: 'Package Name',
      accessor: (item: Package) => (
        <div className="flex flex-col">
          <div className="font-title-md text-title-md text-on-surface">{item.name}</div>
          {item.tag && (
            <div className="text-[10px] text-primary font-bold uppercase tracking-wider">{item.tag}</div>
          )}
        </div>
      )
    },
    {
      header: 'Speed',
      accessor: (item: Package) => (
        <div className="flex items-center gap-xs">
          <span className="material-symbols-outlined text-[18px] text-on-surface-variant">speed</span>
          <span className="font-label-lg">{item.speed_mbps} Mbps</span>
        </div>
      )
    },
    {
      header: 'Price',
      accessor: (item: Package) => (
        <div className="flex flex-col">
          <span className="font-label-lg text-label-lg">Rs. {item.price_per_month.toLocaleString()}</span>
          <span className="text-[11px] text-on-surface-variant">per month</span>
        </div>
      )
    },
    {
      header: 'Features',
      accessor: (item: Package) => (
        <div className="text-on-surface-variant truncate max-w-[200px]">
          {item.features?.join(', ') || 'No features listed'}
        </div>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: Package) => (
        <Badge variant={item.is_active ? 'success' : 'error'}>
          {item.is_active ? 'Active' : 'Inactive'}
        </Badge>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: Package) => (
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
            title="Edit Package"
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
            onClick={() => handleDeletePackage(item)}
            className="w-8 h-8 rounded-full hover:bg-error-container/20 flex items-center justify-center text-on-surface-variant hover:text-error transition-colors"
            title="Delete Package"
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
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Package Management</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Configure internet plans, speeds, and pricing for your customers.</p>
        </div>
        <div className="flex items-center gap-md">
          <Button
            icon="add"
            onClick={() => { setSelectedPackage(undefined); setIsFormModalOpen(true); }}
          >
            Create Package
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-md mb-lg">
        <StatCard label="Total Packages" value={packages.length} icon="inventory_2" variant="primary" />
        <StatCard label="Active Plans" value={packages.filter(p => p.is_active).length} icon="check_circle" variant="secondary" />
        <StatCard label="Highest Speed" value={`${Math.max(...packages.map(p => p.speed_mbps), 0)} Mbps`} icon="speed" variant="tertiary" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search by package name or tag..."
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
            <option value="active">Active Only</option>
            <option value="inactive">Inactive Only</option>
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
            <Button onClick={fetchPackages} className="mt-md">Retry</Button>
          </div>
        ) : filteredPackages.length === 0 ? (
          <EmptyState
            icon="inventory_2"
            title="No Packages Found"
            description={search || statusFilter !== 'all' ? "Try adjusting your search or filters." : "Start by creating your first internet package."}
            actionLabel={search || statusFilter !== 'all' ? "Clear Filters" : "Create Package"}
            onAction={() => {
              if (search || statusFilter !== 'all') {
                setSearch('');
                setStatusFilter('all');
              } else {
                setIsFormModalOpen(true);
              }
            }}
          />
        ) : (
          <Table
            columns={columns}
            data={filteredPackages}
            onRowClick={(item) => openDetailsModal(item)}
          />
        )}
      </div>

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isFormModalOpen}
        onClose={() => { setIsFormModalOpen(false); setSelectedPackage(undefined); }}
        title={selectedPackage ? 'Edit Package' : 'Create New Package'}
        size="lg"
      >
        <PackageForm
          initialData={selectedPackage}
          onSubmit={selectedPackage ? handleUpdatePackage : handleCreatePackage}
          onCancel={() => { setIsFormModalOpen(false); setSelectedPackage(undefined); }}
          isLoading={isSubmitting}
        />
      </Modal>

      {/* Details Modal */}
      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Package Details"
        size="md"
        footer={
          <div className="flex gap-md w-full">
            <Button
              variant="secondary"
              className="flex-1"
              onClick={() => { setIsDetailsModalOpen(false); openEditModal(selectedPackage!); }}
            >
              Edit Package
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
        {selectedPackage && (
          <div className="flex flex-col gap-lg">
            <div className="flex items-start justify-between">
              <div>
                <h3 className="text-headline-sm font-headline-sm text-on-surface">{selectedPackage.name}</h3>
                {selectedPackage.tag && (
                  <span className="inline-block bg-primary/10 text-primary px-sm py-xs rounded text-label-sm font-bold mt-xs uppercase">
                    {selectedPackage.tag}
                  </span>
                )}
              </div>
              <Badge variant={selectedPackage.is_active ? 'success' : 'error'}>
                {selectedPackage.is_active ? 'Active' : 'Inactive'}
              </Badge>
            </div>

            <div className="grid grid-cols-2 gap-md">
              <div className="bg-surface-container-low p-md rounded-xl">
                <div className="text-label-md text-on-surface-variant mb-xs">Speed</div>
                <div className="text-title-lg font-title-lg text-on-surface flex items-center gap-xs">
                  <span className="material-symbols-outlined text-primary">speed</span>
                  {selectedPackage.speed_mbps} Mbps
                </div>
              </div>
              <div className="bg-surface-container-low p-md rounded-xl">
                <div className="text-label-md text-on-surface-variant mb-xs">Monthly Price</div>
                <div className="text-title-lg font-title-lg text-on-surface flex items-center gap-xs">
                  <span className="material-symbols-outlined text-primary">payments</span>
                  Rs. {selectedPackage.price_per_month.toLocaleString()}
                </div>
              </div>
            </div>

            <div>
              <div className="text-label-lg font-label-lg text-on-surface mb-sm">Included Features</div>
              <ul className="grid grid-cols-1 gap-xs">
                {selectedPackage.features && selectedPackage.features.length > 0 ? (
                  selectedPackage.features.map((feature, idx) => (
                    <li key={idx} className="flex items-center gap-sm text-body-md text-on-surface-variant">
                      <span className="material-symbols-outlined text-success text-[20px]">check_circle</span>
                      {feature}
                    </li>
                  ))
                ) : (
                  <li className="text-on-surface-variant italic">No features listed</li>
                )}
              </ul>
            </div>

            <div className="text-[11px] text-on-surface-variant border-t border-surface-container-high pt-md">
              Created on: {new Date(selectedPackage.created_at).toLocaleDateString(undefined, {
                year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit'
              })}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

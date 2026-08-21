import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { customerService } from '../services/customerService';
import { Customer, CustomerStatus } from '../types/customer';
import { Table } from '../components/ui/Table';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { StatCard } from '../components/ui/StatCard';

export const CustomerList: React.FC = () => {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<CustomerStatus | 'all'>('all');
  const [stats, setStats] = useState({
    total: 0,
    active: 0,
    suspended: 0,
    pending: 0
  });

  const navigate = useNavigate();

  const fetchCustomers = async () => {
    try {
      setLoading(true);
      const { data } = await customerService.getCustomers({
        search,
        status: statusFilter,
      });
      setCustomers(data);

      // Calculate stats (in a real app, these might come from a separate RPC or optimized query)
      const total = data.length; // This is just for the current view, ideally from count
      setStats({
        total: data.length,
        active: data.filter(c => c.status === 'active').length,
        suspended: data.filter(c => c.status === 'suspended').length,
        pending: data.filter(c => c.status === 'pending').length
      });
    } catch (err: any) {
      setError(err.message || 'Failed to fetch customers');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomers();
  }, [search, statusFilter]);

  const handleStatusUpdate = async (id: string, newStatus: CustomerStatus) => {
    if (!window.confirm(`Are you sure you want to change status to ${newStatus}?`)) return;

    try {
      await customerService.updateCustomerStatus(id, newStatus);
      fetchCustomers();
    } catch (err: any) {
      alert(err.message || 'Failed to update status');
    }
  };

  const columns = [
    {
      header: 'KB-ID',
      accessor: 'kb_id',
      className: 'font-mono text-on-surface-variant group-hover:text-primary transition-colors'
    },
    {
      header: 'Customer Name',
      accessor: (item: Customer) => (
        <div className="flex items-center gap-sm">
          <div className="w-8 h-8 rounded-full bg-secondary-container text-on-secondary-container flex items-center justify-center font-title-md text-label-md flex-shrink-0">
            {item.full_name.split(' ').map(n => n[0]).join('')}
          </div>
          <div>
            <div className="font-title-md text-title-md text-on-surface truncate">{item.full_name}</div>
            <div className="text-[11px] text-on-surface-variant truncate">{item.email}</div>
          </div>
        </div>
      )
    },
    { header: 'Phone', accessor: 'phone', className: 'whitespace-nowrap' },
    {
      header: 'Area / Node',
      accessor: (item: Customer) => (
        <div className="flex items-center gap-xs">
          <span className="material-symbols-outlined text-[16px] text-on-surface-variant">location_on</span>
          <span className="truncate">{item.area}</span>
        </div>
      )
    },
    {
      header: 'Package',
      accessor: (item: Customer) => (
        <div className="flex flex-col">
          <span className="font-label-lg text-label-lg">{item.subscription?.package_name || 'No Plan'}</span>
          {item.subscription?.speed && (
            <span className="text-[11px] text-on-surface-variant uppercase tracking-widest">{item.subscription.speed}</span>
          )}
        </div>
      )
    },
    {
      header: 'Status',
      align: 'center' as const,
      accessor: (item: Customer) => (
        <Badge variant={item.status === 'active' ? 'success' : item.status === 'suspended' ? 'error' : 'pending'}>
          {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
        </Badge>
      )
    },
    {
      header: 'Actions',
      align: 'right' as const,
      accessor: (item: Customer) => (
        <div className="flex items-center justify-end gap-xs opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => navigate(`/customers/${item.id}`)}
            className="w-8 h-8 rounded-full hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
            title="View Details"
          >
            <span className="material-symbols-outlined text-[20px]">visibility</span>
          </button>
          {item.status === 'pending' && (
            <button
              onClick={() => handleStatusUpdate(item.id, 'active')}
              className="w-8 h-8 rounded-full hover:bg-primary-container/10 flex items-center justify-center text-on-surface-variant hover:text-primary transition-colors"
              title="Approve"
            >
              <span className="material-symbols-outlined text-[20px]">check_circle</span>
            </button>
          )}
          {item.status === 'active' && (
            <button
              onClick={() => handleStatusUpdate(item.id, 'suspended')}
              className="w-8 h-8 rounded-full hover:bg-error-container flex items-center justify-center text-on-surface-variant hover:text-error transition-colors"
              title="Suspend"
            >
              <span className="material-symbols-outlined text-[20px]">block</span>
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
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">Customers</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Manage subscribers, view details, and control account statuses.</p>
        </div>
        <div className="flex items-center gap-md">
          <Button variant="ghost" icon="download">Export CSV</Button>
          <Button icon="person_add">New Customer</Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-md mb-lg">
        <StatCard label="Total Customers" value={stats.total} icon="group" variant="primary" />
        <StatCard label="Active Connects" value={stats.active} icon="wifi" variant="secondary" />
        <StatCard label="Suspended" value={stats.suspended} icon="block" variant="error" />
        <StatCard label="Pending Install" value={stats.pending} icon="build" variant="tertiary" />
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm p-sm flex flex-col lg:flex-row gap-sm items-center z-10 relative">
        <div className="relative w-full lg:w-96 flex-shrink-0">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input
            className="w-full bg-surface-container hover:bg-surface-container-high focus:bg-surface-container-high transition-colors text-on-surface font-body-md text-body-md py-sm pl-xl pr-md rounded-lg outline-none placeholder:text-on-surface-variant/70"
            placeholder="Search by Name, Phone, or KB-ID..."
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
            <option value="suspended">Suspended</option>
            <option value="pending">Pending</option>
          </select>
        </div>

        <Button
          variant="ghost"
          icon="filter_alt_off"
          onClick={() => { setSearch(''); setStatusFilter('all'); }}
          className="ml-auto"
        >
          Clear
        </Button>
      </div>

      <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex-1 flex flex-col">
        {error ? (
          <div className="p-xl text-center text-error">
            <span className="material-symbols-outlined text-[48px] mb-md">error</span>
            <p>{error}</p>
            <Button onClick={fetchCustomers} className="mt-md">Retry</Button>
          </div>
        ) : (
          <Table
            columns={columns}
            data={customers}
            isLoading={loading}
            onRowClick={(item) => navigate(`/customers/${item.id}`)}
          />
        )}
      </div>
    </div>
  );
};

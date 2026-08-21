import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { customerService } from '../services/customerService';
import { Customer, CustomerStatus } from '../types/customer';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';

export const CustomerDetails: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [customer, setCustomer] = useState<Customer | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    const fetchCustomer = async () => {
      if (!id) return;
      try {
        setLoading(true);
        const data = await customerService.getCustomerById(id);
        setCustomer(data);
      } catch (err: any) {
        setError(err.message || 'Failed to fetch customer details');
      } finally {
        setLoading(false);
      }
    };

    fetchCustomer();
  }, [id]);

  const handleStatusChange = async (newStatus: CustomerStatus) => {
    if (!customer || !id) return;
    if (!window.confirm(`Are you sure you want to change this customer's status to ${newStatus}?`)) return;

    try {
      setUpdating(true);
      const updated = await customerService.updateCustomerStatus(id, newStatus);
      setCustomer(updated);
    } catch (err: any) {
      alert(err.message || 'Failed to update status');
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <span className="material-symbols-outlined animate-spin text-primary text-[48px]">autorenew</span>
      </div>
    );
  }

  if (error || !customer) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-md">
        <span className="material-symbols-outlined text-error text-[64px]">error</span>
        <h2 className="text-headline-md font-headline-md">{error || 'Customer not found'}</h2>
        <Button onClick={() => navigate('/customers')}>Back to List</Button>
      </div>
    );
  }

  return (
    <div className="flex flex-col w-full gap-xl pb-xl">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-md">
          <button
            onClick={() => navigate('/customers')}
            className="w-10 h-10 rounded-full hover:bg-surface-container flex items-center justify-center text-on-surface-variant transition-colors"
          >
            <span className="material-symbols-outlined">arrow_back</span>
          </button>
          <div>
            <div className="flex items-center gap-sm">
              <h1 className="font-headline-lg text-headline-lg text-on-surface">{customer.full_name}</h1>
              <Badge variant={customer.status === 'active' ? 'success' : customer.status === 'suspended' ? 'error' : 'pending'}>
                {customer.status.charAt(0).toUpperCase() + customer.status.slice(1)}
              </Badge>
            </div>
            <p className="font-body-md text-body-md text-on-surface-variant">KB-ID: {customer.kb_id} • Joined {new Date(customer.created_at).toLocaleDateString()}</p>
          </div>
        </div>
        <div className="flex items-center gap-md">
          {customer.status === 'pending' && (
            <Button variant="primary" onClick={() => handleStatusChange('active')} isLoading={updating}>Approve Customer</Button>
          )}
          {customer.status === 'active' && (
            <Button variant="error" onClick={() => handleStatusChange('suspended')} isLoading={updating}>Suspend Account</Button>
          )}
          {customer.status === 'suspended' && (
            <Button variant="primary" onClick={() => handleStatusChange('active')} isLoading={updating}>Reactivate Account</Button>
          )}
          <Button variant="secondary" icon="edit">Edit Profile</Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-xl">
        {/* Main Info */}
        <div className="lg:col-span-2 flex flex-col gap-xl">
          {/* Personal & Contact Details */}
          <div className="bg-surface-container-lowest rounded-xl p-lg shadow-sm border border-outline-variant/30">
            <h3 className="font-title-lg text-title-lg mb-lg flex items-center gap-sm">
              <span className="material-symbols-outlined text-primary">person</span>
              Information Details
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-xl">
              <div className="flex flex-col gap-sm">
                <label className="text-label-md font-label-md text-on-surface-variant uppercase tracking-wider">Full Name</label>
                <p className="text-body-lg font-body-lg">{customer.full_name}</p>
              </div>
              <div className="flex flex-col gap-sm">
                <label className="text-label-md font-label-md text-on-surface-variant uppercase tracking-wider">CNIC / ID Number</label>
                <p className="text-body-lg font-body-lg font-mono">{customer.cnic || 'Not provided'}</p>
              </div>
              <div className="flex flex-col gap-sm">
                <label className="text-label-md font-label-md text-on-surface-variant uppercase tracking-wider">Email Address</label>
                <p className="text-body-lg font-body-lg">{customer.email}</p>
              </div>
              <div className="flex flex-col gap-sm">
                <label className="text-label-md font-label-md text-on-surface-variant uppercase tracking-wider">Phone Number</label>
                <p className="text-body-lg font-body-lg">{customer.phone}</p>
              </div>
              <div className="flex flex-col gap-sm md:col-span-2">
                <label className="text-label-md font-label-md text-on-surface-variant uppercase tracking-wider">Service Address</label>
                <p className="text-body-lg font-body-lg">{customer.address}, {customer.area}</p>
              </div>
            </div>
          </div>

          {/* Subscription Section */}
          <div className="bg-surface-container-lowest rounded-xl p-lg shadow-sm border border-outline-variant/30">
            <h3 className="font-title-lg text-title-lg mb-lg flex items-center gap-sm">
              <span className="material-symbols-outlined text-surface-tint">router</span>
              Current Subscription
            </h3>
            {customer.subscription ? (
              <div className="flex items-center justify-between p-md bg-surface-container-low rounded-lg">
                <div className="flex items-center gap-md">
                  <div className="w-12 h-12 rounded-full bg-primary-container flex items-center justify-center">
                    <span className="material-symbols-outlined text-on-primary-container">speed</span>
                  </div>
                  <div>
                    <h4 className="font-title-md text-title-md">{customer.subscription.package_name}</h4>
                    <p className="text-body-md text-on-surface-variant">{customer.subscription.speed}</p>
                  </div>
                </div>
                <Button variant="ghost">Manage Plan</Button>
              </div>
            ) : (
              <div className="text-center py-lg text-on-surface-variant">
                <p>No active subscription found.</p>
                <Button variant="primary" className="mt-md">Assign Package</Button>
              </div>
            )}
          </div>
        </div>

        {/* Sidebar info */}
        <div className="flex flex-col gap-xl">
          {/* Quick Actions / Status Summary */}
          <div className="bg-surface-container-lowest rounded-xl p-lg shadow-sm border border-outline-variant/30">
            <h3 className="font-title-md text-title-md mb-md">Account Summary</h3>
            <div className="space-y-md">
              <div className="flex justify-between items-center py-xs border-b border-outline-variant/20">
                <span className="text-body-md text-on-surface-variant">System Role</span>
                <span className="font-label-md text-label-md uppercase">{customer.role}</span>
              </div>
              <div className="flex justify-between items-center py-xs border-b border-outline-variant/20">
                <span className="text-body-md text-on-surface-variant">Area Node</span>
                <span className="font-label-md text-label-md">{customer.area}</span>
              </div>
              <div className="flex justify-between items-center py-xs border-b border-outline-variant/20">
                <span className="text-body-md text-on-surface-variant">Installation Date</span>
                <span className="font-label-md text-label-md">{new Date(customer.created_at).toLocaleDateString()}</span>
              </div>
            </div>
          </div>

          {/* Activity / Complaints Summary Placeholder */}
          <div className="bg-surface-container-lowest rounded-xl p-lg shadow-sm border border-outline-variant/30">
            <h3 className="font-title-md text-title-md mb-md">Support History</h3>
            <div className="flex flex-col gap-sm">
               <div className="p-sm bg-surface-container-low rounded flex items-center justify-between">
                  <span className="text-label-md font-label-md">Open Complaints</span>
                  <span className="bg-error text-on-error px-2 py-0.5 rounded-full text-[10px]">0</span>
               </div>
               <div className="p-sm bg-surface-container-low rounded flex items-center justify-between">
                  <span className="text-label-md font-label-md">Total Tickets</span>
                  <span className="bg-surface-container-high text-on-surface-variant px-2 py-0.5 rounded-full text-[10px]">2</span>
               </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

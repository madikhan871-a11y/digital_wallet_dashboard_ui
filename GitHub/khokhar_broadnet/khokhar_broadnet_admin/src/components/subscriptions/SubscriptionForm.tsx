import React, { useState, useEffect } from 'react';
import { packageService } from '../../services/packageService';
import { customerService } from '../../services/customerService';
import type { Package } from '../../types/package';
import type { Customer } from '../../types/customer';
import { Button } from '../ui/Button';

interface SubscriptionFormProps {
  onSubmit: (data: any) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
}

export const SubscriptionForm: React.FC<SubscriptionFormProps> = ({ onSubmit, onCancel, isLoading }) => {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [packages, setPackages] = useState<Package[]>([]);
  const [loading, setLoading] = useState(true);

  const [formData, setFormData] = useState({
    customer_id: '',
    package_id: '',
    status: 'active',
    activation_date: new Date().toISOString().split('T')[0],
    expiry_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [custs, pkgs] = await Promise.all([
          customerService.getCustomers({ pageSize: 1000 }),
          packageService.getPackages()
        ]);
        setCustomers(custs.data || []);
        setPackages(pkgs || []);
      } catch (err) {
        console.error('Failed to load form data', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const selectedPkg = packages.find(p => p.id === formData.package_id);
    if (!selectedPkg) return;

    onSubmit({
      ...formData,
      package_name_snapshot: selectedPkg.name,
      speed_mbps_snapshot: selectedPkg.speed_mbps,
      monthly_price_snapshot: selectedPkg.monthly_price
    });
  };

  if (loading) return <div className="p-xl text-center">Loading options...</div>;

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-md">
      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-bold">Select Customer *</label>
        <select required className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.customer_id} onChange={e => setFormData({...formData, customer_id: e.target.value})}>
          <option value="">Choose a customer...</option>
          {customers.map(c => <option key={c.id} value={c.id}>{c.full_name} ({c.kb_id})</option>)}
        </select>
      </div>

      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-bold">Select Package *</label>
        <select required className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.package_id} onChange={e => setFormData({...formData, package_id: e.target.value})}>
          <option value="">Choose a plan...</option>
          {packages.map(p => <option key={p.id} value={p.id}>{p.name} - {p.speed_mbps}Mbps (Rs. {p.monthly_price})</option>)}
        </select>
      </div>

      <div className="grid grid-cols-2 gap-md">
        <div className="flex flex-col gap-xs">
          <label className="text-label-md font-bold">Activation Date</label>
          <input type="date" className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.activation_date} onChange={e => setFormData({...formData, activation_date: e.target.value})} />
        </div>
        <div className="flex flex-col gap-xs">
          <label className="text-label-md font-bold">Expiry Date</label>
          <input type="date" className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.expiry_date} onChange={e => setFormData({...formData, expiry_date: e.target.value})} />
        </div>
      </div>

      <div className="flex justify-end gap-md mt-md">
        <Button type="button" variant="ghost" onClick={onCancel}>Cancel</Button>
        <Button type="submit" isLoading={isLoading}>Create Subscription</Button>
      </div>
    </form>
  );
};

import React, { useState } from 'react';
import { Button } from '../ui/Button';

interface CustomerFormProps {
  onSubmit: (data: any) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
}

export const CustomerForm: React.FC<CustomerFormProps> = ({ onSubmit, onCancel, isLoading }) => {
  const [formData, setFormData] = useState({
    full_name: '',
    phone: '',
    email: '',
    cnic: '',
    area: 'DHA Phase 1',
    address: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-md">
      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-bold">Full Name *</label>
        <input required className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.full_name} onChange={e => setFormData({...formData, full_name: e.target.value})} />
      </div>
      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-bold">Phone Number *</label>
        <input required className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.phone} onChange={e => setFormData({...formData, phone: e.target.value})} />
      </div>
      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-bold">Email Address</label>
        <input type="email" className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} />
      </div>
      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-bold">CNIC</label>
        <input className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.cnic} onChange={e => setFormData({...formData, cnic: e.target.value})} />
      </div>
      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-bold">Area</label>
        <select className="bg-surface-container-high p-sm rounded-lg outline-none" value={formData.area} onChange={e => setFormData({...formData, area: e.target.value})}>
          <option>DHA Phase 1</option>
          <option>DHA Phase 2</option>
          <option>Model Town</option>
          <option>Gulberg III</option>
        </select>
      </div>
      <div className="flex flex-col gap-xs md:col-span-2">
        <label className="text-label-md font-bold">Installation Address</label>
        <textarea required className="bg-surface-container-high p-sm rounded-lg outline-none min-h-[80px]" value={formData.address} onChange={e => setFormData({...formData, address: e.target.value})} />
      </div>
      <div className="flex justify-end gap-md md:col-span-2 mt-md">
        <Button type="button" variant="ghost" onClick={onCancel}>Cancel</Button>
        <Button type="submit" isLoading={isLoading}>Register Customer</Button>
      </div>
    </form>
  );
};

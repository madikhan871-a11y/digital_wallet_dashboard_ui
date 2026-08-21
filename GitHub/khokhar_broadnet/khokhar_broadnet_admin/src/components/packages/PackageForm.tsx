import React, { useState, useEffect } from 'react';
import { CreatePackageInput, Package } from '../../types/package';
import { Button } from '../ui/Button';

interface PackageFormProps {
  initialData?: Package;
  onSubmit: (data: CreatePackageInput) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
}

export const PackageForm: React.FC<PackageFormProps> = ({
  initialData,
  onSubmit,
  onCancel,
  isLoading = false,
}) => {
  const [formData, setFormData] = useState<CreatePackageInput>({
    name: '',
    speed_mbps: 0,
    price_per_month: 0,
    features: [],
    is_active: true,
    tag: '',
  });

  const [featureInput, setFeatureInput] = useState('');

  useEffect(() => {
    if (initialData) {
      setFormData({
        name: initialData.name,
        speed_mbps: initialData.speed_mbps,
        price_per_month: initialData.price_per_month,
        features: initialData.features || [],
        is_active: initialData.is_active,
        tag: initialData.tag || '',
      });
    }
  }, [initialData]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value, type } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'number' ? Number(value) : value,
    }));
  };

  const handleToggleActive = () => {
    setFormData((prev) => ({ ...prev, is_active: !prev.is_active }));
  };

  const addFeature = () => {
    if (featureInput.trim()) {
      setFormData((prev) => ({
        ...prev,
        features: [...prev.features, featureInput.trim()],
      }));
      setFeatureInput('');
    }
  };

  const removeFeature = (index: number) => {
    setFormData((prev) => ({
      ...prev,
      features: prev.features.filter((_, i) => i !== index),
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-md">
        <div className="flex flex-col gap-xs">
          <label className="text-label-md font-label-md text-on-surface-variant">Package Name *</label>
          <input
            required
            name="name"
            value={formData.name}
            onChange={handleChange}
            className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
            placeholder="e.g. Home Basic"
          />
        </div>

        <div className="flex flex-col gap-xs">
          <label className="text-label-md font-label-md text-on-surface-variant">Speed (Mbps) *</label>
          <input
            required
            type="number"
            name="speed_mbps"
            value={formData.speed_mbps}
            onChange={handleChange}
            className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
            placeholder="e.g. 20"
          />
        </div>

        <div className="flex flex-col gap-xs">
          <label className="text-label-md font-label-md text-on-surface-variant">Monthly Price *</label>
          <input
            required
            type="number"
            name="price_per_month"
            value={formData.price_per_month}
            onChange={handleChange}
            className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
            placeholder="e.g. 1500"
          />
        </div>

        <div className="flex flex-col gap-xs">
          <label className="text-label-md font-label-md text-on-surface-variant">Tag (Optional)</label>
          <input
            name="tag"
            value={formData.tag}
            onChange={handleChange}
            className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
            placeholder="e.g. Best Seller"
          />
        </div>
      </div>

      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-label-md text-on-surface-variant">Features</label>
        <div className="flex gap-sm">
          <input
            value={featureInput}
            onChange={(e) => setFeatureInput(e.target.value)}
            className="flex-1 bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
            placeholder="Add a feature..."
            onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addFeature())}
          />
          <Button type="button" onClick={addFeature} variant="secondary" icon="add">Add</Button>
        </div>
        <div className="flex flex-wrap gap-xs mt-xs">
          {formData.features.map((feature, index) => (
            <div key={index} className="flex items-center gap-xs bg-secondary-container text-on-secondary-container px-sm py-xs rounded-full text-label-md">
              {feature}
              <button type="button" onClick={() => removeFeature(index)} className="material-symbols-outlined text-[16px] hover:text-error">close</button>
            </div>
          ))}
        </div>
      </div>

      <div className="flex items-center gap-md p-sm bg-surface-container-low rounded-lg">
        <div
          className={`w-12 h-6 rounded-full relative cursor-pointer transition-colors ${formData.is_active ? 'bg-primary' : 'bg-outline'}`}
          onClick={handleToggleActive}
        >
          <div className={`absolute top-1 w-4 h-4 rounded-full bg-white transition-all ${formData.is_active ? 'left-7' : 'left-1'}`} />
        </div>
        <div className="flex flex-col">
          <span className="text-label-lg font-label-lg text-on-surface">Active Status</span>
          <span className="text-[11px] text-on-surface-variant">Hidden from website if inactive</span>
        </div>
      </div>

      <div className="flex justify-end gap-md mt-md">
        <Button type="button" variant="ghost" onClick={onCancel}>Cancel</Button>
        <Button type="submit" isLoading={isLoading}>{initialData ? 'Update Package' : 'Create Package'}</Button>
      </div>
    </form>
  );
};

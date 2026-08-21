import React, { useState, useEffect } from 'react';
import type { CreateCoverageInput, CoverageArea } from '../../types/coverage';
import { Button } from '../ui/Button';

interface CoverageFormProps {
  initialData?: CoverageArea;
  onSubmit: (data: CreateCoverageInput) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
}

export const CoverageForm: React.FC<CoverageFormProps> = ({
  initialData,
  onSubmit,
  onCancel,
  isLoading = false,
}) => {
  const [formData, setFormData] = useState<CreateCoverageInput>({
    name: '',
    description: '',
    is_active: true,
  });

  useEffect(() => {
    if (initialData) {
      setFormData({
        name: initialData.name,
        description: initialData.description || '',
        is_active: initialData.is_active,
      });
    }
  }, [initialData]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleToggleActive = () => {
    setFormData((prev) => ({ ...prev, is_active: !prev.is_active }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-label-md text-on-surface-variant">Area Name *</label>
        <input
          required
          name="name"
          value={formData.name}
          onChange={handleChange}
          className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
          placeholder="e.g. DHA Phase 1"
        />
      </div>

      <div className="flex flex-col gap-xs">
        <label className="text-label-md font-label-md text-on-surface-variant">Description (Optional)</label>
        <textarea
          name="description"
          value={formData.description}
          onChange={handleChange}
          className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20 min-h-[100px]"
          placeholder="Additional details about the coverage node or boundaries..."
        />
      </div>

      <div className="flex items-center gap-md p-sm bg-surface-container-low rounded-lg">
        <div
          className={`w-12 h-6 rounded-full relative cursor-pointer transition-colors ${formData.is_active ? 'bg-primary' : 'bg-outline'}`}
          onClick={handleToggleActive}
        >
          <div className={`absolute top-1 w-4 h-4 rounded-full bg-white transition-all ${formData.is_active ? 'left-7' : 'left-1'}`} />
        </div>
        <div className="flex flex-col">
          <span className="text-label-lg font-label-lg text-on-surface">Serviceable Status</span>
          <span className="text-[11px] text-on-surface-variant">Allow new connections in this area</span>
        </div>
      </div>

      <div className="flex justify-end gap-md mt-md">
        <Button type="button" variant="ghost" onClick={onCancel}>Cancel</Button>
        <Button type="submit" isLoading={isLoading}>{initialData ? 'Update Area' : 'Add Area'}</Button>
      </div>
    </form>
  );
};

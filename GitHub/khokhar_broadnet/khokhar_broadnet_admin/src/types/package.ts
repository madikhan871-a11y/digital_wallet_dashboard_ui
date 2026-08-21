export interface Package {
  id: string;
  name: string;
  speed_mbps: number;
  price_per_month: number;
  features: string[];
  is_active: boolean;
  tag?: string;
  created_at: string;
}

export type CreatePackageInput = Omit<Package, 'id' | 'created_at'>;
export type UpdatePackageInput = Partial<CreatePackageInput>;

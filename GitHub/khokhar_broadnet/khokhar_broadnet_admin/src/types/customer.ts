export type CustomerStatus = 'pending' | 'active' | 'suspended';

export interface Customer {
  id: string;
  kb_id: string;
  full_name: string;
  phone: string;
  email: string;
  area: string;
  address: string;
  cnic: string;
  status: CustomerStatus;
  role: string;
  created_at: string;
  // Relationships (optional)
  subscription?: {
    id: string;
    package_name: string;
    speed: string;
  };
}

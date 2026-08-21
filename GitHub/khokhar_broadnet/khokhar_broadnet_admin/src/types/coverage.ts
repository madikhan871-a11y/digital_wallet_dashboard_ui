export interface CoverageArea {
  id: string;
  name: string;
  description?: string;
  is_active: boolean;
  created_at: string;
}

export interface CreateCoverageInput {
  name: string;
  description?: string;
  is_active: boolean;
}

export interface UpdateCoverageInput extends Partial<CreateCoverageInput> {}

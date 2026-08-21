import { supabase } from './supabase';
import type { CoverageArea, CreateCoverageInput, UpdateCoverageInput } from '../types/coverage';

export const coverageService = {
  async getCoverageAreas() {
    const { data, error } = await supabase
      .from('coverage_areas')
      .select('*')
      .order('name', { ascending: true });

    if (error) throw error;
    return data as CoverageArea[];
  },

  async createCoverageArea(input: CreateCoverageInput) {
    const { data, error } = await supabase
      .from('coverage_areas')
      .insert([input])
      .select()
      .single();

    if (error) throw error;
    return data as CoverageArea;
  },

  async updateCoverageArea(id: string, input: UpdateCoverageInput) {
    const { data, error } = await supabase
      .from('coverage_areas')
      .update(input)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as CoverageArea;
  },

  async toggleCoverageStatus(id: string, isActive: boolean) {
    const { data, error } = await supabase
      .from('coverage_areas')
      .update({ is_active: isActive })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as CoverageArea;
  },

  async deleteCoverageArea(id: string) {
    // Note: In a production app, we'd check if any customers are assigned to this area first.
    // Since we're moving from hardcoded strings to this table, we'll keep it simple for now.
    const { error } = await supabase
      .from('coverage_areas')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }
};

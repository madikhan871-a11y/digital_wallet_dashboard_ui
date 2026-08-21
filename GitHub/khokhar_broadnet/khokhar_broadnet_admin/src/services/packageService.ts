import { supabase } from './supabase';
import { Package, CreatePackageInput, UpdatePackageInput } from '../types/package';

export const packageService = {
  async getPackages() {
    const { data, error } = await supabase
      .from('packages')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data as Package[];
  },

  async getPackageById(id: string) {
    const { data, error } = await supabase
      .from('packages')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data as Package;
  },

  async createPackage(input: CreatePackageInput) {
    const { data, error } = await supabase
      .from('packages')
      .insert([input])
      .select()
      .single();

    if (error) throw error;
    return data as Package;
  },

  async updatePackage(id: string, input: UpdatePackageInput) {
    const { data, error } = await supabase
      .from('packages')
      .update(input)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Package;
  },

  async togglePackageStatus(id: string, isActive: boolean) {
    const { data, error } = await supabase
      .from('packages')
      .update({ is_active: isActive })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Package;
  },

  async deletePackage(id: string) {
    // First check if it's referenced by subscriptions
    const { count, error: checkError } = await supabase
      .from('subscriptions')
      .select('*', { count: 'exact', head: true })
      .eq('package_id', id);

    if (checkError) throw checkError;

    if (count && count > 0) {
      throw new Error('Cannot delete package as it is currently assigned to customers. Try deactivating it instead.');
    }

    const { error } = await supabase
      .from('packages')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }
};

import { supabase } from './supabase';
import { SystemSetting, ISPInfo, BillingSettings } from '../types/settings';

export const settingsService = {
  async getAllSettings() {
    const { data, error } = await supabase
      .from('system_settings')
      .select('*');

    if (error) throw error;
    return data as SystemSetting[];
  },

  async updateSetting(key: string, value: any) {
    const { data, error } = await supabase
      .from('system_settings')
      .update({ value, updated_at: new Date().toISOString() })
      .eq('key', key)
      .select()
      .single();

    if (error) throw error;
    return data as SystemSetting;
  },

  async getISPInfo(): Promise<ISPInfo> {
    const settings = await this.getAllSettings();
    const find = (key: string) => settings.find(s => s.key === key)?.value || '';

    return {
      name: find('isp_name'),
      supportPhone: find('support_phone'),
      whatsappNumber: find('whatsapp_number'),
      email: find('support_email'),
      address: find('isp_address'),
    };
  },

  async updateISPInfo(info: ISPInfo) {
    await Promise.all([
      this.updateSetting('isp_name', info.name),
      this.updateSetting('support_phone', info.supportPhone),
      this.updateSetting('whatsapp_number', info.whatsappNumber),
      this.updateSetting('support_email', info.email),
      this.updateSetting('isp_address', info.address),
    ]);
  },

  async getBillingSettings(): Promise<BillingSettings> {
    const settings = await this.getAllSettings();
    const find = (key: string) => settings.find(s => s.key === key)?.value;

    return {
      taxPercentage: Number(find('tax_percentage') || 0),
      currency: find('currency') || 'Rs.',
      defaultDueDateDays: Number(find('default_due_date_days') || 10),
    };
  },

  async updateBillingSettings(settings: BillingSettings) {
    await Promise.all([
      this.updateSetting('tax_percentage', settings.taxPercentage),
      this.updateSetting('currency', settings.currency),
      this.updateSetting('default_due_date_days', settings.defaultDueDateDays),
    ]);
  }
};

import { supabase } from './supabase';
import { Announcement, CreateAnnouncementInput, UpdateAnnouncementInput } from '../types/announcement';

export const announcementService = {
  async getAnnouncements() {
    const { data, error } = await supabase
      .from('announcements')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data as Announcement[];
  },

  async createAnnouncement(input: CreateAnnouncementInput) {
    const { data, error } = await supabase
      .from('announcements')
      .insert([input])
      .select()
      .single();

    if (error) throw error;
    return data as Announcement;
  },

  async updateAnnouncement(id: string, input: UpdateAnnouncementInput) {
    const { data, error } = await supabase
      .from('announcements')
      .update(input)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as Announcement;
  },

  async deleteAnnouncement(id: string) {
    const { error } = await supabase
      .from('announcements')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }
};

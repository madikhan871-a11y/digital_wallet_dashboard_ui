export interface Announcement {
  id: string;
  title: string;
  content: string;
  created_at: string;
}

export interface CreateAnnouncementInput {
  title: string;
  content: string;
}

export interface UpdateAnnouncementInput extends Partial<CreateAnnouncementInput> {}

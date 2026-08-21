import React, { useEffect, useState } from 'react';
import { authService } from '../services/authService';
import { settingsService } from '../services/settingsService';
import { ISPInfo, BillingSettings, AdminProfile } from '../types/settings';
import { Button } from '../components/ui/Button';
import { LoadingState } from '../components/ui/LoadingState';
import { Modal } from '../components/ui/Modal';

export const Settings: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'profile' | 'isp' | 'billing' | 'notifications'>('profile');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Admin Profile State
  const [profile, setProfile] = useState<AdminProfile | null>(null);
  const [passwordForm, setPasswordForm] = useState({ current: '', new: '', confirm: '' });
  const [isPasswordModalOpen, setIsPasswordModalOpen] = useState(false);

  // ISP Info State
  const [ispInfo, setIspInfo] = useState<ISPInfo>({
    name: '',
    supportPhone: '',
    whatsappNumber: '',
    email: '',
    address: ''
  });

  // Billing Settings State
  const [billingSettings, setBillingSettings] = useState<BillingSettings>({
    taxPercentage: 0,
    currency: 'Rs.',
    defaultDueDateDays: 10
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [user, isp, billing] = await Promise.all([
          authService.getCurrentUser(),
          settingsService.getISPInfo().catch(() => ({ name: 'Khokhar BroadNet', supportPhone: '', whatsappNumber: '', email: '', address: '' })),
          settingsService.getBillingSettings().catch(() => ({ taxPercentage: 0, currency: 'Rs.', defaultDueDateDays: 10 }))
        ]);

        if (user) {
          setProfile({
            id: user.id,
            name: user.user_metadata?.name || 'Admin User',
            email: user.email || '',
            avatarUrl: user.user_metadata?.avatar_url
          });
        }
        setIspInfo(isp);
        setBillingSettings(billing);
      } catch (err) {
        console.error('Failed to load settings', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleProfileUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!profile) return;
    try {
      setIsSubmitting(true);
      await authService.updateProfile({ name: profile.name });
      alert('Profile updated successfully');
    } catch (err: any) {
      alert(err.message || 'Failed to update profile');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handlePasswordUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (passwordForm.new !== passwordForm.confirm) {
      alert('New passwords do not match');
      return;
    }
    try {
      setIsSubmitting(true);
      await authService.updatePassword(passwordForm.new);
      alert('Password updated successfully');
      setIsPasswordModalOpen(false);
      setPasswordForm({ current: '', new: '', confirm: '' });
    } catch (err: any) {
      alert(err.message || 'Failed to update password');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleISPUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsSubmitting(true);
      await settingsService.updateISPInfo(ispInfo);
      alert('ISP information updated successfully');
    } catch (err: any) {
      alert(err.message || 'Failed to update ISP info');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleBillingUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsSubmitting(true);
      await settingsService.updateBillingSettings(billingSettings);
      alert('Billing settings updated successfully');
    } catch (err: any) {
      alert(err.message || 'Failed to update billing settings');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading) return <LoadingState />;

  const tabs = [
    { id: 'profile', label: 'Admin Profile', icon: 'person' },
    { id: 'isp', label: 'Business Info', icon: 'business' },
    { id: 'billing', label: 'Billing Setup', icon: 'receipt_long' },
    { id: 'notifications', label: 'Notifications', icon: 'notifications' },
  ];

  return (
    <div className="flex flex-col w-full h-full gap-lg">
      <div className="flex flex-col">
        <h1 className="font-headline-lg text-headline-lg text-on-surface mb-xs">System Settings</h1>
        <p className="font-body-lg text-body-lg text-on-surface-variant">Manage your account, business profile, and system-wide configurations.</p>
      </div>

      <div className="flex flex-col lg:flex-row gap-lg flex-1">
        {/* Navigation Sidebar */}
        <div className="w-full lg:w-64 flex-shrink-0">
          <div className="bg-surface-container-lowest rounded-2xl p-sm shadow-sm space-y-xs">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`w-full flex items-center gap-md px-md py-sm rounded-xl transition-all ${
                  activeTab === tab.id
                    ? 'bg-secondary-container text-on-secondary-container font-bold'
                    : 'text-on-surface-variant hover:bg-surface-container-high'
                }`}
              >
                <span className="material-symbols-outlined">{tab.icon}</span>
                <span className="text-label-lg font-label-lg">{tab.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Content Area */}
        <div className="flex-1 bg-surface-container-lowest rounded-2xl shadow-sm overflow-hidden flex flex-col">
          <div className="p-lg border-b border-surface-container-high bg-surface-container-low">
            <h2 className="text-title-lg font-bold text-on-surface">
              {tabs.find(t => t.id === activeTab)?.label}
            </h2>
          </div>

          <div className="flex-1 overflow-y-auto p-lg">
            {activeTab === 'profile' && profile && (
              <div className="max-w-2xl space-y-xl">
                <div className="flex items-center gap-xl">
                  <div className="w-24 h-24 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center text-[40px] font-bold">
                    {profile.name.charAt(0)}
                  </div>
                  <div>
                    <h3 className="text-headline-sm font-bold text-on-surface">{profile.name}</h3>
                    <p className="text-body-md text-on-surface-variant">{profile.email}</p>
                    <Badge variant="success">Administrator</Badge>
                  </div>
                </div>

                <form onSubmit={handleProfileUpdate} className="grid grid-cols-1 gap-lg pt-md">
                  <div className="flex flex-col gap-xs">
                    <label className="text-label-md text-on-surface-variant">Full Name</label>
                    <input
                      className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                      value={profile.name}
                      onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                    />
                  </div>
                  <div className="flex flex-col gap-xs">
                    <label className="text-label-md text-on-surface-variant">Email Address</label>
                    <input
                      disabled
                      className="bg-surface-container text-on-surface-variant p-sm rounded-lg outline-none opacity-60 cursor-not-allowed"
                      value={profile.email}
                    />
                  </div>
                  <div className="flex gap-md pt-md">
                    <Button type="submit" isLoading={isSubmitting}>Update Profile</Button>
                    <Button variant="secondary" type="button" onClick={() => setIsPasswordModalOpen(true)}>Change Password</Button>
                  </div>
                </form>
              </div>
            )}

            {activeTab === 'isp' && (
              <form onSubmit={handleISPUpdate} className="max-w-2xl space-y-lg">
                <div className="flex flex-col gap-xs">
                  <label className="text-label-md text-on-surface-variant">ISP Name *</label>
                  <input
                    required
                    className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                    value={ispInfo.name}
                    onChange={(e) => setIspInfo({ ...ispInfo, name: e.target.value })}
                  />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-md">
                  <div className="flex flex-col gap-xs">
                    <label className="text-label-md text-on-surface-variant">Support Phone</label>
                    <input
                      className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                      value={ispInfo.supportPhone}
                      onChange={(e) => setIspInfo({ ...ispInfo, supportPhone: e.target.value })}
                    />
                  </div>
                  <div className="flex flex-col gap-xs">
                    <label className="text-label-md text-on-surface-variant">WhatsApp Number</label>
                    <input
                      className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                      value={ispInfo.whatsappNumber}
                      onChange={(e) => setIspInfo({ ...ispInfo, whatsappNumber: e.target.value })}
                    />
                  </div>
                </div>
                <div className="flex flex-col gap-xs">
                  <label className="text-label-md text-on-surface-variant">Business Email</label>
                  <input
                    className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                    value={ispInfo.email}
                    onChange={(e) => setIspInfo({ ...ispInfo, email: e.target.value })}
                  />
                </div>
                <div className="flex flex-col gap-xs">
                  <label className="text-label-md text-on-surface-variant">Physical Address</label>
                  <textarea
                    className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20 min-h-[100px]"
                    value={ispInfo.address}
                    onChange={(e) => setIspInfo({ ...ispInfo, address: e.target.value })}
                  />
                </div>
                <div className="pt-md">
                  <Button type="submit" isLoading={isSubmitting}>Save Business Info</Button>
                </div>
              </form>
            )}

            {activeTab === 'billing' && (
              <form onSubmit={handleBillingUpdate} className="max-w-2xl space-y-lg">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-md">
                  <div className="flex flex-col gap-xs">
                    <label className="text-label-md text-on-surface-variant">Tax Percentage (%)</label>
                    <input
                      type="number"
                      step="0.1"
                      className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                      value={billingSettings.taxPercentage}
                      onChange={(e) => setBillingSettings({ ...billingSettings, taxPercentage: Number(e.target.value) })}
                    />
                  </div>
                  <div className="flex flex-col gap-xs">
                    <label className="text-label-md text-on-surface-variant">Currency Symbol</label>
                    <input
                      className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                      value={billingSettings.currency}
                      onChange={(e) => setBillingSettings({ ...billingSettings, currency: e.target.value })}
                    />
                  </div>
                </div>
                <div className="flex flex-col gap-xs">
                  <label className="text-label-md text-on-surface-variant">Default Due Date (Days after generation)</label>
                  <input
                    type="number"
                    className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
                    value={billingSettings.defaultDueDateDays}
                    onChange={(e) => setBillingSettings({ ...billingSettings, defaultDueDateDays: Number(e.target.value) })}
                  />
                </div>
                <div className="pt-md">
                  <Button type="submit" isLoading={isSubmitting}>Save Billing Setup</Button>
                </div>
              </form>
            )}

            {activeTab === 'notifications' && (
              <div className="max-w-2xl space-y-lg">
                <div className="bg-surface-container-low p-md rounded-2xl flex items-center justify-between border border-surface-container-high">
                  <div>
                    <h4 className="font-bold">Email Notifications</h4>
                    <p className="text-body-sm text-on-surface-variant">Send automated payment reminders to customers via email.</p>
                  </div>
                  <div className="w-12 h-6 bg-primary rounded-full relative"><div className="absolute right-1 top-1 w-4 h-4 bg-white rounded-full"></div></div>
                </div>
                <div className="bg-surface-container-low p-md rounded-2xl flex items-center justify-between border border-surface-container-high">
                  <div>
                    <h4 className="font-bold">WhatsApp Alerts</h4>
                    <p className="text-body-sm text-on-surface-variant">Integrate WhatsApp API for maintenance announcements.</p>
                  </div>
                  <div className="w-12 h-6 bg-outline rounded-full relative"><div className="absolute left-1 top-1 w-4 h-4 bg-white rounded-full"></div></div>
                </div>
                <div className="bg-secondary-container/20 p-md rounded-xl border border-secondary-container/40">
                  <p className="text-[12px] italic text-on-surface-variant">
                    Note: Notification integrations are currently being prepared for automated n8n workflows.
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Password Modal */}
      <Modal
        isOpen={isPasswordModalOpen}
        onClose={() => setIsPasswordModalOpen(false)}
        title="Change Security Password"
        size="sm"
      >
        <form onSubmit={handlePasswordUpdate} className="flex flex-col gap-lg">
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">New Password</label>
            <input
              type="password"
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
              value={passwordForm.new}
              onChange={(e) => setPasswordForm({ ...passwordForm, new: e.target.value })}
            />
          </div>
          <div className="flex flex-col gap-xs">
            <label className="text-label-md text-on-surface-variant">Confirm New Password</label>
            <input
              type="password"
              required
              className="bg-surface-container-high text-on-surface p-sm rounded-lg outline-none focus:ring-2 focus:ring-primary/20"
              value={passwordForm.confirm}
              onChange={(e) => setPasswordForm({ ...passwordForm, confirm: e.target.value })}
            />
          </div>
          <div className="flex justify-end gap-md">
            <Button variant="ghost" onClick={() => setIsPasswordModalOpen(false)}>Cancel</Button>
            <Button type="submit" isLoading={isSubmitting}>Change Password</Button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

// Internal Badge Component for Settings
const Badge: React.FC<{ children: React.ReactNode, variant: 'success' | 'info' }> = ({ children, variant }) => {
  const styles = {
    success: 'bg-primary-container/20 text-primary-container',
    info: 'bg-secondary-container/20 text-secondary-container'
  };
  return (
    <span className={`inline-flex px-sm py-xs rounded-full text-[10px] font-bold uppercase tracking-wider ${styles[variant]}`}>
      {children}
    </span>
  );
};

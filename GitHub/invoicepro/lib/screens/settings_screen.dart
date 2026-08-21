import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _biometricLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBjQiSbK_apHR7ehjSyjUUzPhDEgAbCRxxeye2h7oXObm4yKB9pjvaCRWZ40mQa4tI997SdKTx-PJCcLesgEtmgl0eoD1QUtsoJT0BwteG4SSsVY8YKMsNoh1fwglvmoJDlBfwib7j4o0N3MtNgaDcCK5d70lSJWQoGnyjxPpRvfGob3Vj982Sj0dj-rwt3Mb_d1SHenntOneBM5osnTO6mnAd60gTOWmz60CIBsEyg1m3CjFGzQkLb',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.receipt, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('Settings', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAFzig4dGn9ssLgpl5MItn4QgaxaTglPY8rgGKND-8UIUFabQQiHAqTSm40lEJRX2yqTpF8Brpr3gge1xl-4GxVERTX3Jh_wLndSGiv-AHJyGBnkIDGGSJMSGlWZabfqWHIh7lkO-rAPz-hERDwc1BQeLN5EOyq5fp-W81xrGdv4SsI38Fqf3Sjphh0Nu_sFbmtCNvhEcUHC8G3no4CgK1qibaHR4cZktyBzCc4hsFxmH4zFZsY1sVQ',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: AppColors.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTheme.lightTheme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your business profile, preferences, and app configuration.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Business Profile'),
            _buildCard([
              _buildListTile(
                icon: Icons.business,
                title: 'Acme Corp',
                subtitle: 'Edit business details & logo',
                onTap: () {},
                showChevron: true,
                leadingImage: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBDCFVzIN8NkCKb6CM048PBgoQ7pCuIUf3cJiTnRb3KJxWgREJCB_A5Ylhma28pGioHE9m_YWB7u4-0SBmLlfxg1TsY9aRK4NEOzr_FWzaNXaCYiWGj-iIkbdg2pi-hHuIUI5eLoyOFTlxN2WqZfr5jAt5ikfK1qG5GkqeBYHCGT-Kz_leBLUMg1Tf3F_MxkNbj1QdiVKCAISScgpHBdDaGWfj4afYDT9nJ5ZpnCqBXqRXcJ9B-K3qv',
              ),
              const Divider(height: 1, indent: 64),
              _buildListTile(
                icon: Icons.payments,
                title: 'Payment Methods',
                subtitle: 'Manage bank accounts & gateways',
                onTap: () {},
                showChevron: true,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primaryContainer,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            _buildCard([
              _buildListTile(
                icon: Icons.percent,
                title: 'Tax Rates',
                subtitle: 'Default tax: 10%',
                onTap: () {},
                showChevron: true,
              ),
              const Divider(height: 1, indent: 64),
              _buildListTile(
                icon: Icons.currency_exchange,
                title: 'Currency',
                subtitle: 'Default: USD (\$)',
                onTap: () {},
                showChevron: true,
              ),
              const Divider(height: 1, indent: 64),
              _buildListTile(
                icon: Icons.format_list_numbered,
                title: 'Invoice Numbering',
                subtitle: 'Prefix: INV-2024-',
                onTap: () {},
                showChevron: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('App Settings'),
            _buildCard([
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                value: _pushNotifications,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),
              const Divider(height: 1, indent: 64),
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                value: _biometricLogin,
                onChanged: (val) => setState(() => _biometricLogin = val),
              ),
              const Divider(height: 1, indent: 64),
              _buildListTile(
                icon: Icons.security,
                title: 'Security & Privacy',
                subtitle: 'Change password, 2FA',
                onTap: () {},
                showChevron: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Information'),
            _buildCard([
              _buildListTile(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {},
                showChevron: true,
              ),
              const Divider(height: 1, indent: 64),
              _buildListTile(
                icon: Icons.info,
                title: 'About InvoicePro',
                subtitle: 'Version 1.0.0',
                onTap: () {},
                showChevron: true,
              ),
            ]),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showChevron = false,
    Color? iconColor,
    Color? iconBgColor,
    String? leadingImage,
  }) {
    return ListTile(
      onTap: onTap,
      leading: leadingImage != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: NetworkImage(leadingImage), fit: BoxFit.cover),
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.onSurfaceVariant),
            ),
      title: Text(title, style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)) : null,
      trailing: showChevron ? const Icon(Icons.chevron_right, color: AppColors.outline) : null,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.onSurfaceVariant),
      ),
      title: Text(title, style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.onPrimary,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

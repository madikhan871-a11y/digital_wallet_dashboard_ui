import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../providers/expense_provider.dart';
import '../auth/login_screen.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
final _budgetController = TextEditingController();
final _nameController = TextEditingController();
File? _localImageFile;

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
if (mounted) {
_budgetController.text = context.read<ExpenseProvider>().monthlyBudgetLimit.toStringAsFixed(0);
}
});
}

@override
void dispose() {
_budgetController.dispose();
_nameController.dispose();
super.dispose();
}

Future<void> _imgSelect(ImageSource src) async {
try {
final file = await ImagePicker().pickImage(source: src, imageQuality: 70, maxWidth: 400);
if (file != null) {
setState(() => _localImageFile = File(file.path));
if (mounted) Navigator.pop(context);
}
} catch (e) {
debugPrint("Media framework crash: $e");
}
}

void _showMediaSheet() {
showModalBottomSheet(
context: context,
shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
builder: (ctx) => SafeArea(
child: Wrap(
children: [
ListTile(leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary), title: const Text("Gallery"), onTap: () => _imgSelect(ImageSource.gallery)),
ListTile(leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary), title: const Text("Camera"), onTap: () => _imgSelect(ImageSource.camera)),
],
),
),
);
}

void _showEditProfile(String name, bool isDark) {
_nameController.text = name;
showModalBottomSheet(
context: context,
isScrollControlled: true,
backgroundColor: AppColors.getCardBackground(isDark),
shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
builder: (ctx) => Padding(
padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 24, left: 24, right: 24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Text("Edit Profile Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark))),
const SizedBox(height: 20),
TextField(controller: _nameController, style: TextStyle(color: AppColors.getTextDark(isDark)), decoration: const InputDecoration(labelText: "Client Full Name", border: OutlineInputBorder())),
const SizedBox(height: 25),
SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
onPressed: () { Navigator.pop(context); setState(() {}); },
child: const Text("Save Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
),
),
const SizedBox(height: 25),
],
),
),
);
}

@override
Widget build(BuildContext context) {
final prov = Provider.of<ExpenseProvider>(context);
final isDark = prov.isDarkMode;
final user = AuthService().currentUser;
final uName = _nameController.text.isNotEmpty ? _nameController.text : (user?.userMetadata?['full_name'] ?? 'Fintech Client');

return Scaffold(
backgroundColor: AppColors.getBackground(isDark),
body: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
child: Column(
children: [
const SizedBox(height: 20),
Stack(
alignment: Alignment.bottomRight,
children: [
CircleAvatar(
radius: 55, backgroundColor: Colors.grey.shade300,
backgroundImage: _localImageFile != null ? FileImage(_localImageFile!) : null,
child: _localImageFile == null ? Text(uName.substring(0,1).toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)) : null,
),
InkWell(onTap: _showMediaSheet, child: const CircleAvatar(radius: 18, backgroundColor: AppColors.primary, child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white)))
],
),
const SizedBox(height: 16),
Text(uName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark))),
Text(user?.email ?? "Cloud Active", style: TextStyle(color: AppColors.getTextLight(isDark), fontSize: 13)),
const SizedBox(height: 15),
OutlinedButton.icon(
style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
onPressed: () => _showEditProfile(uName, isDark),
icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
label: const Text("Edit Details Info", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
),
const SizedBox(height: 25),
Container(
decoration: BoxDecoration(color: AppColors.getCardBackground(isDark), borderRadius: BorderRadius.circular(20)),
child: SwitchListTile(
title: Text("Dark Layout Mode", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark), fontSize: 15)),
secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.primary),
value: isDark, activeColor: AppColors.primary,
onChanged: (val) => prov.toggleTheme(val),
),
),
const SizedBox(height: 16),
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: AppColors.getCardBackground(isDark), borderRadius: BorderRadius.circular(20)),
child: Column(
children: [
Row(children: [const Icon(Icons.currency_exchange, color: AppColors.primary), const SizedBox(width: 10), Text("Multi-Currency", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark)))]),
const SizedBox(height: 12),
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: prov.activeCurrencySymbol == "\$" ? AppColors.primary : Colors.grey.withAlpha(30)), onPressed: () => prov.setCurrencyFormat("\$", 1.0), child: const Text("\$")),
ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: prov.activeCurrencySymbol == "Rs" ? AppColors.primary : Colors.grey.withAlpha(30)), onPressed: () => prov.setCurrencyFormat("Rs", 278.0), child: const Text("Rs")),
ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: prov.activeCurrencySymbol == "€" ? AppColors.primary : Colors.grey.withAlpha(30)), onPressed: () => prov.setCurrencyFormat("€", 0.92), child: const Text("€")),
])
],
),
),
const SizedBox(height: 16),
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(color: AppColors.getCardBackground(isDark), borderRadius: BorderRadius.circular(24)),
child: Column(
children: [
Row(children: [const Icon(Icons.tune, color: AppColors.primary), const SizedBox(width: 8), Text("Budget Cap Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark)))]),
const SizedBox(height: 20),
Row(
children: [
Expanded(child: TextField(controller: _budgetController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.getTextDark(isDark)), decoration: InputDecoration(prefixIcon: const Icon(Icons.attach_money), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.getBorder(isDark))), border: const OutlineInputBorder()))),
const SizedBox(width: 12),
ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
onPressed: () {
final amt = double.tryParse(_budgetController.text.trim());
if (amt != null && amt > 0) { prov.updateBudgetLimit(amt); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Limit Saved!"), backgroundColor: Colors.green)); }
},
child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
)
],
)
],
),
),
const SizedBox(height: 16),
  Card(
    color: AppColors.getCardBackground(isDark),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.getBorder(isDark))
    ),
    child: ListTile(
      leading: const Icon(Icons.logout, color: AppColors.redSmooth),
      title: const Text(
          "Logout Session",
          style: TextStyle(color: AppColors.redSmooth, fontWeight: FontWeight.bold)
      ),
      onTap: () async {
        await AuthService().logout();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false
          );
        }
      },
    ),
  )
],
),
),
);
}
}


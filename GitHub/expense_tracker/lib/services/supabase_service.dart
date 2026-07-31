import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Live server initialize handler configuration
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://hskgjfhoqqjgfblvtziw.supabase.co',
      anonKey: 'sb_publishable_gpQeg8HsGD5mXfxCxdg7vg_MMwF16Nr',
    );



  }

  // Active secure backend instance getter client
  static SupabaseClient get client => Supabase.instance.client;
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_ANON_KEY .env dosyasında tanımlı değil. '
        '.env.example dosyasını kopyalayıp kendi değerlerinizi girin.',
      );
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
}

SupabaseClient get supabase => Supabase.instance.client;

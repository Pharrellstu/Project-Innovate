import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  static final SupabaseClient client = Supabase.instance.client;
}

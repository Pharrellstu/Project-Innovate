import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbHandler {
  SupabaseClient supabase = Supabase.instance.client;
  
  Future<void> insertUser(String userId, String email) async {
    try {
      await supabase.from('account').insert({
        'auth_user_id': userId,
        'username': email.split('@')[0], // TEMP: Use email prefix as username
        'email': email,
      });
    } catch (e) {
      log('Error inserting user: $e');
    }
  }
}
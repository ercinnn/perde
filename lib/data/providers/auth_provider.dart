import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_config.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

final currentSessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider).valueOrNull;
  return authState?.session ?? supabase.auth.currentSession;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentSessionProvider) != null;
});

class AuthController {
  AuthController();

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController());

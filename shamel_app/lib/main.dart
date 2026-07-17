import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_service.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Catch UI errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'UI Error:\n${details.exception}\n\n${details.stack}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
        ),
      );
    };
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Request permission for notifications
    await FirebaseMessaging.instance.requestPermission();
    
    // Setup FCM Service
    await FCMService.initialize();

    // Initialize SharedPreferences
    final sharedPrefs = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(sharedPrefs),
        ],
        child: const ShamelApp(),
      ),
    );
  } catch (e, stackTrace) {
    runApp(MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Startup Error:\n$e\n\n$stackTrace',
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

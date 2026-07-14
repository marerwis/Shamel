import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

void main() async {
  const supabaseUrl = 'https://ahhmkwhrbwlyteinwlwb.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoaG1rd2hyYndseXRlaW53bHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4ODkyMTMsImV4cCI6MjA5OTQ2NTIxM30.gZ86XXc7UpdDKk_Jjz7drlzXKxum_2LX9gJwaZVdWdI';
  
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  final uuid = Uuid();

  print('Starting lifecycle test...');

  try {
    // 0. Create Admin
    print('0. Creating Admin...');
    final adminEmail = 'admin_${uuid.v4().substring(0,8)}@test.com';
    print('Admin Email: $adminEmail');
    try {
      final adminAuthRes = await client.auth.signUp(
        email: adminEmail,
        password: 'Password123!',
      );
      if (adminAuthRes.user == null) {
        print('Error: User is null after signup! AuthResponse: $adminAuthRes');
        exit(1);
      }
      final adminId = adminAuthRes.user!.id;
      print('Admin User Created: $adminId');
      await client.from('profiles').update({
        'full_name': 'Test Admin',
        'role': 'admin',
      }).eq('id', adminId);
    } catch (e) {
      print('Signup failed: $e');
      exit(1);
    }

    // 1. Create a Category
    print('1. Creating Category...');
    final catRes = await client.from('categories').insert({
      'name': 'صيانة سيارات',
      'icon': 'https://example.com/car.png'
    }).select().single();
    final catId = catRes['id'];
    print('Category Created: $catId');

    // 2. Create Sub-category
    print('2. Creating Sub-category...');
    final subCatRes = await client.from('categories').insert({
      'name': 'كهربائي سيارات',
      'parent_id': catId,
      'icon': 'https://example.com/elec.png'
    }).select().single();
    final subCatId = subCatRes['id'];
    print('Sub-category Created: $subCatId');

    // 3. Create Provider Account
    print('3. Creating Provider Account...');
    final providerEmail = 'provider_${uuid.v4().substring(0,8)}@test.com';
    final providerAuthRes = await client.auth.signUp(
      email: providerEmail,
      password: 'password123',
    );
    final providerId = providerAuthRes.user!.id;
    
    // Update profile role
    await client.from('profiles').update({
      'full_name': 'Test Provider',
      'role': 'provider',
    }).eq('id', providerId);

    // Insert provider details
    await client.from('provider_details').insert({
      'id': providerId,
      'father_name': 'Father',
      'grandfather_name': 'Grandfather',
      'id_type': 'passport',
      'id_number': '12345678',
      'category_id': subCatId,
    });
    print('Provider Created: $providerId');

    // 4. Create Service
    print('4. Creating Service...');
    final serviceRes = await client.from('services').insert({
      'provider_id': providerId,
      'category_id': subCatId,
      'title': 'تصليح دينمو',
      'description': 'تصليح جميع أنواع الدينمو',
      'price': 150.0,
      'image_url': 'https://example.com/dynamo.png'
    }).select().single();
    final serviceId = serviceRes['id'];
    print('Service Created: $serviceId');

    // 5. Create Customer Account
    print('5. Creating Customer Account...');
    final customerEmail = 'customer_${uuid.v4().substring(0,8)}@test.com';
    final customerAuthRes = await client.auth.signUp(
      email: customerEmail,
      password: 'password123',
    );
    final customerId = customerAuthRes.user!.id;
    await client.from('profiles').update({
      'full_name': 'Test Customer',
      'role': 'customer',
    }).eq('id', customerId);
    print('Customer Created: $customerId');

    // 6. Create Order
    print('6. Creating Order...');
    final orderRes = await client.from('orders').insert({
      'customer_id': customerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'status': 'pending',
      'price': 150.0,
      'address': 'Libya, Tripoli',
    }).select().single();
    final orderId = orderRes['id'];
    print('Order Created: $orderId');

    print('Lifecycle test completed successfully!');
    exit(0);
  } catch (e) {
    print('Error during lifecycle test: $e');
    exit(1);
  }
}

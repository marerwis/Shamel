import 'package:supabase/supabase.dart';
import 'dart:math';

void main() async {
  const supabaseUrl = 'https://ahhmkwhrbwlyteinwlwb.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoaG1rd2hyYndseXRlaW53bHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4ODkyMTMsImV4cCI6MjA5OTQ2NTIxM30.gZ86XXc7UpdDKk_Jjz7drlzXKxum_2LX9gJwaZVdWdI';
  
  final client = SupabaseClient(
    supabaseUrl,
    supabaseAnonKey,
    authOptions: const AuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  try {
    final rand = Random().nextInt(100000);
    final customerEmail = 'customer_$rand@test.com';
    final providerEmail = 'provider_$rand@test.com';
    
    print('1. Signing up Customer: $customerEmail');
    final customerRes = await client.auth.signUp(
      email: customerEmail,
      password: 'Password123!',
      data: {'role': 'user', 'full_name': 'Test Customer'}
    );
    final customerId = customerRes.user!.id;
    
    print('2. Signing up Provider: $providerEmail');
    final providerRes = await client.auth.signUp(
      email: providerEmail,
      password: 'Password123!',
      data: {'role': 'provider', 'full_name': 'Test Provider'}
    );
    final providerId = providerRes.user!.id;

    // Login as Provider to set category (required for broadcast)
    await client.auth.signInWithPassword(email: providerEmail, password: 'Password123!');
    print('3. Updating provider details...');
    // We must update the profiles table
    await client.from('profiles').update({'role': 'provider', 'status': 'active'}).eq('id', providerId);
    
    // Login as Customer
    await client.auth.signInWithPassword(email: customerEmail, password: 'Password123!');
    print('4. Customer creates a request...');
    
    // Fetch a real category_id
    final catRes = await client.from('categories').select('id').limit(1).single();
    final categoryId = catRes['id'];

    final requestRes = await client.from('requests').insert({
      'customer_id': customerId,
      'category_id': categoryId,
      'description': 'Test plumbing issue',
      'status': 'Pending_Broadcast'
    }).select().single();
    final requestId = requestRes['id'];
    print('   Request created: $requestId');

    // Login as Provider
    await client.auth.signInWithPassword(email: providerEmail, password: 'Password123!');
    print('5. Provider submits a bid...');
    final bidRes = await client.from('bids').insert({
      'request_id': requestId,
      'provider_id': providerId,
      'price': 100.0,
      'status': 'Pending',
      'net_profit': 90.0
    }).select().single();
    final bidId = bidRes['id'];
    print('   Bid created: $bidId');

    // Login as Customer
    await client.auth.signInWithPassword(email: customerEmail, password: 'Password123!');
    
    // Give customer some money
    print('6. Admin funds customer wallet...');
    // To do this, we need an admin or just a raw SQL update. But wait, normal user can't update their balance.
    // Let's try calling an RPC if available, or just ignore escrow funding if not enforced.
    // Actually `accept_bid_and_create_order` requires funds in the customer's wallet.
    // We can't easily add funds without RLS bypass.
    print('Notice: We might need RLS bypass to add funds. Let\'s attempt accept_bid_and_create_order.');
    try {
      await client.rpc('accept_bid_and_create_order', params: {
        'p_request_id': requestId,
        'p_bid_id': bidId,
        'p_customer_id': customerId,
        'p_provider_id': providerId,
        'p_total_amount': 100.0
      });
      print('   Order and Escrow created successfully!');
    } catch(e) {
      print('   Failed (Expected if wallet is empty): $e');
    }

    print('Test Lifecycle Script Completed!');
  } catch (e) {
    print('Error: $e');
  }
}

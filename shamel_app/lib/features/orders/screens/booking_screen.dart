import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/providers/services_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../../requests/providers/requests_provider.dart';
import '../../../core/providers/shared_prefs_provider.dart';
import '../../wallet/providers/wallet_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final ServiceModel? service;
  final Map<String, dynamic>? provider;

  const BookingScreen({super.key, this.service, this.provider});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  bool _isLoading = false;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveSelectedArea(String area) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString('selected_area', area);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
      );
      return;
    }

    final providerId = widget.provider?['id'];

    setState(() {
      _isLoading = true;
    });

    try {
      if (providerId == null) {
        // Broadcast request logic
        final desc = '''
خدمة: ${widget.service?.title ?? 'عام'}
الموقع: ${_addressController.text}
السعر المتوقع: ${widget.service?.price ?? 50.0} د.ل
ملاحظات: ${_notesController.text}
''';
        await ref.read(requestsProvider.notifier).createRequest(
          categoryId: widget.service?.categoryId ?? '',
          serviceId: widget.service?.id,
          description: desc,
          imageFiles: [],
          price: widget.service?.price ?? 50.0,
          address: _addressController.text,
          notes: _notesController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء طلب عام بنجاح! بانتظار عروض المزودين.'), backgroundColor: Colors.green),
          );
          ref.invalidate(myRequestsStreamProvider);
          ref.invalidate(walletProvider);
          context.go('/orders'); // Go to orders or requests
        }
      } else {
        // Direct order logic
        await ref.read(ordersProvider.notifier).createOrder(
          providerId: providerId,
          serviceId: widget.service?.id,
          price: widget.service?.price ?? 50.0,
          address: _addressController.text,
          notes: _notesController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال الطلب بنجاح!'), backgroundColor: Colors.green),
          );
          ref.invalidate(myOrdersStreamProvider);
          ref.invalidate(walletProvider);
          context.go('/orders');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحجز: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.service == null && widget.provider == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حجز الخدمة')),
        body: const Center(child: Text('الرجاء اختيار خدمة أو مزود أولاً')),
      );
    }

    final srv = widget.service;
    final prov = widget.provider;

    final displayName = srv?.title ?? prov?['first_name'] ?? 'طلب خدمة';
    final displayCategory = srv?.categoryId ?? prov?['provider_details']?[0]?['title'] ?? 'عام';
    final displayPrice = srv?.price.toString() ?? 'حسب الاتفاق';

    final profileAsync = ref.watch(userProfileProvider);
    final sharedPrefs = ref.watch(sharedPrefsProvider);
    
    // Initialize addressController synchronously before build if empty
    if (_addressController.text.isEmpty) {
      final savedArea = sharedPrefs.getString('selected_area');
      if (savedArea != null && savedArea.isNotEmpty) {
        _addressController.text = savedArea;
      } else {
        // Fallback to profile address
        profileAsync.whenData((profile) {
          if (profile != null && profile['address'] != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _addressController.text.isEmpty) {
                _addressController.text = profile['address'];
                setState((){});
              }
            });
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          color: AppColors.primary,
        ),
        title: const Text('تفاصيل الحجز', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service/Provider Info Snippet
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(srv != null ? Icons.home_repair_service : Icons.person, color: AppColors.onPrimaryContainer, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(displayCategory, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Text(srv != null ? 'د.ل $displayPrice' : displayPrice, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Location
                Text('مكان الطلب', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _addressController.text.isNotEmpty && const ['سيدي حسين', 'الكيش', 'الفويهات', 'الماجوري', 'الحدائق', 'بوعطني', 'شبنة', 'بلعون', 'طريق النهر', 'وسط البلاد'].contains(_addressController.text) 
                      ? _addressController.text 
                      : null,
                  items: const ['سيدي حسين', 'الكيش', 'الفويهات', 'الماجوري', 'الحدائق', 'بوعطني', 'شبنة', 'بلعون', 'طريق النهر', 'وسط البلاد']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _addressController.text = newValue;
                      _saveSelectedArea(newValue);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'اختر منطقتك',
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(height: 32),



                // Problem Description
                Text('وصف الطلب بدقة', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'اكتب تفاصيل المشكلة أو أي ملاحظات للمزود...',
                    hintStyle: const TextStyle(color: AppColors.outline),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: (!_isLoading) ? _submitOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.surfaceVariant,
              disabledForegroundColor: AppColors.onSurfaceVariant,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('تأكيد الحجز', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

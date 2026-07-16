import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/requests_provider.dart';
import '../providers/commission_provider.dart';

class ProviderAcceptRequestScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> request;
  
  const ProviderAcceptRequestScreen({super.key, required this.request});

  @override
  ConsumerState<ProviderAcceptRequestScreen> createState() => _ProviderAcceptRequestScreenState();
}

class _ProviderAcceptRequestScreenState extends ConsumerState<ProviderAcceptRequestScreen> {
  final _priceCtrl = TextEditingController();
  double _netProfit = 0.0;
  double _commissionRate = 0.10;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCommission();
  }

  void _fetchCommission() async {
    try {
      final rate = await ref.read(commissionRateProvider.future);
      if (mounted) {
        setState(() {
          _commissionRate = rate;
        });
      }
    } catch (_) {}
  }

  void _submitPrice() async {
    final p = double.tryParse(_priceCtrl.text);
    if (p == null || p <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال سعر صحيح')));
      return;
    }
    
    setState(() => _isSubmitting = true);
    try {
      await ref.read(requestsProvider.notifier).submitBid(
        requestId: widget.request['id'],
        price: p,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال عرضك للعميل! بانتظار موافقته.')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().contains('duplicate') ? 'لقد قمت بتقديم عرض مسبقاً!' : 'خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.request['description'] ?? 'بدون وصف';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text('قبول الطلب وتحديد السعر'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تفاصيل الطلب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'أدخل القيمة المتفق عليها لإنجاز هذا الطلب (سيتم إرسالها للعميل للموافقة):',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'السعر المقترح (بدينار ليبي)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                final p = double.tryParse(val) ?? 0;
                setState(() {
                  _netProfit = p * (1 - _commissionRate);
                });
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الصافي المتوقع لك (بعد خصم العمولة):', style: TextStyle(fontSize: 14)),
                  Text('${_netProfit.toStringAsFixed(2)} د.ل', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: _isSubmitting ? null : _submitPrice,
              child: _isSubmitting 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('تأكيد العرض وإرساله للعميل'),
            ),
          ],
        ),
      ),
    );
  }
}

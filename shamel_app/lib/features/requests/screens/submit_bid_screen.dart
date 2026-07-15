import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/requests_provider.dart';

import '../providers/commission_provider.dart';

class SubmitBidScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> requestData;
  const SubmitBidScreen({super.key, required this.requestData});

  @override
  ConsumerState<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends ConsumerState<SubmitBidScreen> {
  final _priceController = TextEditingController();
  double _netProfit = 0.0;
  double _commissionRate = 0.10; // Default fallback

  @override
  void initState() {
    super.initState();
    // Load dynamic commission rate
    Future.microtask(() async {
      try {
        final rate = await ref.read(commissionRateProvider.future);
        setState(() {
          _commissionRate = rate;
        });
      } catch(e) {
        // Fallback to 10%
      }
    });
  }

  void _calculateProfit(String value) {
    final double? price = double.tryParse(value);
    if (price != null) {
      setState(() {
        _netProfit = price * (1 - _commissionRate);
      });
    } else {
      setState(() {
        _netProfit = 0.0;
      });
    }
  }

  void _submitBid() async {
    final double? price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال سعر صحيح')));
      return;
    }

    try {
      await ref.read(requestsProvider.notifier).submitBid(
        requestId: widget.requestData['id'],
        price: price,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال عرضك للعميل بنجاح!')));
      context.pop();
    } catch (e) {
      if (e.toString().contains('duplicate key value')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لقد قمت بتقديم عرض مسبقاً لهذا الطلب!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم عرض سعر'),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('تفاصيل الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(widget.requestData['description'] ?? '', style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 32),
                const Text('أدخل عرض السعر (بدينار ليبي)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'مثال: 150',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  onChanged: _calculateProfit,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('سيتم خصم عمولة التطبيق (${(_commissionRate * 100).toInt()}%):'),
                          Text('${(_netProfit > 0 ? double.parse(_priceController.text) - _netProfit : 0).toStringAsFixed(2)} د.ل', style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الصافي المتوقع لك:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${_netProfit.toStringAsFixed(2)} د.ل', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitBid,
                  child: const Text('إرسال العرض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
        ),
    );
  }
}

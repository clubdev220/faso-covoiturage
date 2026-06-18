import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});
  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadBookings(); }

  Future<void> _loadBookings() async {
    final authState = ref.read(authStateProvider);
    if (authState.token == null) { setState(() => _isLoading = false); return; }
    try {
      final bookings = await ref.read(bookingRepositoryProvider).getMyBookings(authState.token!);
      setState(() => _bookings = bookings);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error)); }
    finally { setState(() => _isLoading = false); }
  }

  Color _statusColor(String status) {
    switch (status) { case 'pending': return Colors.orange; case 'accepted': return AppColors.success; case 'rejected': return AppColors.error; case 'cancelled': return Colors.grey; case 'completed': return AppColors.primary; default: return Colors.grey; }
  }

  String _statusLabel(String status) {
    switch (status) { case 'pending': return 'En attente'; case 'accepted': return 'Confirmé'; case 'rejected': return 'Refusé'; case 'cancelled': return 'Annulé'; case 'completed': return 'Terminé'; default: return status; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes réservations')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _bookings.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.book, size: 64, color: AppColors.textSecondary), const SizedBox(height: 16), const Text('Aucune réservation')])) : RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView.builder(itemCount: _bookings.length, padding: const EdgeInsets.all(16), itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Réservation #${(booking['id'] ?? '').toString().substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _statusColor(booking['status'] ?? '').withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(_statusLabel(booking['status'] ?? ''), style: TextStyle(color: _statusColor(booking['status'] ?? ''), fontSize: 12))),
            ]),
            const SizedBox(height: 12),
            Text('${booking['seats'] ?? 0} place(s) • ${booking['totalAmount'] ?? 0} FCFA'),
            Text('Paiement: ${booking['paymentMethod'] ?? ''}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ])));
        }),
      ),
    );
  }
}

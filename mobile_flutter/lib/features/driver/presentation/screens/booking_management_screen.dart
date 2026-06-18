import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';

class BookingManagementScreen extends ConsumerStatefulWidget {
  final String tripId;
  const BookingManagementScreen({super.key, required this.tripId});
  @override
  ConsumerState<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends ConsumerState<BookingManagementScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadBookings(); }

  Future<void> _loadBookings() async {
    final authState = ref.read(authStateProvider);
    if (authState.token == null) { setState(() => _isLoading = false); return; }
    try {
      final bookings = await ref.read(bookingRepositoryProvider).getTripBookings(authState.token!, widget.tripId);
      setState(() => _bookings = bookings);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error)); }
    finally { setState(() => _isLoading = false); }
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    final authState = ref.read(authStateProvider);
    if (authState.token == null) return;
    try {
      await ref.read(bookingRepositoryProvider).updateBookingStatus(authState.token!, bookingId, status);
      _loadBookings();
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error)); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des réservations')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _bookings.isEmpty ? const Center(child: Text('Aucune réservation pour ce trajet')) : ListView.builder(
        itemCount: _bookings.length, padding: const EdgeInsets.all(16), itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Réservation #${(booking['id'] ?? '').toString().substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              _StatusBadge(status: booking['status'] ?? ''),
            ]),
            const SizedBox(height: 8),
            Text('${booking['seats'] ?? 0} place(s) • ${booking['totalAmount'] ?? 0} FCFA'),
            const SizedBox(height: 12),
            if (booking['status'] == 'pending') Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => _updateStatus(booking['id'], 'rejected'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Refuser'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () => _updateStatus(booking['id'], 'accepted'), child: const Text('Accepter'))),
            ]),
          ])));
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color { switch (status) { case 'pending': return Colors.orange; case 'accepted': return AppColors.success; case 'rejected': return AppColors.error; case 'cancelled': return Colors.grey; default: return Colors.grey; } }
  String get _label { switch (status) { case 'pending': return 'En attente'; case 'accepted': return 'Confirmé'; case 'rejected': return 'Refusé'; case 'cancelled': return 'Annulé'; default: return status; } }

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(_label, style: TextStyle(color: _color, fontSize: 12)));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String tripId;
  const BookingScreen({super.key, required this.tripId});
  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _seats = 1;
  String _paymentMethod = 'cash';
  bool _isLoading = false;
  Map<String, dynamic>? _trip;

  @override
  void initState() { super.initState(); _loadTrip(); }

  Future<void> _loadTrip() async {
    try {
      final trip = await ref.read(tripRepositoryProvider).getTripById(widget.tripId);
      setState(() => _trip = trip);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error)); }
  }

  Future<void> _confirmBooking() async {
    final authState = ref.read(authStateProvider);
    if (authState.token == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez vous connecter'))); return; }
    setState(() => _isLoading = true);
    try {
      await ref.read(bookingRepositoryProvider).createBooking(authState.token!, widget.tripId, _seats, _paymentMethod);
      if (mounted) {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          title: const Text('Réservation confirmée!'),
          content: const Text('Votre réservation a été envoyée au conducteur.'),
          actions: [TextButton(onPressed: () { Navigator.pop(ctx); context.go('/history'); }, child: const Text('Voir mes réservations'))],
        ));
      }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error)); }
    finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_trip == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final total = (_trip!['pricePerSeat'] ?? 0) * _seats;

    return Scaffold(
      appBar: AppBar(title: const Text('Réservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Text('${_trip!['originCity']} → ${_trip!['destinationCity']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${_trip!['departureDate']} à ${_trip!['departureTime']}', style: TextStyle(color: AppColors.textSecondary)),
          ]))),
          const SizedBox(height: 24),
          Text('Nombre de places', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            IconButton(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove_circle_outline)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(8)), child: Text('$_seats', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            IconButton(onPressed: _seats < (_trip!['availableSeats'] ?? 1) ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add_circle_outline)),
            const Spacer(),
            Text('Max ${_trip!['availableSeats']}', style: TextStyle(color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 24),
          Text('Mode de paiement', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _PaymentOption(icon: Icons.money, title: 'Espèces', subtitle: 'Payer directement au conducteur', value: 'cash', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!)),
          _PaymentOption(icon: Icons.phone_android, title: 'Orange Money', subtitle: 'Payer avec Orange Money', value: 'orange_money', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!)),
          _PaymentOption(icon: Icons.wifi, title: 'Wave', subtitle: 'Payer avec Wave', value: 'wave', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!)),
          const SizedBox(height: 24),
          Card(color: AppColors.primary.withOpacity(0.1), child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total à payer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('$total FCFA', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ]))),
          const SizedBox(height: 100),
        ]),
      ),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: ElevatedButton(onPressed: _isLoading ? null : _confirmBooking, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirmer la réservation')))),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final String value; final String groupValue; final ValueChanged<String?> onChanged;
  const _PaymentOption({required this.icon, required this.title, required this.subtitle, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(child: RadioListTile<String>(value: value, groupValue: groupValue, onChanged: onChanged, title: Row(children: [
      Icon(icon, color: AppColors.primary), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))])),
    ])));
  }
}

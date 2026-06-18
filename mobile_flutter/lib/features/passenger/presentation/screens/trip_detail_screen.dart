import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});
  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  Map<String, dynamic>? _trip;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadTrip(); }

  Future<void> _loadTrip() async {
    try {
      final trip = await ref.read(tripRepositoryProvider).getTripById(widget.tripId);
      setState(() => _trip = trip);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error)); }
    finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_trip == null) return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Trajet non trouvé'), const SizedBox(height: 16), ElevatedButton(onPressed: () => context.pop(), child: const Text('Retour'))])));

    return Scaffold(
      appBar: AppBar(title: const Text('Détails du trajet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(children: [const Icon(Icons.trip_origin, color: AppColors.success, size: 20), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_trip!['originCity'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)), Text(_trip!['originAddress'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))]))]),
            const Padding(padding: EdgeInsets.only(left: 9), child: Icon(Icons.arrow_downward, color: AppColors.divider)),
            Row(children: [const Icon(Icons.location_on, color: AppColors.error, size: 20), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_trip!['destinationCity'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)), Text(_trip!['destinationAddress'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))]))]),
          ]))),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _DetailRow(icon: Icons.calendar_today, label: 'Date', value: '${_trip!['departureDate'] ?? ''}'),
            _DetailRow(icon: Icons.access_time, label: 'Départ', value: '${_trip!['departureTime'] ?? ''}'),
            _DetailRow(icon: Icons.event_seat, label: 'Places', value: '${_trip!['availableSeats'] ?? 0} / ${_trip!['totalSeats'] ?? 0}'),
            _DetailRow(icon: Icons.attach_money, label: 'Prix/place', value: '${_trip!['pricePerSeat'] ?? 0} FCFA', isHighlight: true),
          ]))),
          const SizedBox(height: 16),
          if (_trip!['vehicleInfo'] != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Véhicule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _DetailRow(icon: Icons.directions_car, label: '', value: '${_trip!['vehicleInfo']['brand']} ${_trip!['vehicleInfo']['model']}'),
            _DetailRow(icon: Icons.color_lens, label: '', value: '${_trip!['vehicleInfo']['color']}'),
            _DetailRow(icon: Icons.credit_card, label: 'Plaque', value: '${_trip!['vehicleInfo']['plateNumber']}'),
          ]))),
          const SizedBox(height: 100),
        ]),
      ),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: ElevatedButton(onPressed: () => context.push('/booking/${widget.tripId}'), child: const Text('Réserver ce trajet')))),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String label; final String value; final bool isHighlight;
  const _DetailRow({required this.icon, required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      Icon(icon, size: 20, color: isHighlight ? AppColors.primary : AppColors.textSecondary),
      if (label.isNotEmpty) ...[const SizedBox(width: 8), Text('$label: ', style: TextStyle(color: AppColors.textSecondary))],
      Expanded(child: Text(value, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal, color: isHighlight ? AppColors.primary : null))),
    ]));
  }
}

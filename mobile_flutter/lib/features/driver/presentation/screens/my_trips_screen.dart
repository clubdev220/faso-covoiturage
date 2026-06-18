import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});
  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  List<dynamic> _trips = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadTrips(); }

  Future<void> _loadTrips() async {
    final authState = ref.read(authStateProvider);
    if (authState.token == null) { setState(() => _isLoading = false); return; }
    try {
      final trips = await ref.read(tripRepositoryProvider).getMyTrips(authState.token!);
      setState(() => _trips = trips);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error)); }
    finally { setState(() => _isLoading = false); }
  }

  Color _statusColor(String? status) { switch (status) { case 'active': return AppColors.success; case 'cancelled': return AppColors.error; case 'completed': return AppColors.primary; default: return Colors.grey; } }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes trajets'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/publish-trip'))]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _trips.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.directions_car, size: 64, color: AppColors.textSecondary), const SizedBox(height: 16), const Text('Aucun trajet publié'), const SizedBox(height: 16), ElevatedButton.icon(onPressed: () => context.push('/publish-trip'), icon: const Icon(Icons.add), label: const Text('Publier un trajet'))])) : RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView.builder(itemCount: _trips.length, padding: const EdgeInsets.all(16), itemBuilder: (context, index) {
          final trip = _trips[index];
          return Card(child: InkWell(
            onTap: () => context.push('/trip/${trip['id']}/bookings'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text('${trip['originCity']} → ${trip['destinationCity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _statusColor(trip['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text((trip['status'] ?? 'active').toString().toUpperCase(), style: TextStyle(color: _statusColor(trip['status']), fontSize: 11, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 8),
              Text('${trip['departureDate']} à ${trip['departureTime']}', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.event_seat, size: 16, color: AppColors.textSecondary), const SizedBox(width: 4),
                Text('${trip['availableSeats']}/${trip['totalSeats']} places', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
                Text('${trip['pricePerSeat']} FCFA', style: TextStyle(color: AppColors.textSecondary)),
              ]),
            ])),
          ));
        }),
      ),
    );
  }
}

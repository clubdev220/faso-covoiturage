import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});
  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadUsers(); }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  Color _roleColor(String role) {
    switch (role) { case 'admin': return Colors.purple; case 'driver': return AppColors.primary; case 'passenger': return Colors.blue; case 'agent_relay': return Colors.orange; default: return Colors.grey; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des utilisateurs')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _users.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people, size: 64, color: AppColors.textSecondary), const SizedBox(height: 16), const Text('Aucun utilisateur trouvé'), const SizedBox(height: 16), ElevatedButton(onPressed: _loadUsers, child: const Text('Actualiser'))])) : RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView.builder(itemCount: _users.length, itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: _roleColor(user['role']).withOpacity(0.1), child: Icon(Icons.person, color: _roleColor(user['role']))),
              title: Text(user['displayName'] ?? 'Sans nom'),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user['phone'], style: const TextStyle(fontSize: 12)),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _roleColor(user['role']).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(user['role'], style: TextStyle(color: _roleColor(user['role']), fontSize: 10))),
                  const SizedBox(width: 8),
                  if ((user['rating'] ?? 0) > 0) ...[Icon(Icons.star, size: 12, color: Colors.amber), Text(' ${(user['rating'] as double).toStringAsFixed(1)}', style: const TextStyle(fontSize: 12))],
                ]),
              ]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        }),
      ),
    );
  }
}
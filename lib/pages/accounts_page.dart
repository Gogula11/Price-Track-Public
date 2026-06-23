import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:TrueTrack/pages/tracked_products_page.dart';
import 'package:TrueTrack/providers/auth_provider.dart';
import 'package:TrueTrack/services/service_registry.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final email = user?.email ?? 'Unknown User';
    final joinDate = user?.joinDate != null
        ? DateFormat('dd/MM/yyyy').format(user!.joinDate!)
        : '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.deepPurple),
                ],
              ),
              if (joinDate.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Joined $joinDate',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: context
                          .read<ServiceRegistry>()
                          .firestore
                          .getTrackedProductsStream(),
                      builder: (context, snapshot) {
                        final hasTrackedProducts =
                            snapshot.hasData && snapshot.data!.isNotEmpty;
                        return _MenuOption(
                          icon: Icons.local_offer,
                          title: 'Tracked Products',
                          trailing: hasTrackedProducts
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    'N',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TrackedProductsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    _MenuOption(
                      icon: Icons.lock,
                      title: 'Change Password',
                      onTap: () {},
                    ),
                    _MenuOption(
                      icon: Icons.logout,
                      title: 'Log Out',
                      onTap: () async {
                        await context.read<AuthProvider>().signOut();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    ),
                    _MenuOption(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      isLast: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuOption({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: Text(title),
          trailing:
              trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

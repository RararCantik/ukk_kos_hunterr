// lib/view/owner/profil_owner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_controller.dart';
import '../../models/user_model.dart';

class ProfilOwnerPage extends StatefulWidget {
  const ProfilOwnerPage({super.key});

  @override
  State<ProfilOwnerPage> createState() => _ProfilOwnerPageState();
}

class _ProfilOwnerPageState extends State<ProfilOwnerPage> {
  
  void _logout() {
    Provider.of<AuthController>(context, listen: false).logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Kita tonton (watch) AuthController
    final auth = Provider.of<AuthController>(context);
    final UserModel? user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Owner'),
        backgroundColor: Colors.indigo,
      ),
      body: user == null
          ? const Center(child: Text("Gagal memuat profil, silakan login ulang."))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 40),
                  const Text(
                    "Informasi Akun",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Nomor Telepon"),
                    subtitle: Text(user.phone ?? 'Belum diatur'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout", style: TextStyle(color: Colors.red)),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
    );
  }
}
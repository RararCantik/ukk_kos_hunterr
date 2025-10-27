import 'package:flutter/material.dart';

class HalamanPilihanRole extends StatelessWidget {
  const HalamanPilihanRole({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Role')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/society/beranda'),
              child: const Text('Masuk sebagai Society (Pencari Kos)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/owner/beranda'),
              child: const Text('Masuk sebagai Owner (Pengelola Kos)'),
            ),
          ],
        ),
      ),
    );
  }
}
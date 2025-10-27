// lib/view/society/beranda_society.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; 
import '../../controller/daftar_kost_controller.dart';
import '../../models/kost_composite_model.dart'; 

class KartuKostSociety extends StatelessWidget {
  final KostCompositeModel compositeKost; 
  const KartuKostSociety({super.key, required this.compositeKost});

  @override
  Widget build(BuildContext context) {
    final kost = compositeKost.kost; 
    final firstImage = compositeKost.firstImage; 

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: ListTile(
        leading: firstImage != null
            ? Image.file( 
                File(firstImage), 
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.home_work, size: 40, color: Colors.red),
              )
            : const Icon(Icons.home_work, size: 40),
        title: Text(kost.name),
        subtitle: Text("Rp${kost.pricePerMonth}/bulan\nGender: ${kost.gender ?? 'N/A'}"),
        isThreeLine: true,
        onTap: () {
          // Navigasi ke detail
          Navigator.pushNamed(context, '/society/detail_kost', arguments: kost.id);
        },
      ),
    );
  }
}


class BerandaSociety extends StatefulWidget {
  const BerandaSociety({super.key});
  @override
  State<BerandaSociety> createState() => _BerandaSocietyState();
}

class _BerandaSocietyState extends State<BerandaSociety> {
  String? selectedGender; 

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      Provider.of<DaftarKostController>(context, listen: false).fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<DaftarKostController>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kost (Lokal)'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              hint: const Text('Filter Gender'),
              initialValue: selectedGender,
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua')), 
                DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                DropdownMenuItem(value: 'all', child: Text('Campur')),
              ],
              onChanged: (v) {
                setState(() => selectedGender = v);
                // Panggil API lagi dengan filter baru
                ctrl.fetchAll(gender: v); 
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12)
              ),
            ),
          ),

          if (ctrl.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat data: ${ctrl.errorMessage}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: ctrl.loading
                ? const Center(child: CircularProgressIndicator())
                : ctrl.list.isEmpty
                    ? const Center(child: Text('Tidak ada kost ditemukan'))
                    : RefreshIndicator(
                        onRefresh: () => ctrl.fetchAll(gender: selectedGender),
                        child: ListView.builder(
                          itemCount: ctrl.list.length,
                          itemBuilder: (context, idx) {
                            return KartuKostSociety(compositeKost: ctrl.list[idx]); 
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kos_kos/controller/auth_controller.dart';
import 'package:kos_kos/controller/owner_kost_controller.dart';

class BerandaOwner extends StatefulWidget {
  const BerandaOwner({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _BerandaOwnerState createState() => _BerandaOwnerState();
}

class _BerandaOwnerState extends State<BerandaOwner> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadKost());
  }

  Future<void> _loadKost() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    if (auth.userId != null) {
      await Provider.of<OwnerKostController>(context, listen: false)
          .fetchOwnerKost(auth.userId!);
    }
  }

  void _showDeleteDialog(int kostId) {
    final ctrl = Provider.of<OwnerKostController>(context, listen: false);
    final auth = Provider.of<AuthController>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus kost ini? Semua data (termasuk foto, fasilitas, dan booking) akan hilang permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool sukses = await ctrl.deleteKost(kostId, auth.userId!);
              if (mounted && !sukses) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(ctrl.errorMessage ?? 'Gagal menghapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<OwnerKostController>(context);
    final auth = Provider.of<AuthController>(context, listen: false);

    if (auth.userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beranda Owner')),
        body: const Center(child: Text('Silakan login untuk mengelola kost.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kost Milik Saya'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKost,
          ),
        ],
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.errorMessage != null
              ? Center(child: Text('Error: ${ctrl.errorMessage}'))
              : ctrl.list.isEmpty
                  ? const Center(child: Text('Belum ada kost terdaftar'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: ctrl.list.length,
                      itemBuilder: (context, index) {
                        final composite = ctrl.list[index];
                        final kost = composite.kost;
                        final firstImage = composite.firstImage;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundImage: firstImage != null
                                  ? FileImage(File(firstImage))
                                  : null,
                              child: firstImage == null
                                  ? const Icon(Icons.home_work)
                                  : null,
                            ),
                            title: Text(
                              kost.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Rp ${kost.pricePerMonth}/bulan\n${kost.address ?? 'No Address'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(kost.id!),
                            ),
                            onTap: () {
                              // Navigasi ke ubah kost
                              Navigator.pushNamed(
                                context,
                                '/owner/ubah_kost',
                                arguments: composite, // Mengirim data composite
                              ).then((_) =>
                                  _loadKost()); // Refresh setelah kembali
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke tambah kost
          await Navigator.pushNamed(context, '/owner/tambah_kost');
          // Refresh data setelah kembali
          _loadKost();
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
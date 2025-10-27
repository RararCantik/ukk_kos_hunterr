import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_controller.dart';
import '../../controller/detail_kost_controller.dart';
import '../../models/kost_composite_model.dart';
import '../../models/review_composite_model.dart';

class DetailKostPage extends StatefulWidget {
  final int kostId;
  const DetailKostPage({super.key, required this.kostId});

  @override
  State<DetailKostPage> createState() => _DetailKostPageState();
}

class _DetailKostPageState extends State<DetailKostPage> {
  final _commentController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      Provider.of<DetailKostController>(context, listen: false)
          .fetchDetail(widget.kostId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose(); 
    super.dispose();
  }

  void _showPesanDialog(BuildContext context, int kostId) {
    final auth = Provider.of<AuthController>(context, listen: false);
    final ctrl = Provider.of<DetailKostController>(context, listen: false);

    if (auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk memesan.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pemesanan'),
        content: const Text('Apakah Anda yakin ingin memesan kost ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool sukses = await ctrl.pesanKost(kostId, auth.userId!);
              if (mounted) {
                if (sukses) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Pemesanan berhasil dikirim!')),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(ctrl.errorMessage ?? 'Gagal memesan')),
                  );
                }
              }
            },
            child: const Text('Ya, Pesan'),
          ),
        ],
      ),
    );
  }

  Future<void> _kirimKomentar() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final ctrl = Provider.of<DetailKostController>(context, listen: false);

    if (auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk berkomentar.')),
      );
      return;
    }

    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong.')),
      );
      return;
    }

    bool sukses = await ctrl.addReview(
      widget.kostId,
      auth.userId!,
      _commentController.text,
    );

    if (sukses) {
      _commentController.clear();
      // ignore: use_build_context_synchronously
      FocusScope.of(context).unfocus(); // Tutup keyboard
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ctrl.errorMessage ?? 'Gagal mengirim komentar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<DetailKostController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kost'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ctrl.loading && ctrl.kostComposite == null 
          ? const Center(child: CircularProgressIndicator())
          : ctrl.errorMessage != null && ctrl.kostComposite == null 
              ? Center(child: Text('Error: ${ctrl.errorMessage}'))
              : ctrl.kostComposite == null
                  ? const Center(child: Text('Data kost tidak ditemukan'))
                  : _buildBody(context, ctrl),
    );
  }

  Widget _buildBody(BuildContext context, DetailKostController ctrl) {
    final KostCompositeModel composite = ctrl.kostComposite!;
    final kost = composite.kost;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO KOST
          _buildImageSlider(composite),

          // INFORMASI KOST
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kost.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  kost.address ?? 'Alamat tidak tersedia',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Harga: Rp${kost.pricePerMonth}/bulan",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Gender: ${kost.gender ?? 'N/A'}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Fasilitas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (composite.facilities.isEmpty)
                  const Text("Tidak ada data fasilitas"),
                ...composite.facilities.map((f) => Text("• ${f.facility}")),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showPesanDialog(context, kost.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text(
                    "Pesan Kost",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Komentar & Ulasan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Form Tambah Komentar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar Anda...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) => _kirimKomentar(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tampilkan loading kecil saat mengirim
                    ctrl.loading 
                        ? const CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.blueAccent),
                            onPressed: _kirimKomentar,
                          ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Daftar Komentar
                if (ctrl.reviews.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Belum ada ulasan'),
                  )),
                ...ctrl.reviews.map((ReviewCompositeModel review) => ListTile(
                      leading: const Icon(Icons.person_pin),
                      title: Text(review.userName),
                      subtitle: Text(review.comment),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(KostCompositeModel composite) {
    if (composite.images.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey[300],
        child:
            const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }

    // Tampilkan gambar pertama
    // Untuk slider, Anda perlu PageView.builder
    final imagePath = composite.images.first.file;
    return Image.file(
      File(imagePath),
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 220,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50, color: Colors.red),
        );
      },
    );
  }
}
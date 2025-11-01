import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_controller.dart';
import '../../controller/detail_kost_controller.dart';
import '../../controller/owner_kost_controller.dart';
import '../../models/kost_composite_model.dart';

class UbahKostPage extends StatefulWidget {
  final KostCompositeModel kostComposite;
  const UbahKostPage({super.key, required this.kostComposite});

  @override
  State<UbahKostPage> createState() => _UbahKostPageState();
}

class _UbahKostPageState extends State<UbahKostPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();

  String _selectedGender = 'all';
  // Simpan path gambar. Bisa path file lokal (baru) atau path lama
  List<String> _imagePaths = [];
  List<String> _facilities = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Isi form dengan data yang ada
    final kost = widget.kostComposite.kost;
    _namaCtrl.text = kost.name;
    _alamatCtrl.text = kost.address ?? '';
    _hargaCtrl.text = kost.pricePerMonth.toString();
    _selectedGender = kost.gender ?? 'all';
    _imagePaths = widget.kostComposite.images.map((img) => img.file).toList();
    _facilities = widget.kostComposite.facilities.map((fac) => fac.facility).toList();

    // Ambil data review
    Future.microtask(() {
      Provider.of<DetailKostController>(context, listen: false)
          .fetchDetail(widget.kostComposite.kost.id!);
    });
  }

  Future<void> _pickImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _imagePaths.addAll(pickedFiles.map((xfile) => xfile.path));
    });
  }

  void _addFacility() {
    if (_facilityCtrl.text.isNotEmpty) {
      setState(() {
        _facilities.add(_facilityCtrl.text);
        _facilityCtrl.clear();
      });
    }
  }

  Future<void> _saveKost() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = Provider.of<AuthController>(context, listen: false);
    if (auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Owner ID tidak ditemukan!')),
      );
      return;
    }

    final ctrl = Provider.of<OwnerKostController>(context, listen: false);

    bool sukses = await ctrl.saveKost(
      kostId: widget.kostComposite.kost.id, 
      ownerId: auth.userId!,
      name: _namaCtrl.text,
      address: _alamatCtrl.text,
      price: int.parse(_hargaCtrl.text),
      gender: _selectedGender,
      facilities: _facilities,
      imagePaths: _imagePaths, 
    );

    if (mounted) {
      if (sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kost berhasil diperbarui!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ctrl.errorMessage ?? 'Gagal memperbarui')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<OwnerKostController>(context);
    final detailCtrl = Provider.of<DetailKostController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Data Kost'),
        backgroundColor: Colors.indigo,
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- FOTO ---
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  
                  // --- INPUT ---
                  TextFormField(
                    controller: _namaCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Kost', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alamatCtrl,
                    decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                    maxLines: 2,
                    validator: (v) => v!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaCtrl,
                    decoration: const InputDecoration(labelText: 'Harga per Bulan', border: OutlineInputBorder(), prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Harga tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                      DropdownMenuItem(value: 'all', child: Text('Campur')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedGender = v);
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- FASILITAS ---
                  const Text('Fasilitas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _facilities.map((f) => Chip(
                      label: Text(f),
                      onDeleted: () => setState(() => _facilities.remove(f)),
                    )).toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _facilityCtrl,
                          decoration: const InputDecoration(hintText: 'Cth: WiFi'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addFacility,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveKost,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
                  ),

                  // review kost
                  const Divider(height: 40, thickness: 1),
                  const Text('Ulasan & Komentar',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildReviewList(detailCtrl),

                ],
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Kost', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imagePaths.isEmpty
              ? InkWell(
                  onTap: _pickImage,
                  child: const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey)),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    final path = _imagePaths[index];
                    final imageProvider = FileImage(File(path));
                    
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          Image(
                            image: imageProvider,
                            width: 100,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40, color: Colors.red),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => setState(() => _imagePaths.removeAt(index)),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Tambah Foto'),
        ),
      ],
    );
  }

  // review
  Widget _buildReviewList(DetailKostController ctrl) {
    if (ctrl.loading && ctrl.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.reviews.isEmpty) {
      return const Center(child: Text('Belum ada ulasan.'));
    }

    return ListView.builder(
      shrinkWrap: true, // Penting di dalam ListView lain
      physics: const NeverScrollableScrollPhysics(), // Penting
      itemCount: ctrl.reviews.length,
      itemBuilder: (context, index) {
        final review = ctrl.reviews[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_pin),
                  title: Text(review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(review.comment),
                  contentPadding: EdgeInsets.zero,
                ),
                if (review.ownerReply != null && review.ownerReply!.isNotEmpty)
                  // Tampilkan balasan yang sudah ada
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, top: 8.0, bottom: 8.0, right: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Balasan Anda:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(review.ownerReply!),
                        ],
                      ),
                    ),
                  ),

                // Tombol Balas (jika belum dibalas)
                if (review.ownerReply == null || review.ownerReply!.isEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showReplyDialog(ctrl, review.id),
                      child: const Text('Balas Komentar'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DIALOG UNTUK MENGISI BALASAN ---
  void _showReplyDialog(DetailKostController ctrl, int reviewId) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Beri Balasan'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'Tulis balasan Anda...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.isEmpty) return;

              // Panggil controller
              await ctrl.addOwnerReply(
                  reviewId,
                  replyController.text,
                  widget.kostComposite.kost
                      .id! // Kirim kostId untuk refresh
                  );

              // ignore: use_build_context_synchronously
              Navigator.pop(ctx); // Tutup dialog
            },
            child: const Text('Kirim Balasan'),
          ),
        ],
      ),
    );
  }
}
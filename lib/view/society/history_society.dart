// lib/view/society/history_society.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_controller.dart';
import '../../controller/booking_controller.dart';
import '../../models/booking_composite_model.dart';

class HistoriSocietyPage extends StatefulWidget {
  const HistoriSocietyPage({super.key});

  @override
  State<HistoriSocietyPage> createState() => _HistoriSocietyPageState();
}

class _HistoriSocietyPageState extends State<HistoriSocietyPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      final auth = Provider.of<AuthController>(context, listen: false);
      if (auth.userId != null) {
        // ignore: use_build_context_synchronously
        Provider.of<BookingController>(context, listen: false)
            .fetchSocietyHistory(auth.userId!);
      }
    });
  }

  Future<void> _refreshHistori() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    if (auth.userId != null) {
      await Provider.of<BookingController>(context, listen: false)
          .fetchSocietyHistory(auth.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<BookingController>(context);
    final auth = Provider.of<AuthController>(context, listen: false);

    if (auth.userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Histori Pemesanan')),
        body: const Center(child: Text('Silakan login untuk melihat histori.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori Pemesanan Kost'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.errorMessage != null
              ? Center(child: Text('Error: ${ctrl.errorMessage}'))
              : ctrl.list.isEmpty
                  ? const Center(child: Text('Belum ada histori pemesanan'))
                  : RefreshIndicator(
                      onRefresh: _refreshHistori,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: ctrl.list.length,
                        itemBuilder: (context, index) {
                          final BookingCompositeModel data = ctrl.list[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.home, color: Colors.blue),
                              title: Text(
                                data.kosName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tanggal Pesan: ${data.startDate.substring(0, 10)}"),
                                  Text("Status: ${data.status}",
                                      style: TextStyle(
                                        color: data.status == 'accept'
                                            ? Colors.green
                                            : data.status == 'reject'
                                                ? Colors.red
                                                : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.receipt_long,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  _showNotaDialog(context, data);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showNotaDialog(BuildContext context, BookingCompositeModel data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Bukti Pemesanan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID Pemesanan: ${data.id}"),
            Text("Nama Kost: ${data.kosName}"),
            Text("Tanggal: ${data.startDate.substring(0, 10)}"),
            Text("Status: ${data.status}", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: data.status == 'accept' ? Colors.green : (data.status == 'reject' ? Colors.red : Colors.orange),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
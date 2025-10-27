// lib/view/owner/laporan_owner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_controller.dart';
import '../../controller/booking_controller.dart';
import '../../models/booking_composite_model.dart';

class LaporanOwner extends StatefulWidget {
  const LaporanOwner({super.key});

  @override
  State<LaporanOwner> createState() => _LaporanOwnerState();
}

class _LaporanOwnerState extends State<LaporanOwner> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchLaporan());
  }

  Future<void> _fetchLaporan() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    if (auth.userId != null) {
      await Provider.of<BookingController>(context, listen: false)
          .fetchOwnerLaporan(auth.userId!);
    }
  }

  void _updateStatus(BookingCompositeModel booking, String status) {
    final auth = Provider.of<AuthController>(context, listen: false);
    final ctrl = Provider.of<BookingController>(context, listen: false);
    
    ctrl.updateBookingStatus(booking.id, status, ownerId: auth.userId!);
  }

  Widget _buildActionButton(BookingCompositeModel booking) {
    if (booking.status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _updateStatus(booking, 'accept'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _updateStatus(booking, 'reject'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      );
    } else {
      return Text(
        booking.status.toUpperCase(),
        style: TextStyle(
          color: booking.status == 'accept' ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<BookingController>(context);
    final auth = Provider.of<AuthController>(context, listen: false);
    
    if (auth.userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Laporan Pemesanan')),
        body: const Center(child: Text('Silakan login untuk melihat laporan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pemesanan'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.errorMessage != null
              ? Center(child: Text('Error: ${ctrl.errorMessage}'))
              : ctrl.list.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada laporan tersedia',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchLaporan,
                      child: ListView.builder(
                        itemCount: ctrl.list.length,
                        itemBuilder: (context, index) {
                          final data = ctrl.list[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(data.userName ?? 'Nama User Error'),
                              subtitle: Text("Kost: ${data.kosName}\nTanggal: ${data.startDate.substring(0, 10)}"),
                              trailing: _buildActionButton(data),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
// lib/controller/booking_controller.dart
import 'package:flutter/material.dart';
import 'package:kos_kos/models/booking_composite_model.dart';
import 'package:kos_kos/services/database_helper.dart';

class BookingController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _loading = false;
  String? _errorMessage;
  List<BookingCompositeModel> _list = [];
  
  // Simpan filter terakhir
  String? _lastStartDate;
  String? _lastEndDate;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<BookingCompositeModel> get list => _list;

  // Untuk Halaman Society
  Future<void> fetchSocietyHistory(int userId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final maps = await _dbHelper.getCompositeBookingsForUser(userId);
      _list = maps.map((map) => BookingCompositeModel.fromMap(map)).toList();
    } catch (e) {
      _setErrorMessage(e.toString());
      _list = [];
    } finally {
      _setLoading(false);
    }
  }

  // Untuk Halaman Owner (DENGAN FILTER)
  Future<void> fetchOwnerLaporan(
    int ownerId, {
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    
    // Simpan filter
    _lastStartDate = startDate;
    _lastEndDate = endDate;
    
    try {
      final maps = await _dbHelper.getCompositeBookingsForOwner(
        ownerId,
        startDate: startDate,
        endDate: endDate,
      );
      _list = maps.map((map) => BookingCompositeModel.fromMap(map)).toList();
    } catch (e) {
      _setErrorMessage(e.toString());
      _list = [];
    } finally {
      _setLoading(false);
    }
  }

  // Untuk Owner update status
  Future<bool> updateBookingStatus(int bookingId, String newStatus, {required int ownerId}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _dbHelper.updateBookingStatus(bookingId, newStatus);
      // Refresh list laporan (gunakan filter terakhir)
      await fetchOwnerLaporan(
        ownerId,
        startDate: _lastStartDate,
        endDate: _lastEndDate,
      );
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void _setErrorMessage(String? val) {
    _errorMessage = val;
    notifyListeners();
  }
}
// lib/controller/owner_kost_controller.dart
import 'package:flutter/material.dart';
import 'package:kos_kos/models/kost_composite_model.dart';
import 'package:kos_kos/models/kost_facility_model.dart';
import 'package:kos_kos/models/kost_image_model.dart';
import 'package:kos_kos/models/kost_model.dart';
import 'package:kos_kos/services/database_helper.dart';

class OwnerKostController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _loading = false;
  String? _errorMessage;
  List<KostCompositeModel> _list = [];

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<KostCompositeModel> get list => _list;

  Future<void> fetchOwnerKost(int ownerId) async {
    _setLoading(true);
    _setErrorMessage(null);
    List<KostCompositeModel> compositeList = [];

    try {
      final List<Map<String, dynamic>> kosMaps =
          await _dbHelper.getKosByOwner(ownerId);
      final List<KostModel> kostList =
          kosMaps.map((map) => KostModel.fromMap(map)).toList();

      for (var kost in kostList) {
        final imageMaps = await _dbHelper.getImagesForKos(kost.id!);
        final images =
            imageMaps.map((map) => KostImageModel.fromMap(map)).toList();

        final facilityMaps = await _dbHelper.getFacilitiesForKos(kost.id!);
        final facilities =
            facilityMaps.map((map) => KostFacilityModel.fromMap(map)).toList();

        compositeList.add(KostCompositeModel(
          kost: kost,
          images: images,
          facilities: facilities,
        ));
      }

      _list = compositeList;
    } catch (e) {
      _setErrorMessage(e.toString());
      _list = [];
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi untuk tambah dan ubah kost
  Future<bool> saveKost({
    int? kostId, // Jika null, berarti 'tambah'. Jika ada, 'ubah'.
    required int ownerId,
    required String name,
    required String address,
    required int price,
    required String gender,
    required List<String> facilities, 
    required List<String> imagePaths, 
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    final kosData = {
      'user_id': ownerId,
      'name': name,
      'address': address,
      'price_per_month': price,
      'gender': gender,
    };

    try {
      if (kostId == null) {
        // --- BUAT KOST BARU ---
        final newId = await _dbHelper.createKos(kosData);
        // Tambah gambar
        for (var path in imagePaths) {
          await _dbHelper.addKosImage({'kos_id': newId, 'file': path});
        }
        // Tambah fasilitas
        for (var facility in facilities) {
          await _dbHelper
              .addKosFacility({'kos_id': newId, 'facility': facility});
        }
      } else {
        await _dbHelper.updateKos(kostId, kosData);

        await _dbHelper.deleteImagesForKos(kostId);
        await _dbHelper.deleteFacilitiesForKos(kostId);

        for (var path in imagePaths) {
          await _dbHelper.addKosImage({'kos_id': kostId, 'file': path});
        }
        for (var facility in facilities) {
          await _dbHelper
              .addKosFacility({'kos_id': kostId, 'facility': facility});
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteKost(int kostId, int ownerId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _dbHelper.deleteKos(kostId);

      await fetchOwnerKost(ownerId);
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
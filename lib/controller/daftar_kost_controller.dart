// lib/controller/daftar_kost_controller.dart
import 'package:flutter/material.dart';

import '../models/kost_composite_model.dart';
import '../models/kost_facility_model.dart';
import '../models/kost_image_model.dart';
import '../models/kost_model.dart';
import '../services/database_helper.dart';

class DaftarKostController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper(); 

  bool _loading = false;
  String? _errorMessage;
  List<KostCompositeModel> _list = []; 

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<KostCompositeModel> get list => _list;

  Future<void> fetchAll({String? gender}) async {
    _setLoading(true);
    _setErrorMessage(null);
    
    List<KostCompositeModel> compositeList = [];

    try {
      final List<Map<String, dynamic>> kosMaps = await _dbHelper.getAllKos(gender: gender);
      final List<KostModel> kostList = kosMaps.map((map) => KostModel.fromMap(map)).toList();

      for (var kost in kostList) {
        // Ambil gambar
        final imageMaps = await _dbHelper.getImagesForKos(kost.id!);
        final images = imageMaps.map((map) => KostImageModel.fromMap(map)).toList();
        
        // Ambil fasilitas
        final facilityMaps = await _dbHelper.getFacilitiesForKos(kost.id!);
        final facilities = facilityMaps.map((map) => KostFacilityModel.fromMap(map)).toList();
        
        compositeList.add(KostCompositeModel(
          kost: kost,
          images: images,
          facilities: facilities,
        ));
      }
      
      _list = compositeList; // Set list akhir

    } catch (e) {
      _setErrorMessage(e.toString());
      _list = []; 
    } finally {
      _setLoading(false);
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
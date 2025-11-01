import 'package:flutter/material.dart';
import 'package:kos_kos/models/kost_composite_model.dart';
import 'package:kos_kos/models/kost_facility_model.dart';
import 'package:kos_kos/models/kost_image_model.dart';
import 'package:kos_kos/models/kost_model.dart';
import 'package:kos_kos/models/review_composite_model.dart';
import 'package:kos_kos/services/database_helper.dart';

class DetailKostController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _loading = false;
  String? _errorMessage;
  KostCompositeModel? _kostComposite;
  List<ReviewCompositeModel> _reviews = [];

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  KostCompositeModel? get kostComposite => _kostComposite;
  List<ReviewCompositeModel> get reviews => _reviews;

  Future<void> fetchDetail(int kostId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final kosMap = await _dbHelper.getKos(kostId); //
      if (kosMap == null) {
        throw Exception('Kost dengan ID $kostId tidak ditemukan.');
      }
      final kost = KostModel.fromMap(kosMap); 

      final imageMaps = await _dbHelper.getImagesForKos(kostId); 
      final images = imageMaps.map((map) => KostImageModel.fromMap(map)).toList(); 

      final facilityMaps = await _dbHelper.getFacilitiesForKos(kostId); //
      final facilities = facilityMaps.map((map) => KostFacilityModel.fromMap(map)).toList(); //

      _kostComposite = KostCompositeModel( //
        kost: kost,
        images: images,
        facilities: facilities,
      );

      await _fetchReviews(kostId); 

    } catch (e) {
      _setErrorMessage(e.toString());
      _kostComposite = null;
      _reviews = [];
    } finally {
      _setLoading(false);
    }
  }

  // --- FUNGSI UNTUK MENGAMBIL REVIEW SECARA TERPISAH ---
  Future<void> _fetchReviews(int kostId) async {
    final reviewMaps = await _dbHelper.getCompositeReviewsForKos(kostId); //
    _reviews = reviewMaps.map((map) => ReviewCompositeModel.fromMap(map)).toList(); //
    notifyListeners(); 
  }

  Future<bool> pesanKost(int kostId, int userId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _dbHelper.createBooking({ //
        'kos_id': kostId,
        'user_id': userId,
        'start_date': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addReview(int kostId, int userId, String comment) async {
    // Kita set loading=true agar di UI tombol send berubah jadi spinner
    _setLoading(true); 
    _setErrorMessage(null);
    
    try {
      await _dbHelper.addReview({ //
        'kos_id': kostId,
        'user_id': userId,
        'comment': comment,
      });

      // Jika sukses, panggil ulang _fetchReviews
      await _fetchReviews(kostId); 
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- FUNGSI BALASAN OWNER ---
  Future<bool> addOwnerReply(int reviewId, String reply, int kostId) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      await _dbHelper.updateOwnerReply(reviewId, reply);

      // Jika sukses, panggil ulang _fetchReviews agar UI terupdate
      await _fetchReviews(kostId);

      _setLoading(false);
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
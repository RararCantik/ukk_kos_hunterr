import 'kost_facility_model.dart';
import 'kost_image_model.dart';
import 'kost_model.dart';

class KostCompositeModel {
  final KostModel kost;
  final List<KostImageModel> images;
  final List<KostFacilityModel> facilities;

  KostCompositeModel({
    required this.kost,
    required this.images,
    required this.facilities,
  });

  
  String? get firstImage {
    if (images.isNotEmpty) {
      return images.first.file;
    }
    return null; 
  }
}
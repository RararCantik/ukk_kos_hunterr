class KostFacilityModel {
  final int? id;
  final int kosId;
  final String facility;

  KostFacilityModel({
    this.id,
    required this.kosId,
    required this.facility,
  });

  factory KostFacilityModel.fromMap(Map<String, dynamic> map) {
    return KostFacilityModel(
      id: map['id'],
      kosId: map['kos_id'],
      facility: map['facility'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kos_id': kosId,
      'facility': facility,
    };
  }
}
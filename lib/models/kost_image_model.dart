class KostImageModel {
  final int? id;
  final int kosId;
  final String file; 

  KostImageModel({
    this.id,
    required this.kosId,
    required this.file,
  });

  factory KostImageModel.fromMap(Map<String, dynamic> map) {
    return KostImageModel(
      id: map['id'],
      kosId: map['kos_id'],
      file: map['file'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kos_id': kosId,
      'file': file,
    };
  }
}
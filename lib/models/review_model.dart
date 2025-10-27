class ReviewModel {
  final int? id;
  final int kosId;
  final int userId;
  final String? comment;

  ReviewModel({
    this.id,
    required this.kosId,
    required this.userId,
    this.comment,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'],
      kosId: map['kos_id'],
      userId: map['user_id'],
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kos_id': kosId,
      'user_id': userId,
      'comment': comment,
    };
  }
}
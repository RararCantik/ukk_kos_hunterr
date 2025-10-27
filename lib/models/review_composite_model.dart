class ReviewCompositeModel {
  final int id;
  final String comment;
  final String userName; 
  final String? ownerReply;

  ReviewCompositeModel({
    required this.id,
    required this.comment,
    required this.userName,
    this.ownerReply, 
  });
  
  factory ReviewCompositeModel.fromMap(Map<String, dynamic> map) {
    return ReviewCompositeModel(
      id: map['id'],
      comment: map['comment'] ?? 'Tidak ada komentar',
      userName: map['user_name'] ?? 'User Anonim',
      ownerReply: map['owner_reply'], 
    );
  }
}
class BookingModel {
  final int? id;
  final int kosId;
  final int userId;
  final String startDate; 
  final String? endDate;
  final String status; 

  BookingModel({
    this.id,
    required this.kosId,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.status = 'pending',
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      kosId: map['kos_id'],
      userId: map['userId'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kos_id': kosId,
      'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    };
  }
}
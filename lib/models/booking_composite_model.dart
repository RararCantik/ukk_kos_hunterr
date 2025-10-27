class BookingCompositeModel {
  final int id;
  final int kosId;
  final int userId;
  final String startDate;
  final String status;
  
  // Data gabungan
  final String kosName;
  final String? userName; 

  BookingCompositeModel({
    required this.id,
    required this.kosId,
    required this.userId,
    required this.startDate,
    required this.status,
    required this.kosName,
    this.userName,
  });
  
  factory BookingCompositeModel.fromMap(Map<String, dynamic> map) {
    return BookingCompositeModel(
      id: map['id'],
      kosId: map['kos_id'],
      userId: map['user_id'],
      startDate: map['start_date'],
      status: map['status'],
      kosName: map['kos_name'] ?? 'Nama Kos Tidak Ditemukan',
      userName: map['user_name'],
    );
  }
}
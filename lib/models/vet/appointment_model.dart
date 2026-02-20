class AppointmentModel {
  final String vetName;
  final String specialization;
  final DateTime date;
  final String time;
  final String address;
  final bool isUpcoming;

  const AppointmentModel({
    required this.vetName,
    required this.specialization,
    required this.date,
    required this.time,
    required this.address,
    required this.isUpcoming,
  });
}
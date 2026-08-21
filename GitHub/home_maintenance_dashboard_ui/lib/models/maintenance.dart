class Maintenance {
  final String title;
  final String location;
  final String date;
  final String cost;
  final String type;
  final bool urgent;

  const Maintenance({
    required this.title,
    required this.location,
    required this.date,
    required this.cost,
    required this.type,
    this.urgent = false,
  });
}
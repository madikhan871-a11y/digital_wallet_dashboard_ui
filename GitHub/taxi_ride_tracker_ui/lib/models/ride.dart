class Ride {
  final String driverName;
  final String carName;
  final String carNumber;
  final String pickup;
  final String destination;
  final String eta;
  final String fare;
  final double progress;

  const Ride({
    required this.driverName,
    required this.carName,
    required this.carNumber,
    required this.pickup,
    required this.destination,
    required this.eta,
    required this.fare,
    required this.progress,
  });
}
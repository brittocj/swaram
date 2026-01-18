class NoiseSession {
  final int? id;
  final double averageDb;
  final double peakDb;
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  NoiseSession({
    this.id,
    required this.averageDb,
    required this.peakDb,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'averageDb': averageDb,
      'peakDb': peakDb,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory NoiseSession.fromMap(Map<String, dynamic> map) {
    return NoiseSession(
      id: map['id'],
      averageDb: map['averageDb'],
      peakDb: map['peakDb'],
      timestamp: DateTime.parse(map['timestamp']),
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

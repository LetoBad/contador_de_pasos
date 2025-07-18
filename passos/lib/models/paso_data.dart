class PasoData {
  final int totalSteps;
  final DateTime date;
  final String source;

  PasoData({
    required this.totalSteps,
    required this.date,
    required this.source,
  });

  factory PasoData.fromJson(Map<String, dynamic> json) {
    return PasoData(
      totalSteps: json['totalSteps'] ?? 0,
      date: DateTime.parse(json['date']),
      source: json['source'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'date': date.toIso8601String(),
      'source': source,
    };
  }
}

class PasoDiaData {
  final int totalSteps;
  final DateTime date;

  PasoDiaData({required this.totalSteps, required this.date});
}

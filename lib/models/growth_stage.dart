class GrowthStage {
  final String name;
  final int startDay;
  final int endDay;

  const GrowthStage({
    required this.name,
    required this.startDay,
    required this.endDay,
  });
}

class GrowthStageCalculator {
  GrowthStageCalculator._();

  static const List<GrowthStage> riceStages = [
    GrowthStage(name: '이앙기', startDay: 0, endDay: 7),
    GrowthStage(name: '분얼기', startDay: 8, endDay: 45),
    GrowthStage(name: '유수형성기', startDay: 46, endDay: 65),
    GrowthStage(name: '수잉기', startDay: 66, endDay: 80),
    GrowthStage(name: '출수기', startDay: 81, endDay: 95),
    GrowthStage(name: '등숙기', startDay: 96, endDay: 140),
  ];

  static int activeIndex(DateTime transplantDate, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final base = DateTime(transplantDate.year, transplantDate.month, transplantDate.day);
    final ref = DateTime(today.year, today.month, today.day);
    final days = ref.difference(base).inDays;
    if (days < 0) return 0;
    for (var i = 0; i < riceStages.length; i++) {
      if (days <= riceStages[i].endDay) return i;
    }
    return riceStages.length - 1;
  }

  static (DateTime, DateTime) rangeOf(DateTime transplantDate, int index) {
    final stage = riceStages[index];
    final start = transplantDate.add(Duration(days: stage.startDay));
    final end = transplantDate.add(Duration(days: stage.endDay));
    return (start, end);
  }
}

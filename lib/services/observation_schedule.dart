/// 예찰(현장 피해 면적율 측정) 일정 및 평년 베이스라인 헬퍼.
///
/// 예찰 일정: 6월~9월의 매월 1일·16일.
/// 평년 베이스라인(`baselineDamageRate`)은 임시 상수이며, 추후 작물·생육
/// 단계·지역별 통계로 교체될 수 있다.
class ObservationSchedule {
  ObservationSchedule._();

  /// 평년(다년 평균) 피해 면적율 — 비율(0~1). 지금은 단일 상수.
  static const double baselineDamageRate = 0.102; // 10.2%

  /// 주어진 날짜가 현장 예찰일(6-9월 1·16일)인지 여부.
  static bool isObservationDay(DateTime date) {
    if (date.month < 6 || date.month > 9) return false;
    return date.day == 1 || date.day == 16;
  }
}

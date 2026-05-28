import '../theme/risk_palette.dart';

/// 풍속 + 강수로 결정되는 살포 가능 조건.
///
/// - [goodVentilation] : 풍속 2~5 m/s 이며 강수 없음
/// - [poorVentilation] : 풍속 <2 m/s 이며 강수 없음 (살포는 가능하나 통풍 개선 필요)
/// - [impossible]      : 풍속 >5 m/s 또는 강수 중
enum SprayCondition { goodVentilation, poorVentilation, impossible }

extension SprayConditionX on SprayCondition {
  String get label {
    switch (this) {
      case SprayCondition.goodVentilation:
        return '살포 가능';
      case SprayCondition.poorVentilation:
        return '살포 가능';
      case SprayCondition.impossible:
        return '살포 불가';
    }
  }

  String get badgeText {
    switch (this) {
      case SprayCondition.goodVentilation:
        return '살포 가능';
      case SprayCondition.poorVentilation:
        return '살포 가능 (통풍 개선 필요)';
      case SprayCondition.impossible:
        return '살포 불가';
    }
  }
}

/// 풍속(m/s)과 24h 강수량(mm)을 기준으로 살포 조건을 분류한다.
SprayCondition classifySprayCondition({
  required double? windMs,
  required double? rainMm,
}) {
  final rain = rainMm ?? 0;
  final wind = windMs ?? 0;
  if (rain > 0 || wind > 5) return SprayCondition.impossible;
  if (wind < 2) return SprayCondition.poorVentilation;
  return SprayCondition.goodVentilation;
}

/// 위험 등급 × 살포 조건으로 결정되는 9개 시나리오 (A~I).
enum SprayScenario {
  a, b, c, // 심각 + good/poor/impossible
  d, e, f, // 경계
  g, h, i, // 주의
}

extension SprayScenarioX on SprayScenario {
  String get letter => 'ABCDEFGHI'[index];
}

SprayScenario resolveScenario(RiskGrade grade, SprayCondition cond) {
  // 안전 → 주의 등급과 동일하게 취급
  final row = switch (grade) {
    RiskGrade.severe => 0,
    RiskGrade.alert => 1,
    RiskGrade.caution => 2,
    RiskGrade.safe => 2,
  };
  final col = switch (cond) {
    SprayCondition.goodVentilation => 0,
    SprayCondition.poorVentilation => 1,
    SprayCondition.impossible => 2,
  };
  return SprayScenario.values[row * 3 + col];
}

// -- 약제 ---------------------------------------------------------------------

/// 약제 제형
enum DrugFormulation {
  suspension('액상수화제'),
  wettable('수화제'),
  emulsifiable('유제'),
  liquid('액제'),
  granule('입제');

  const DrugFormulation(this.label);
  final String label;
}

class Drug {
  final String id;
  final String brand; // 대표상표명
  final String maker;
  final String ingredient;
  final DrugFormulation formulation;
  final String dilution; // 1,000배 / 2,000배 / 직접 살포
  final String safetyTimeLabel; // "수확 21일전", "이앙기", "발생 초기까지"
  final int? safetyDaysBeforeHarvest; // 14 / 21 / 30 / null(=무관)
  final String safetyCountLabel; // "3회", "회수 제한 없음"
  final int? safetyCountMax; // 3 / null(=무제한)
  final bool eco;
  final String characteristic; // 특징
  final bool weatherIndependent; // 입제(강수/풍속 무관)
  final List<String> sameSeriesBrands;

  const Drug({
    required this.id,
    required this.brand,
    required this.maker,
    required this.ingredient,
    required this.formulation,
    required this.dilution,
    required this.safetyTimeLabel,
    required this.safetyDaysBeforeHarvest,
    required this.safetyCountLabel,
    required this.safetyCountMax,
    required this.eco,
    required this.characteristic,
    required this.weatherIndependent,
    this.sameSeriesBrands = const [],
  });
}

// -- 비약제 -------------------------------------------------------------------

class NonDrugMethod {
  final String id;
  final String name;
  final String description; // 앱 표시 멘트
  final String urgency; // 즉시 / 상시 / 발견 즉시 등
  const NonDrugMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.urgency,
  });
}

// -- 체크리스트 ----------------------------------------------------------------

enum EcoPreference {
  certified('네, 친환경·유기농 인증 농가입니다',
      '친환경 인증 농가는 사용 가능한 약제가 제한돼요'),
  preferEco('인증은 없지만 친환경 농법을 선호합니다', ''),
  effectFirst('아니요, 효과 우선입니다', '');

  const EcoPreference(this.label, this.hint);
  final String label;
  final String hint;
}

enum DiseaseSpread {
  early('잎집 아래쪽에 일부 무늬가 보입니다', '초기'),
  spreading('위쪽 잎까지 번지고 있습니다', '확산 중'),
  late('줄기·이삭까지 침범했습니다', '말기');

  const DiseaseSpread(this.label, this.tag);
  final String label;
  final String tag;
}

enum SprayCount {
  zero('0회 (이번이 처음)', 0),
  one('1회', 1),
  two('2회', 2),
  threeOrMore('3회 이상', 3);

  const SprayCount(this.label, this.value);
  final String label;
  final int value;
}

enum SprayEquipment {
  drone('드론', '광역·빠름'),
  ground('광역살포기 (지상)', '정밀·표준'),
  manual('배부식 분무기 (수동)', '소규모');

  const SprayEquipment(this.label, this.hint);
  final String label;
  final String hint;
}

enum WeatherForecastChoice {
  dry('강수 없음 (3일간 맑음)'),
  rainAfter1to2Day('1~2일 후 비 예보'),
  rainWithin24h('24시간 이내 비 예보'),
  unknown('모름');

  const WeatherForecastChoice(this.label);
  final String label;
}

enum HarvestRange {
  within14('14일 이내에 수확합니다', 14),
  days14to21('14일~21일 사이에 수확합니다', 20),
  days21to30('21일~30일 사이에 수확합니다', 29),
  after30('30일 이후에 수확합니다', 60);

  const HarvestRange(this.label, this.maxDays);
  final String label;
  final int maxDays; // 안전사용기준 비교용 (남은 일수의 상한)
}

enum NeighborSensitive {
  yes('있음 (인접 작물 또는 양봉장)'),
  no('없음');

  const NeighborSensitive(this.label);
  final String label;
}

class CopingChecklist {
  EcoPreference? s1;
  DiseaseSpread? s2;
  SprayCount? s3;
  SprayEquipment? s4;
  WeatherForecastChoice? s5;
  HarvestRange? s6;
  NeighborSensitive? s7;

  int get answeredCount {
    var n = 0;
    if (s1 != null) n++;
    if (s2 != null) n++;
    if (s3 != null) n++;
    if (s4 != null) n++;
    if (s5 != null) n++;
    if (s6 != null) n++;
    if (s7 != null) n++;
    return n;
  }

  static const total = 7;
  bool get isComplete => answeredCount == total;
  int get remaining => total - answeredCount;
}

// -- 추천 결과 ----------------------------------------------------------------

enum CopingResultKind {
  /// 약제 사용 불가/필요 없음 (수확 임박 등 일반)
  noDrugNeeded,

  /// 등숙기 — 방제 효과가 없어 수확 후 관리 위주
  noDrugHarvest,

  /// 강수/강풍 등 살포 불가 + 입제도 없음
  sprayBlocked,

  /// 살포 불가 + 입제(기상 무관) 약제만 사용 가능
  granuleOnly,

  /// 친환경 모드: 친환경 약제만 추천
  ecoOnly,

  /// 친환경 모드 + 위험등급 심각 → 화학 약제 권장 (eco override)
  ecoInsufficient,

  /// 단일 약제 + (수확14일전 등) 강조 경고
  warningDrug,

  /// 다중 후보 약제
  multipleDrugs,
}

class CopingResult {
  final CopingResultKind kind;
  final SprayScenario scenario;
  final SprayCondition condition;
  final RiskGrade grade;
  final String stageName;

  final List<Drug> drugs; // 1순위, 2순위...
  final List<NonDrugMethod> nonDrugs;
  final List<String> reasons; // "왜 이 방법인가요?"
  final String? notice; // 비고 (노란 카드)
  final List<String> noDrugReasons; // 약제 없는 경우
  final List<String> nextStagePrep; // "다음 시기 방제 준비"
  final List<NonDrugMethod> postHarvestActions; // 등숙기 "수확 후 이렇게 해주세요"
  final String? bottomNote; // 친환경 부족 등 → 본문 하단 안내 배너

  const CopingResult({
    required this.kind,
    required this.scenario,
    required this.condition,
    required this.grade,
    required this.stageName,
    required this.drugs,
    required this.nonDrugs,
    required this.reasons,
    this.notice,
    this.noDrugReasons = const [],
    this.nextStagePrep = const [],
    this.postHarvestActions = const [],
    this.bottomNote,
  });

  Drug? get primaryDrug => drugs.isEmpty ? null : drugs.first;
}

import '../models/coping_models.dart';

/// 잎집무늬마름병 방제 매트릭스 — 엑셀 `잎집무늬마름병_방제메트릭스_v5.xlsx` 의
/// `약제_상세정보`, `비약제_상세정보`, 생육단계별 시트를 dart 로 옮긴 것.
class CopingCatalog {
  CopingCatalog._();

  // -- 약제 9 종 -------------------------------------------------------------

  static const Drug iangiGranule = Drug(
    id: 'iangi_granule',
    brand: '도래미',
    maker: '(주)팜한농',
    ingredient: '아족시스트로빈+클로티아니딘',
    formulation: DrugFormulation.granule,
    dilution: '직접 살포',
    safetyTimeLabel: '이앙기 처리',
    safetyDaysBeforeHarvest: null,
    safetyCountLabel: '1회',
    safetyCountMax: 1,
    eco: false,
    characteristic: '이앙 전 1회 처리, 기상 무관 → 살포불가 시나리오에서도 사용 가능',
    weatherIndependent: true,
  );

  static const Drug validamycin = Drug(
    id: 'validamycin',
    brand: '팜한농바리신',
    maker: '(주)팜한농',
    ingredient: '발리다마이신에이',
    formulation: DrugFormulation.liquid,
    dilution: '1,000배',
    safetyTimeLabel: '수확 21일전',
    safetyDaysBeforeHarvest: 21,
    safetyCountLabel: '4회',
    safetyCountMax: 4,
    eco: false,
    characteristic: '즉각 효과, 침투이행 약함 → 잎집 아래까지 충분히 살포 필수',
    weatherIndependent: false,
  );

  static const Drug pencycuron = Drug(
    id: 'pencycuron',
    brand: '몬세렌',
    maker: '(주)팜한농',
    ingredient: '펜사이큐론',
    formulation: DrugFormulation.wettable,
    dilution: '2,000배',
    safetyTimeLabel: '수확 30일전',
    safetyDaysBeforeHarvest: 30,
    safetyCountLabel: '3회',
    safetyCountMax: 3,
    eco: false,
    characteristic: '침투이행성 우수, 예방 효과 강함',
    weatherIndependent: false,
  );

  static const Drug hexaconazole = Drug(
    id: 'hexaconazole',
    brand: '엑티베이터',
    maker: '신젠타코리아(주)',
    ingredient: '헥사코나졸',
    formulation: DrugFormulation.emulsifiable,
    dilution: '1,000배',
    safetyTimeLabel: '수확 21일전',
    safetyDaysBeforeHarvest: 21,
    safetyCountLabel: '3회',
    safetyCountMax: 3,
    eco: false,
    characteristic: '침투이행성 우수, 예방+치료 겸용',
    weatherIndependent: false,
  );

  static const Drug bacillus = Drug(
    id: 'bacillus',
    brand: '씰러스',
    maker: '(주)그린바이오텍',
    ingredient: '바실루스서브틸리스 지비365',
    formulation: DrugFormulation.suspension,
    dilution: '300배',
    safetyTimeLabel: '발생 초기까지',
    safetyDaysBeforeHarvest: null,
    safetyCountLabel: '회수 제한 없음',
    safetyCountMax: null,
    eco: true,
    characteristic: '친환경 인증 가능, 예방 목적, 효과 변동성',
    weatherIndependent: false,
  );

  static const Drug amistatop = Drug(
    id: 'amistatop',
    brand: '아미스타탑',
    maker: '신젠타코리아(주)',
    ingredient: '아족시스트로빈+디페노코나졸',
    formulation: DrugFormulation.suspension,
    dilution: '2,000배',
    safetyTimeLabel: '수확 14일전',
    safetyDaysBeforeHarvest: 14,
    safetyCountLabel: '3회',
    safetyCountMax: 3,
    eco: false,
    characteristic: '광범위 복합살균제, 도열병·이삭누룩병 동시방제',
    weatherIndependent: false,
  );

  static const Drug gongjungjeon = Drug(
    id: 'gongjungjeon',
    brand: '공중전',
    maker: '(주)팜한농',
    ingredient: '헥사코나졸+티아디닐',
    formulation: DrugFormulation.suspension,
    dilution: '2,000배',
    safetyTimeLabel: '수확 21일전',
    safetyDaysBeforeHarvest: 21,
    safetyCountLabel: '3회',
    safetyCountMax: 3,
    eco: false,
    characteristic: '침투이행성 우수, 예방+치료 겸용, 도열병 동시방제',
    weatherIndependent: false,
  );

  static const Drug amista = Drug(
    id: 'amista',
    brand: '아미스타',
    maker: '신젠타코리아(주)',
    ingredient: '아족시스트로빈 (단제)',
    formulation: DrugFormulation.wettable,
    dilution: '1,000배',
    safetyTimeLabel: '수확 21일전',
    safetyDaysBeforeHarvest: 21,
    safetyCountLabel: '3회',
    safetyCountMax: 3,
    eco: false,
    characteristic: '광범위 살균, 침투이행성 우수',
    weatherIndependent: false,
  );

  static const Drug kitazin = Drug(
    id: 'kitazin',
    brand: '키타진',
    maker: '(주)경농',
    ingredient: '이프로벤포스',
    formulation: DrugFormulation.granule,
    dilution: '직접 살포',
    safetyTimeLabel: '수확 30일전',
    safetyDaysBeforeHarvest: 30,
    safetyCountLabel: '2회',
    safetyCountMax: 2,
    eco: false,
    characteristic: '비·바람 무관, 살포불가 시나리오에서 유일한 선택지',
    weatherIndependent: true,
  );

  static List<Drug> get allDrugs => const [
        iangiGranule,
        validamycin,
        pencycuron,
        hexaconazole,
        bacillus,
        amistatop,
        gongjungjeon,
        amista,
        kitazin,
      ];

  // -- 비약제 8 종 -----------------------------------------------------------

  static const NonDrugMethod ventilation = NonDrugMethod(
    id: 'ventilation',
    name: '통풍 확보',
    description: '잡초 제거와 줄 방향 조정으로 포기 사이 공기를 순환시켜 주세요',
    urgency: '즉시',
  );

  static const NonDrugMethod midDrain = NonDrugMethod(
    id: 'mid_drain',
    name: '중간 낙수',
    description: '분얼기 후반~유수형성기 사이 논물을 5~7일간 완전히 빼서 건조시켜 주세요',
    urgency: '1~2일 내',
  );

  static const NonDrugMethod awd = NonDrugMethod(
    id: 'awd',
    name: '간단관수 (AWD)',
    description: '토양 표면이 마를 때까지 기다린 후 다시 물을 대는 방식을 반복해 주세요',
    urgency: '상시',
  );

  static const NonDrugMethod isolate = NonDrugMethod(
    id: 'isolate',
    name: '발병 포기 격리',
    description: '발병된 포기에 표식 후 심한 발병주를 제거하고 주변 포기를 집중 관찰해 주세요',
    urgency: '발견 즉시',
  );

  static const NonDrugMethod sclerotia = NonDrugMethod(
    id: 'sclerotia',
    name: '균핵 제거',
    description: '써레질 직후 물 위에 떠오른 균핵을 망으로 걷어내 주세요',
    urgency: '이앙 전',
  );

  static const NonDrugMethod fertilizer = NonDrugMethod(
    id: 'fertilizer',
    name: '시비 조절',
    description: '질소 비료는 10a당 11kg 이내로 제한하고 추비를 자제해 주세요',
    urgency: '정기',
  );

  static const NonDrugMethod scout = NonDrugMethod(
    id: 'scout',
    name: '정기 예찰',
    description: '3~5일 간격으로 잎집 아래쪽 무늬 확산 여부를 확인해 주세요',
    urgency: '상시',
  );

  static const NonDrugMethod strawDispose = NonDrugMethod(
    id: 'straw_dispose',
    name: '볏짚 처리',
    description: '수확 후 볏짚은 소각하거나 깊이갈이로 매립해 주세요',
    urgency: '수확 직후',
  );

  /// 등숙기 "수확 후 이렇게 해주세요" — 발병 기록
  static const NonDrugMethod postRecord = NonDrugMethod(
    id: 'post_record',
    name: '발병 기록 남기기',
    description: '발병주율, 병반 위치, 균핵 낙하 정도를 기록해 두세요',
    urgency: '수확 직후',
  );

  /// 등숙기 "수확 후 이렇게 해주세요" — 내년 대비
  static const NonDrugMethod postNextYear = NonDrugMethod(
    id: 'post_next_year',
    name: '내년 대비',
    description: '이 논의 발병 이력을 내년 이앙 전 방제 계획에 활용해 주세요',
    urgency: '수확 후',
  );

  // -- 생육단계 × 시나리오 → 약제 우선순위 ----------------------------------

  /// 키 형식: "${stageName}_${scenario.letter}"
  static const Map<String, List<String>> _stageScenarioDrugs = {
    // 이앙기 -----------------------------------------------------------------
    '이앙기_A': ['iangi_granule', 'validamycin'],
    '이앙기_B': ['iangi_granule', 'validamycin'],
    '이앙기_C': ['iangi_granule'],
    '이앙기_D': ['iangi_granule', 'pencycuron'],
    '이앙기_E': ['iangi_granule', 'pencycuron'],
    '이앙기_F': ['iangi_granule'],
    '이앙기_G': [], '이앙기_H': [], '이앙기_I': [],

    // 분얼기 -----------------------------------------------------------------
    '분얼기_A': ['validamycin', 'pencycuron', 'hexaconazole', 'bacillus'],
    '분얼기_B': ['validamycin', 'pencycuron', 'hexaconazole', 'bacillus'],
    '분얼기_C': [],
    '분얼기_D': ['hexaconazole', 'bacillus', 'pencycuron'],
    '분얼기_E': ['hexaconazole', 'bacillus', 'pencycuron'],
    '분얼기_F': [], '분얼기_G': [], '분얼기_H': [], '분얼기_I': [],

    // 유수형성기 ------------------------------------------------------------
    '유수형성기_A': ['amistatop', 'gongjungjeon', 'amista'],
    '유수형성기_B': ['amistatop', 'gongjungjeon', 'amista'],
    '유수형성기_C': [],
    '유수형성기_D': ['gongjungjeon', 'amista', 'amistatop'],
    '유수형성기_E': ['gongjungjeon', 'amista', 'amistatop'],
    '유수형성기_F': [],
    '유수형성기_G': [], '유수형성기_H': [], '유수형성기_I': [],

    // 수잉기 -----------------------------------------------------------------
    '수잉기_A': ['amistatop', 'kitazin', 'amista'],
    '수잉기_B': ['amistatop', 'kitazin', 'amista'],
    '수잉기_C': ['kitazin'],
    '수잉기_D': ['amista', 'gongjungjeon', 'kitazin'],
    '수잉기_E': ['amista', 'gongjungjeon', 'kitazin'],
    '수잉기_F': ['kitazin'],
    '수잉기_G': [], '수잉기_H': [], '수잉기_I': [],

    // 출수기 -----------------------------------------------------------------
    '출수기_A': ['amistatop', 'amista'],
    '출수기_B': ['amistatop', 'amista'],
    '출수기_C': [],
    '출수기_D': ['amista', 'amistatop'],
    '출수기_E': ['amista', 'amistatop'],
    '출수기_F': [],
    '출수기_G': [], '출수기_H': [], '출수기_I': [],

    // 등숙기: 모든 시나리오 약제 사용 제한 -----------------------------------
    '등숙기_A': [], '등숙기_B': [], '등숙기_C': [],
    '등숙기_D': [], '등숙기_E': [], '등숙기_F': [],
    '등숙기_G': [], '등숙기_H': [], '등숙기_I': [],
  };

  /// 생육단계 × 시나리오 → 비약제 방법 ID 목록 (앱 표시 순서)
  static const Map<String, List<String>> _stageScenarioNonDrugs = {
    // 이앙기 -----------------------------------------------------------------
    '이앙기_A': ['sclerotia', 'fertilizer'],
    '이앙기_B': ['ventilation', 'sclerotia', 'fertilizer'],
    '이앙기_C': ['sclerotia', 'fertilizer'],
    '이앙기_D': ['sclerotia', 'fertilizer'],
    '이앙기_E': ['ventilation', 'sclerotia', 'fertilizer'],
    '이앙기_F': ['sclerotia', 'fertilizer', 'ventilation'],
    '이앙기_G': ['scout', 'fertilizer', 'sclerotia'],
    '이앙기_H': ['ventilation', 'scout', 'fertilizer'],
    '이앙기_I': ['scout', 'fertilizer', 'sclerotia'],

    // 분얼기 -----------------------------------------------------------------
    '분얼기_A': ['scout', 'midDrain', 'fertilizer'],
    '분얼기_B': ['ventilation', 'scout', 'midDrain', 'fertilizer'],
    '분얼기_C': ['isolate', 'ventilation', 'awd', 'scout'],
    '분얼기_D': ['scout', 'awd', 'fertilizer'],
    '분얼기_E': ['ventilation', 'scout', 'awd', 'fertilizer'],
    '분얼기_F': ['ventilation', 'awd', 'fertilizer', 'scout'],
    '분얼기_G': ['scout', 'fertilizer'],
    '분얼기_H': ['ventilation', 'scout', 'fertilizer'],
    '분얼기_I': ['scout', 'fertilizer'],

    // 유수형성기 ------------------------------------------------------------
    '유수형성기_A': ['scout', 'midDrain', 'awd'],
    '유수형성기_B': ['ventilation', 'scout', 'midDrain', 'awd'],
    '유수형성기_C': ['isolate', 'midDrain', 'awd', 'scout'],
    '유수형성기_D': ['scout', 'midDrain', 'awd'],
    '유수형성기_E': ['ventilation', 'scout', 'midDrain', 'awd'],
    '유수형성기_F': ['midDrain', 'awd', 'scout', 'ventilation'],
    '유수형성기_G': ['scout', 'awd'],
    '유수형성기_H': ['ventilation', 'scout', 'awd'],
    '유수형성기_I': ['scout', 'awd'],

    // 수잉기 -----------------------------------------------------------------
    '수잉기_A': ['scout', 'awd'],
    '수잉기_B': ['ventilation', 'scout', 'awd'],
    '수잉기_C': ['awd', 'scout'],
    '수잉기_D': ['scout', 'awd', 'ventilation', 'fertilizer'],
    '수잉기_E': ['ventilation', 'scout', 'awd', 'fertilizer'],
    '수잉기_F': ['awd', 'scout'],
    '수잉기_G': ['scout', 'fertilizer'],
    '수잉기_H': ['ventilation', 'scout', 'fertilizer'],
    '수잉기_I': ['scout', 'fertilizer'],

    // 출수기 -----------------------------------------------------------------
    '출수기_A': ['scout', 'awd'],
    '출수기_B': ['ventilation', 'scout', 'awd'],
    '출수기_C': ['scout', 'awd'],
    '출수기_D': ['scout', 'awd'],
    '출수기_E': ['ventilation', 'scout', 'awd'],
    '출수기_F': ['scout', 'awd'],
    '출수기_G': ['scout', 'awd'],
    '출수기_H': ['ventilation', 'scout', 'awd'],
    '출수기_I': ['scout', 'awd'],

    // 등숙기 -----------------------------------------------------------------
    '등숙기_A': ['scout', 'strawDispose'],
    '등숙기_B': ['ventilation', 'strawDispose'],
    '등숙기_C': ['scout', 'strawDispose'],
    '등숙기_D': ['scout', 'strawDispose', 'awd'],
    '등숙기_E': ['ventilation', 'strawDispose'],
    '등숙기_F': ['scout', 'strawDispose'],
    '등숙기_G': ['scout', 'strawDispose'],
    '등숙기_H': ['ventilation', 'strawDispose'],
    '등숙기_I': ['scout', 'strawDispose'],
  };

  static const Map<String, Drug> _drugsById = {
    'iangi_granule': iangiGranule,
    'validamycin': validamycin,
    'pencycuron': pencycuron,
    'hexaconazole': hexaconazole,
    'bacillus': bacillus,
    'amistatop': amistatop,
    'gongjungjeon': gongjungjeon,
    'amista': amista,
    'kitazin': kitazin,
  };

  static const Map<String, NonDrugMethod> _nonDrugsById = {
    'ventilation': ventilation,
    'midDrain': midDrain,
    'awd': awd,
    'isolate': isolate,
    'sclerotia': sclerotia,
    'fertilizer': fertilizer,
    'scout': scout,
    'strawDispose': strawDispose,
  };

  static List<Drug> drugsFor({
    required String stageName,
    required SprayScenario scenario,
  }) {
    final key = '${stageName}_${scenario.letter}';
    final ids = _stageScenarioDrugs[key] ?? const <String>[];
    return ids
        .map((id) => _drugsById[id])
        .whereType<Drug>()
        .toList(growable: false);
  }

  static List<NonDrugMethod> nonDrugsFor({
    required String stageName,
    required SprayScenario scenario,
  }) {
    final key = '${stageName}_${scenario.letter}';
    final ids = _stageScenarioNonDrugs[key] ?? const <String>[];
    return ids
        .map((id) => _nonDrugsById[id])
        .whereType<NonDrugMethod>()
        .toList(growable: false);
  }
}

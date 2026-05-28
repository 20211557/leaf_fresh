import '../models/coping_models.dart';
import '../models/forecast.dart';
import '../models/growth_stage.dart';
import '../models/user_settings.dart';
import '../theme/risk_palette.dart';
import 'coping_catalog.dart';

/// 체크리스트 + 오늘 예측 + 사용자 설정으로 방제 추천 결과를 만든다.
class CopingRecommender {
  CopingRecommender._();

  static CopingResult recommend({
    required UserSettings settings,
    required Prediction today,
    required CopingChecklist checklist,
  }) {
    // 1) 생육 단계 (로컬 이앙일 기반)
    final stageIndex =
        GrowthStageCalculator.activeIndex(settings.transplantDate);
    final stageName = GrowthStageCalculator.riceStages[stageIndex].name;

    // 2) 살포 조건 — JSON inputs.wind_speed_today / precipitation_today
    final condition = classifySprayCondition(
      windMs: today.inputs.windSpeedToday,
      rainMm: today.inputs.precipitationToday,
    );

    // 3) 위험 등급 — JSON grade. S2 가 '말기' 라면 심각으로, '확산' 이면 경계 이상으로 보정.
    var grade = RiskPalette.fromGradeCode(today.grade);
    if (checklist.s2 == DiseaseSpread.late) {
      grade = RiskGrade.severe;
    } else if (checklist.s2 == DiseaseSpread.spreading &&
        grade.index < RiskGrade.alert.index) {
      grade = RiskGrade.alert;
    }

    // 4) 시나리오 결정 (A~I)
    final scenario = resolveScenario(grade, condition);

    // 5) 후보 약제 / 비약제
    final base = CopingCatalog.drugsFor(
      stageName: stageName,
      scenario: scenario,
    );
    final nonDrugs = CopingCatalog.nonDrugsFor(
      stageName: stageName,
      scenario: scenario,
    );

    // 6) 친환경 필터 (+ 심각 → eco override)
    final ecoMode = checklist.s1 == EcoPreference.certified;
    final ecoOverride = ecoMode && grade == RiskGrade.severe;
    final usingEcoFilter = ecoMode && !ecoOverride;
    var filtered = usingEcoFilter
        ? base.where((d) => d.eco).toList()
        : List<Drug>.from(base);

    // 7) 수확 기간 필터
    final harvestMax = checklist.s6?.maxDays;
    if (harvestMax != null) {
      filtered = filtered.where((d) {
        final req = d.safetyDaysBeforeHarvest;
        if (req == null) return true; // 입제/이앙기/회수제한없음
        return req <= harvestMax;
      }).toList();
    }

    // 8) 살포 횟수 필터
    final usedCount = checklist.s3?.value ?? 0;
    filtered = filtered.where((d) {
      final maxCount = d.safetyCountMax;
      if (maxCount == null) return true;
      return usedCount < maxCount;
    }).toList();

    // 9) 결과 종류 결정
    final kind = _resolveKind(
      stageName: stageName,
      ecoMode: ecoMode,
      ecoOverride: ecoOverride,
      drugs: filtered,
      condition: condition,
      checklist: checklist,
    );

    // 10) 텍스트 빌드
    final reasons = _buildReasonsFor(
      kind: kind,
      stageName: stageName,
      condition: condition,
      grade: grade,
      checklist: checklist,
      primary: filtered.isEmpty ? null : filtered.first,
    );
    final notice = _buildNotice(
      kind: kind,
      stageName: stageName,
    );
    final noDrugReasons =
        (kind == CopingResultKind.noDrugNeeded)
            ? _buildNoDrugReasons(
                stageName: stageName,
                condition: condition,
                checklist: checklist,
              )
            : const <String>[];
    final nextPrep = kind == CopingResultKind.noDrugNeeded
        ? _nextStagePrep(stageName)
        : const <String>[];
    final postHarvest = kind == CopingResultKind.noDrugHarvest
        ? const [
            CopingCatalog.postRecord,
            CopingCatalog.strawDispose,
            CopingCatalog.postNextYear,
          ]
        : const <NonDrugMethod>[];
    final bottomNote = kind == CopingResultKind.ecoInsufficient
        ? '발병이 줄어들면 다음 번 살포부터 다시 친환경 모드로 전환할 수 있어요.'
        : null;

    return CopingResult(
      kind: kind,
      scenario: scenario,
      condition: condition,
      grade: grade,
      stageName: stageName,
      drugs: filtered,
      nonDrugs: nonDrugs,
      reasons: reasons,
      notice: notice,
      noDrugReasons: noDrugReasons,
      nextStagePrep: nextPrep,
      postHarvestActions: postHarvest,
      bottomNote: bottomNote,
    );
  }

  /// 결과 변형 결정
  static CopingResultKind _resolveKind({
    required String stageName,
    required bool ecoMode,
    required bool ecoOverride,
    required List<Drug> drugs,
    required SprayCondition condition,
    required CopingChecklist checklist,
  }) {
    // 등숙기는 항상 수확 후 관리 변형
    if (stageName == '등숙기') return CopingResultKind.noDrugHarvest;

    // 친환경 + 심각 → 친환경 부족 (override)
    if (ecoOverride) return CopingResultKind.ecoInsufficient;

    // 친환경 모드 + 약제 후보 존재
    if (ecoMode && drugs.isNotEmpty) return CopingResultKind.ecoOnly;

    // 약제 후보 없음
    if (drugs.isEmpty) {
      if (condition == SprayCondition.impossible) {
        return CopingResultKind.sprayBlocked;
      }
      return CopingResultKind.noDrugNeeded;
    }

    // 살포 불가 + 입제(기상 무관) 약제만
    if (condition == SprayCondition.impossible &&
        drugs.every((d) => d.weatherIndependent)) {
      return CopingResultKind.granuleOnly;
    }

    // 14일전 약제 강조 (수확 임박이 아닌 경우)
    final primary = drugs.first;
    final harvestWithin = checklist.s6 == HarvestRange.within14;
    if (primary.safetyDaysBeforeHarvest == 14 && !harvestWithin) {
      return CopingResultKind.warningDrug;
    }

    if (drugs.length >= 2) return CopingResultKind.multipleDrugs;
    return CopingResultKind.warningDrug;
  }

  // -- 이유 빌더 ----------------------------------------------------------------

  static List<String> _buildReasonsFor({
    required CopingResultKind kind,
    required String stageName,
    required SprayCondition condition,
    required RiskGrade grade,
    required CopingChecklist checklist,
    required Drug? primary,
  }) {
    switch (kind) {
      case CopingResultKind.ecoInsufficient:
        return [
          '발병주율 20% 초과 → 생물농약 단독으로 진압 어려움',
          '침투이행성 강한 화학 약제로 빠른 확산 차단 필요',
        ];
      case CopingResultKind.sprayBlocked:
        return const [
          '현재 강수 중 또는 풍속 5m/s 초과 → 약액이 날리거나 씻겨 효과 없음',
          '강수 후 최소 6시간 건조 후 살포 가능',
        ];
      case CopingResultKind.granuleOnly:
        return [
          '현재 강수 중 또는 풍속 5m/s 초과 → 경엽처리 불가',
          '입제는 기상 조건과 무관하게 살포 가능',
          if (stageName == '수잉기' || stageName == '출수기')
            '$stageName 이삭 보호 최우선',
          if (stageName == '이앙기') '이앙기 입제 처리로 초기 방어 가능',
        ];
      case CopingResultKind.noDrugHarvest:
        return const []; // 별도 본문 섹션 사용
      case CopingResultKind.noDrugNeeded:
      case CopingResultKind.ecoOnly:
      case CopingResultKind.warningDrug:
      case CopingResultKind.multipleDrugs:
        return _buildReasonsRegular(
          stageName: stageName,
          condition: condition,
          grade: grade,
          checklist: checklist,
          primary: primary,
        );
    }
  }

  static List<String> _buildReasonsRegular({
    required String stageName,
    required SprayCondition condition,
    required RiskGrade grade,
    required CopingChecklist checklist,
    required Drug? primary,
  }) {
    final list = <String>[];

    // S1
    switch (checklist.s1) {
      case EcoPreference.certified:
        list.add('S1 응답: 친환경·유기농 인증 농가 → 화학 살균제 자동 제외');
        break;
      case EcoPreference.preferEco:
        list.add('체크리스트 결과 친환경 선호이지만 인증은 없어 효과 우선 화학약제 적합');
        break;
      case EcoPreference.effectFirst:
        list.add('효과 우선 응답 → 등록 약제 중 효과 기준 1순위 추천');
        break;
      case null:
        break;
    }

    // S2
    switch (checklist.s2) {
      case DiseaseSpread.early:
        list.add('병반이 잎집 아래쪽 초기 단계 → 예방적 살포 및 정기 관찰 병행');
        break;
      case DiseaseSpread.spreading:
        if (primary != null && primary.eco) {
          list.add('병반이 위쪽 잎까지 확산 중 → 친환경 등록 약제 + 정기 관찰 병행');
        } else if (primary != null) {
          list.add('병반이 위쪽 잎까지 확산 중 → 침투이행성 우수한 단제 권장');
        } else {
          list.add('병반이 위쪽 잎까지 확산 중 → 즉각 비약제 조치');
        }
        break;
      case DiseaseSpread.late:
        list.add('줄기·이삭까지 침범 → 위험등급 심각으로 격상');
        break;
      case null:
        break;
    }

    // 약제별 안전기준
    if (primary?.id == 'amistatop') {
      list.add('$stageName 도열병·이삭누룩병 동시방제 가능한 복합 살균제');
      list.add('수확까지 14일 이상 남은 경우에만 사용 가능');
    } else if (primary != null && primary.safetyDaysBeforeHarvest != null) {
      final hrLabel = checklist.s6?.label
              .replaceAll(' 사이에 수확합니다', '')
              .replaceAll('에 수확합니다', '') ??
          '21~30일';
      list.add('수확까지 $hrLabel → 안전사용기준(${primary.safetyTimeLabel}) 충족');
    } else if (primary != null && primary.safetyDaysBeforeHarvest == null) {
      final hrLabel = checklist.s6?.label
              .replaceAll('에 수확합니다', '')
              .replaceAll(' 사이에 수확합니다', '') ??
          '';
      list.add(
          '수확까지 $hrLabel → 회수 제한 없는 ${primary.ingredient.split(' ').first} 계열 안전');
    }

    // 살포 조건
    switch (condition) {
      case SprayCondition.goodVentilation:
        list.add('강수 없음 · 풍속 2~5m/s → 경엽 살포 조건 충족');
        break;
      case SprayCondition.poorVentilation:
        list.add('풍속 <2m/s → 통풍 확보 후 살포 권장');
        break;
      case SprayCondition.impossible:
        list.add('강수 중 또는 풍속 >5m/s → 경엽 살포 불가, 비약제 우선');
        break;
    }
    return list;
  }

  static String? _buildNotice({
    required CopingResultKind kind,
    required String stageName,
  }) {
    if (kind == CopingResultKind.ecoOnly) {
      return '친환경 인증 농가는 화학 살균제 사용 시 인증이 박탈될 수 있습니다. 등록된 친환경 약제와 비약제 방법만 추천드려요.';
    }
    if (kind == CopingResultKind.multipleDrugs && stageName == '수잉기') {
      return '수잉기는 방제 효과가 제한적입니다. 출수기 복합 방제를 준비하세요.';
    }
    return null;
  }

  static List<String> _buildNoDrugReasons({
    required String stageName,
    required SprayCondition condition,
    required CopingChecklist checklist,
  }) {
    final reasons = <String>[];
    if (checklist.s6 == HarvestRange.within14) {
      reasons.add('수확까지 14일 이내 — 모든 등록 약제가 안전사용기준 위반');
    }
    if (checklist.s4 != null) {
      reasons.add('살포 장비는 사용 가능하지만 적용 가능한 약제가 없음');
    }
    if (stageName == '출수기') {
      reasons.add('출수기 후반은 잔류 위험이 높아 살포 자제 권고');
    }
    if (reasons.isEmpty) {
      reasons.add('현재 시나리오는 비약제 관리가 핵심입니다');
    }
    return reasons;
  }

  static List<String> _nextStagePrep(String stageName) {
    switch (stageName) {
      case '출수기':
        return const [
          '논 가장자리·바람 부는 쪽 균핵을 가을갈이 시 매몰',
          '내년 이앙기에 이앙기용 입제(도래미 등) 처리',
          '규산질 비료 충분히 시비, 질소 과잉 자제',
        ];
      case '이앙기':
        return const [
          '분얼기 진입 전 정기 예찰 3~5일 주기로 시작',
          '질소 비료 10a당 11kg 이내로 제한',
        ];
      default:
        return const [
          '다음 생육 시기 진입 전 정기 예찰 강화',
          '필요 시 출수기 복합 방제 준비',
        ];
    }
  }
}

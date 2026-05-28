/// 리포트 한 줄 요약 멘트 매트릭스.
///
/// 엑셀(`리포트_멘트_매트릭스.xlsx > 한줄요약_매트릭스`)을 dart 상수 테이블로 옮긴 것.
/// 조건 코드(summary_code)는 JSON 에서 받아오지만, 생육시기 관련 치환은
/// 로컬에 저장된 이앙일로 계산한 단계 이름으로 처리한다.
class SummaryResolver {
  SummaryResolver._();

  /// 조건 코드 → 멘트 템플릿
  static const Map<String, String> templates = {
    'SUM_SAFE':
        '전반적으로 안정적이에요. 다만 [생육시기]인 만큼 꾸준한 관찰이 필요해요.',
    'SUM_ENV':
        '[top변수명] 등 단기 기상 조건이 나빠지면서 [생육시기_위험설명]에 위험 점수가 빠르게 올랐어요.',
    'SUM_ENV2':
        '[top변수명] 등 단기 기상 조건이 나빠지면서 [생육시기_위험설명]에 위험 점수가 높은 상태가 이어지고 있어요.',
    'SUM_ACCUM':
        '당장 날씨는 괜찮지만, [생육시기] 동안 쌓인 위험이 높아요. 지속적인 관찰이 필요해요.',
    'SUM_BOTH':
        '고온다습이 이어지고 [생육시기_위험설명]에 들어서면서 위험 점수가 빠르게 올랐어요.',
    'SUM_BOTH2':
        '고온다습이 이어지고 [생육시기_위험설명]에서 위험 점수가 높은 상태가 이어지고 있어요.',
  };

  /// 생육시기 → 위험 설명 (`[생육시기_위험설명]` 치환용)
  static const Map<String, String> stageDanger = {
    '이앙기': '이제 막 모내기를 마친 이앙기',
    '분얼기': '벼가 가장 약한 분얼기',
    '유수형성기': '이삭이 만들어지는 유수형성기',
    '수잉기': '이삭이 패는 수잉기',
    '출수기': '벼가 이삭을 내는 출수기',
    '등숙기': '낟알이 여무는 등숙기',
  };

  /// 코드 + 로컬 생육 단계 + 옵션 정보로 한 줄 요약 텍스트를 생성한다.
  ///
  /// - [summaryCode] : JSON `summary_code` (없으면 SUM_SAFE 로 대체)
  /// - [stageName]   : 로컬 이앙일로 계산한 현재 생육 단계 이름 (예: "분얼기")
  /// - [topVarName]  : 기여도 1위 기상 변수 한국어 이름 (옵션, JSON cards 의 subtitle 등)
  static String resolve({
    String? summaryCode,
    required String stageName,
    String? topVarName,
  }) {
    final template = templates[summaryCode ?? ''] ?? templates['SUM_SAFE']!;
    final danger = stageDanger[stageName] ?? stageName;
    final top = (topVarName == null || topVarName.isEmpty)
        ? '기상 요인'
        : topVarName;
    return template
        .replaceAll('[생육시기_위험설명]', danger)
        .replaceAll('[생육시기]', stageName)
        .replaceAll('[top변수명]', top);
  }

  /// 한 줄 요약에서 강조할 (생육시기) 키워드 목록.
  /// 위험설명 안에도 생육시기 이름이 포함되므로 stageName 하나만 반환한다.
  static List<String> emphasisTerms({required String stageName}) {
    return [stageName];
  }
}

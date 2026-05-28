class Forecast {
  final String sido;
  final String regionShort;
  final DateTime baseDate;
  final int nFuture;
  final List<Prediction> predictions;
  final DateTime? updatedAt;

  const Forecast({
    required this.sido,
    required this.regionShort,
    required this.baseDate,
    required this.nFuture,
    required this.predictions,
    required this.updatedAt,
  });

  Prediction? get today => predictions.isEmpty ? null : predictions.first;

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final rawPreds = json['predictions'] as List<dynamic>? ?? const [];
    return Forecast(
      sido: (json['sido'] ?? '') as String,
      regionShort: (json['region'] ?? '') as String,
      baseDate: DateTime.parse(json['base_date'] as String),
      nFuture: (json['n_future'] as num?)?.toInt() ?? rawPreds.length,
      predictions: rawPreds
          .map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'] as String),
    );
  }
}

class Prediction {
  final DateTime targetDate;
  final String displayDate;
  final int grade;
  final String gradeName;
  final double riskScore;

  /// 오늘(offset_days == 0) 예측에만 존재한다.
  final String? summary;
  final String? summaryCode;
  final GradeChange? gradeChange;
  final List<ForecastCard> cards;

  final int offsetDays;
  final PredictionInputs inputs;

  const Prediction({
    required this.targetDate,
    required this.displayDate,
    required this.grade,
    required this.gradeName,
    required this.riskScore,
    required this.summary,
    required this.summaryCode,
    required this.gradeChange,
    required this.cards,
    required this.offsetDays,
    required this.inputs,
  });

  double get riskScore100 => (riskScore * 100).clamp(0, 100).toDouble();

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>? ?? const [];
    final rawInputs = json['inputs'];
    final rawGc = json['grade_change'];
    return Prediction(
      targetDate: DateTime.parse(json['target_date'] as String),
      displayDate: (json['기준_날짜_표시'] ?? '') as String,
      grade: (json['grade'] as num?)?.toInt() ?? 0,
      gradeName: (json['grade_name'] ?? '') as String,
      riskScore: (json['Risk_score'] as num?)?.toDouble() ?? 0,
      summary: json['summary'] as String?,
      summaryCode: json['summary_code'] as String?,
      gradeChange: rawGc is Map<String, dynamic>
          ? GradeChange.fromJson(rawGc)
          : null,
      cards: rawCards
          .map((e) => ForecastCard.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      offsetDays: (json['offset_days'] as num?)?.toInt() ?? 0,
      inputs: rawInputs is Map<String, dynamic>
          ? PredictionInputs.fromJson(rawInputs)
          : const PredictionInputs(),
    );
  }
}

/// 위험 등급 변화 (`predictions[0].grade_change`)
enum GradeChangeDirection { up, down, same }

class GradeChange {
  final int fromCode;
  final String fromName;
  final int toCode;
  final String toName;
  final GradeChangeDirection direction;
  final String? label;

  const GradeChange({
    required this.fromCode,
    required this.fromName,
    required this.toCode,
    required this.toName,
    required this.direction,
    this.label,
  });

  bool get isUp => direction == GradeChangeDirection.up;
  bool get isDown => direction == GradeChangeDirection.down;
  bool get isSame => direction == GradeChangeDirection.same;

  factory GradeChange.fromJson(Map<String, dynamic> json) {
    final dirStr = (json['direction'] ?? 'same') as String;
    final dir = switch (dirStr) {
      'up' => GradeChangeDirection.up,
      'down' => GradeChangeDirection.down,
      _ => GradeChangeDirection.same,
    };
    return GradeChange(
      fromCode: (json['from_code'] as num?)?.toInt() ?? 0,
      fromName: (json['from'] ?? '') as String,
      toCode: (json['to_code'] as num?)?.toInt() ?? 0,
      toName: (json['to'] ?? '') as String,
      direction: dir,
      label: json['label'] as String?,
    );
  }
}

/// 오늘 예측에 함께 실려 오는 환경 변수.
///
/// 방제 추천 로직에서는 [windSpeedToday] 와 [precipitationToday] 를 사용해
/// 살포 가능 여부(통풍양호/통풍불량/살포불가)를 분류한다.
class PredictionInputs {
  final double? windSpeedToday;
  final double? precipitationToday;
  final double? tempMean3;
  final double? rhMean3;

  const PredictionInputs({
    this.windSpeedToday,
    this.precipitationToday,
    this.tempMean3,
    this.rhMean3,
  });

  factory PredictionInputs.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    return PredictionInputs(
      windSpeedToday: toDouble(json['wind_speed_today']),
      precipitationToday: toDouble(json['precipitation_today']),
      tempMean3: toDouble(json['temp_mean_3']),
      rhMean3: toDouble(json['rh_mean_3']),
    );
  }
}

class ForecastCard {
  final String type;
  final String? group;
  final String? groupLabel;
  final String? subtitle;
  final String title;
  final String message;
  final String? conditionCode;
  final String? feature;
  final num? value;
  final int no;

  const ForecastCard({
    required this.type,
    required this.group,
    required this.groupLabel,
    required this.subtitle,
    required this.title,
    required this.message,
    required this.conditionCode,
    required this.feature,
    required this.value,
    required this.no,
  });

  factory ForecastCard.fromJson(Map<String, dynamic> json) {
    return ForecastCard(
      type: (json['type'] ?? 'weather') as String,
      group: json['group'] as String?,
      groupLabel: json['group_label'] as String?,
      subtitle: json['subtitle'] as String?,
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      conditionCode: json['condition_code'] as String?,
      feature: json['feature'] as String?,
      value: json['value'] as num?,
      no: (json['no'] as num?)?.toInt() ?? 0,
    );
  }
}

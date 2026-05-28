import 'package:flutter/material.dart';

enum RiskGrade { safe, caution, alert, severe }

class RiskPalette {
  RiskPalette._();

  static const double safeMax = 3;
  static const double cautionMax = 16;
  static const double alertMax = 35;

  static const Map<RiskGrade, Color> color = {
    RiskGrade.safe: Color(0xFF67B864),
    RiskGrade.caution: Color(0xFFF0C748),
    RiskGrade.alert: Color(0xFFF4A150),
    RiskGrade.severe: Color(0xFFE66457),
  };

  static const Map<RiskGrade, Color> background = {
    RiskGrade.safe: Color(0xFFE3F0E1),
    RiskGrade.caution: Color(0xFFFCF1D3),
    RiskGrade.alert: Color(0xFFFCE3CC),
    RiskGrade.severe: Color(0xFFFCDDD7),
  };

  static const Map<RiskGrade, String> label = {
    RiskGrade.safe: '안전',
    RiskGrade.caution: '주의',
    RiskGrade.alert: '경계',
    RiskGrade.severe: '심각',
  };

  static RiskGrade fromScore100(double score) {
    if (score <= safeMax) return RiskGrade.safe;
    if (score <= cautionMax) return RiskGrade.caution;
    if (score <= alertMax) return RiskGrade.alert;
    return RiskGrade.severe;
  }

  static RiskGrade fromGradeCode(int code) {
    switch (code) {
      case 0:
        return RiskGrade.safe;
      case 1:
        return RiskGrade.caution;
      case 2:
        return RiskGrade.alert;
      case 3:
        return RiskGrade.severe;
      default:
        return RiskGrade.safe;
    }
  }
}

class UserSettings {
  final String region;
  final String crop;
  final String disease;
  final DateTime transplantDate;

  const UserSettings({
    required this.region,
    required this.crop,
    required this.disease,
    required this.transplantDate,
  });

  Map<String, dynamic> toJson() => {
        'region': region,
        'crop': crop,
        'disease': disease,
        'transplantDate': transplantDate.toIso8601String(),
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        region: json['region'] as String,
        crop: json['crop'] as String,
        disease: json['disease'] as String,
        transplantDate: DateTime.parse(json['transplantDate'] as String),
      );

  UserSettings copyWith({
    String? region,
    String? crop,
    String? disease,
    DateTime? transplantDate,
  }) {
    return UserSettings(
      region: region ?? this.region,
      crop: crop ?? this.crop,
      disease: disease ?? this.disease,
      transplantDate: transplantDate ?? this.transplantDate,
    );
  }
}

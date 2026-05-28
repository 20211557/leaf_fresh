import 'package:flutter/foundation.dart';

class SetupDraft extends ChangeNotifier {
  String? region;
  String? crop;
  String? disease;
  DateTime? transplantDate;

  bool get hasRegion => region != null && region!.isNotEmpty;
  bool get hasCropDisease =>
      crop != null && crop!.isNotEmpty && disease != null && disease!.isNotEmpty;
  bool get hasDate => transplantDate != null;
  bool get isComplete => hasRegion && hasCropDisease && hasDate;

  void setRegion(String value) {
    region = value;
    notifyListeners();
  }

  void setCropDisease({required String crop, required String disease}) {
    this.crop = crop;
    this.disease = disease;
    notifyListeners();
  }

  void setDate(DateTime value) {
    transplantDate = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_settings.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/setup_step_indicator.dart';
import 'crop_select_step.dart';
import 'region_select_step.dart';
import 'setup_complete_screen.dart';
import 'setup_controller.dart';
import 'transplant_date_step.dart';

class SetupFlowScreen extends StatefulWidget {
  const SetupFlowScreen({super.key});

  @override
  State<SetupFlowScreen> createState() => _SetupFlowScreenState();
}

class _SetupFlowScreenState extends State<SetupFlowScreen> {
  final SetupDraft _draft = SetupDraft();
  final PageController _pageController = PageController();
  int _index = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft.addListener(_onDraftChanged);
  }

  void _onDraftChanged() => setState(() {});

  @override
  void dispose() {
    _draft.removeListener(_onDraftChanged);
    _draft.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_index) {
      case 0:
        return _draft.hasRegion;
      case 1:
        return _draft.hasCropDisease;
      case 2:
        return _draft.hasDate;
      default:
        return false;
    }
  }

  String get _buttonLabel => _index == 2 ? '시작하기' : '다음';

  Future<void> _onPressed() async {
    if (_index < 2) {
      setState(() => _index += 1);
      _pageController.animateToPage(
        _index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    final settings = UserSettings(
      region: _draft.region!,
      crop: _draft.crop!,
      disease: _draft.disease!,
      transplantDate: _draft.transplantDate!,
    );
    await SettingsService().save(settings);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SetupCompleteScreen(settings: settings),
      ),
    );
  }

  void _onBack() {
    if (_index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index -= 1);
    _pageController.animateToPage(
      _index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  List<SetupStepData> _buildSteps() {
    SetupStepState stateOf(int i) {
      if (i < _index) return SetupStepState.completed;
      if (i == _index) return SetupStepState.current;
      return SetupStepState.upcoming;
    }

    String? regionValue() => _draft.region;
    String? cropValue() {
      if (_draft.crop == null && _draft.disease == null) return null;
      final parts = <String>[];
      if (_draft.crop != null) parts.add(_draft.crop!);
      if (_draft.disease != null) parts.add(_draft.disease!);
      return parts.join(' · ');
    }

    String? dateValue() {
      final d = _draft.transplantDate;
      if (d == null) return null;
      return DateFormat('M월 d일', 'ko_KR').format(d);
    }

    return [
      SetupStepData(label: '지역', state: stateOf(0), value: regionValue()),
      SetupStepData(label: '작물 · 병해충', state: stateOf(1), value: cropValue()),
      SetupStepData(label: '이앙일', state: stateOf(2), value: dateValue()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: _onBack,
        ),
        title: const Text('시작 설정'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: SetupStepIndicator(steps: _buildSteps()),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RegionSelectStep(draft: _draft),
                  CropSelectStep(draft: _draft),
                  TransplantDateStep(draft: _draft),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ElevatedButton(
                onPressed: _canProceed && !_saving ? _onPressed : null,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : Text(_buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

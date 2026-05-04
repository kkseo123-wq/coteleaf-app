import 'package:flutter/material.dart';
import '../models/skin_survey_data.dart';
import '../services/survey_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import 'survey_detail_screen.dart';

class SavedSurveysScreen extends StatefulWidget {
  const SavedSurveysScreen({super.key});

  @override
  State<SavedSurveysScreen> createState() => _SavedSurveysScreenState();
}

class _SavedSurveysScreenState extends State<SavedSurveysScreen> {
  List<SkinSurveyData> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    final surveys = await SurveyStorageService.loadAll();
    setState(() {
      _surveys = surveys;
      _isLoading = false;
    });
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '-';
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _getSkinTypeText(SkinSurveyData data) {
    final selected = data.skinTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selected.isEmpty) return '-';
    return selected.join(', ');
  }

  @override
  Widget build(BuildContext context) {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('저장된 설문 결과', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(height: 16),
                      Text(
                        '저장된 설문 결과가 없습니다.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: _surveys.length,
                  itemBuilder: (context, index) {
                    final survey = _surveys[index];
                    return Card(
                      elevation: 0,
                      color: Colors.white.withValues(alpha: 0.6),
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurveyDetailScreen(surveyData: survey),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${survey.gender ?? '-'} / ${survey.ageGroup ?? '-'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '피부유형: ${_getSkinTypeText(survey)}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(survey.savedAt),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: AppColors.textLight),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.textLight),
                                onPressed: () => _confirmDelete(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 설문 결과를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SurveyStorageService.deleteAt(index);
              _loadSurveys();
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

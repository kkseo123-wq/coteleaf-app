import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import '../models/skin_survey_data.dart';
import '../services/skin_analysis_service.dart';
import 'unified_result_screen.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final List<XFile> capturedImages;
  final List<String> angleLabels;
  final SkinSurveyData surveyData;

  const AnalysisLoadingScreen({
    super.key,
    required this.capturedImages,
    required this.angleLabels,
    required this.surveyData,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with SingleTickerProviderStateMixin {
  final SkinAnalysisService _service = SkinAnalysisService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _hasError = false;
  String _errorMessage = '';
  int _completedCount = 0;
  List<String> _imageStatuses = [];

  @override
  void initState() {
    super.initState();
    _imageStatuses = List.filled(widget.capturedImages.length, 'waiting');

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnalysis();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _hasError = false;
      _completedCount = 0;
      _imageStatuses = List.filled(widget.capturedImages.length, 'waiting');
    });

    try {
      final files = widget.capturedImages
          .map((xfile) => File(xfile.path))
          .toList();

      final result = await _service.analyzeMultipleImages(
        files,
        widget.angleLabels,
        onImageStatusChanged: (index, status) {
          if (mounted) {
            setState(() {
              _imageStatuses[index] = _getStatusLabel(status);
            });
          }
        },
        onProgressChanged: (completed, total) {
          if (mounted) {
            setState(() {
              _completedCount = completed;
            });
          }
        },
      );

      if (mounted) {
        // AI 측정 결과를 설문 데이터에 반영
        widget.surveyData.applyAIMeasurements(result.averageMeasurements);
        widget.surveyData.perceivedAge = result.perceivedAge;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UnifiedResultScreen(
              surveyData: widget.surveyData,
              aiResult: result,
            ),
          ),
        );
      }
    } on SkinAnalysisException catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = '분석 중 오류가 발생했습니다: $e';
        });
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'uploading':
        return '업로드 중';
      case 'processing':
        return '분석 중';
      case 'completed':
      case 'done':
      case 'succeeded':
        return '완료';
      case 'fetching_result':
        return '결과 수신 중';
      case 'waiting':
        return '대기 중';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('AI 피부 분석', style: TextStyle(fontWeight: FontWeight.w300)),
        leading: _hasError
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _hasError ? _buildErrorView() : _buildLoadingView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    final total = widget.capturedImages.length;
    final progress = total > 0 ? _completedCount / total : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 애니메이션 아이콘
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.face_retouching_natural,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          const Text(
            'AI가 피부를 분석하고 있습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '잠시만 기다려 주세요...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),

          // 전체 진행률 바
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_completedCount / $total 완료',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),

          // 이미지별 상태
          ...widget.angleLabels.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final status = index < _imageStatuses.length
                ? _imageStatuses[index]
                : '대기 중';
            final isDone = status == '완료';
            final isProcessing = status == '분석 중' || status == '업로드 중' || status == '결과 수신 중';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle_outline
                          : isProcessing
                              ? Icons.hourglass_top
                              : Icons.radio_button_unchecked,
                      color: isDone
                          ? AppColors.primary
                          : isProcessing
                              ? AppColors.warning
                              : AppColors.textLight,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    if (isProcessing)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Text(
                      status,
                      style: TextStyle(
                        color: isDone
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              '분석에 실패했습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startAnalysis,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('다시 시도', style: TextStyle(fontWeight: FontWeight.w400)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('돌아가기', style: TextStyle(fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

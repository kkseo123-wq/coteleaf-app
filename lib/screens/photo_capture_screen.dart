import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../theme/app_theme.dart';
import '../models/skin_survey_data.dart';
import '../services/image_quality_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'analysis_loading_screen.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final SkinSurveyData surveyData;

  const PhotoCaptureScreen({super.key, required this.surveyData});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  int _selectedPosition = 0;

  // 얼굴 피부 진단용 촬영 위치
  final List<CameraPositionData> _positions = [
    CameraPositionData(name: '정면', icon: '😐', description: '정면을 바라봐주세요', angle: 0),
    CameraPositionData(name: '좌측 45°', icon: '😏', description: '고개를 오른쪽으로 살짝 돌려주세요', angle: -45),
    CameraPositionData(name: '우측 45°', icon: '😏', description: '고개를 왼쪽으로 살짝 돌려주세요', angle: 45),
  ];

  final List<XFile?> _capturedImages = [null, null, null];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('피부 진단'),
        actions: [
          if (_capturedImages.where((img) => img != null).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_capturedImages.where((img) => img != null).length}/3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: () => _showGuideModal(context),
            child: const Text(
              '촬영 가이드',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildImagePreview(),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: const Border(top: BorderSide(color: Colors.white, width: 1.5)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPositionSelector(),
                    const SizedBox(height: 24),
                    _buildTips(),
                    const SizedBox(height: 24),
                    _buildButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final currentImage = _capturedImages[_selectedPosition];

    return Stack(
      alignment: Alignment.center,
      children: [
        // 촬영된 이미지 또는 placeholder
        if (currentImage != null)
          Positioned.fill(
            child: Image.file(
              File(currentImage.path),
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            color: AppColors.secondary,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(100), // 원형 가이드
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _positions[_selectedPosition].icon,
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _positions[_selectedPosition].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _positions[_selectedPosition].description,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 이미지가 있을 때 위치 표시
        if (currentImage != null)
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _positions[_selectedPosition].name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // 이미지가 있을 때 다시 촬영 버튼
        if (currentImage != null)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _openCamera(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '다시 촬영',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // placeholder일 때 가이드
        if (currentImage == null)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGuideChip(Icons.wb_sunny_outlined, '밝은 조명'),
                const SizedBox(width: 8),
                _buildGuideChip(Icons.face, '얼굴 전체'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGuideChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '촬영 각도 선택',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _positions.asMap().entries.map((entry) {
              final index = entry.key;
              final position = entry.value;
              final isSelected = _selectedPosition == index;
              final isCaptured = _capturedImages[index] != null;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPosition = index),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isCaptured
                          ? AppColors.success.withOpacity(0.2)
                          : isSelected
                              ? AppColors.primary
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCaptured
                            ? AppColors.success
                            : isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 각도에 따라 아이콘 회전
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..scale(position.angle < 0 ? -1.0 : 1.0, 1.0),
                              child: Text(
                                position.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            if (isCaptured)
                              const Positioned(
                                right: -8,
                                top: -8,
                                child: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          position.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected && !isCaptured
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '화장을 지우고 자연광에서 촬영하면 더 정확해요',
                style: TextStyle(fontSize: 13, color: AppColors.info),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final capturedCount = _capturedImages.where((img) => img != null).length;
    final allCaptured = capturedCount == 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: allCaptured
              ? () => _showAnalysisDialog()
              : () => _openCamera(context),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: allCaptured ? AppColors.primary : AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: Icon(allCaptured ? Icons.analytics : Icons.camera_alt, size: 20),
          label: Text(
            allCaptured ? '분석하기' : '촬영하기',
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1.0),
          ),
        ),
      ),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    final result = await Navigator.push<XFile>(
      context,
      MaterialPageRoute(
        builder: (context) => FaceCameraScreen(
          positionName: _positions[_selectedPosition].name,
          positionDescription: _positions[_selectedPosition].description,
          targetAngle: _positions[_selectedPosition].angle,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _capturedImages[_selectedPosition] = result;
      });

      // 다음 미촬영 위치로 자동 이동
      final nextUncaptured = _capturedImages.indexWhere((img) => img == null);
      if (nextUncaptured != -1) {
        setState(() {
          _selectedPosition = nextUncaptured;
        });
      }
    }
  }

  void _showAnalysisDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('촬영 완료'),
          ],
        ),
        content: const Text('3개 각도 촬영이 완료되었습니다.\nAI 피부 분석을 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _capturedImages.fillRange(0, 3, null);
                _selectedPosition = 0;
              });
            },
            child: const Text('다시 촬영'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final images = _capturedImages
                  .where((img) => img != null)
                  .cast<XFile>()
                  .toList();
              final labels = _positions.map((p) => p.name).toList();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalysisLoadingScreen(
                    capturedImages: images,
                    angleLabels: labels,
                    surveyData: widget.surveyData,
                  ),
                ),
              );
            },
            child: const Text('분석 시작'),
          ),
        ],
      ),
    );
  }

  void _showGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '촬영 가이드',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildGuideItem(
                    '💡',
                    '밝은 조명',
                    '자연광이나 밝은 조명 아래에서 촬영하세요',
                  ),
                  _buildGuideItem(
                    '🧴',
                    '민낯 상태',
                    '화장을 지우고 세안 후 촬영하면 더 정확해요',
                  ),
                  _buildGuideItem(
                    '😐',
                    '정면 촬영',
                    '카메라를 정면으로 바라보며 촬영하세요',
                  ),
                  _buildGuideItem(
                    '😏',
                    '측면 촬영',
                    '좌우 45도 각도로 고개를 돌려 촬영하세요',
                  ),
                  _buildGuideItem(
                    '🖼️',
                    '얼굴 전체',
                    '얼굴 전체가 화면에 들어오게 촬영하세요',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CameraPositionData {
  final String name;
  final String icon;
  final String description;
  final int angle; // 0: 정면, -45: 좌측, 45: 우측

  CameraPositionData({
    required this.name,
    required this.icon,
    required this.description,
    required this.angle,
  });
}

// 얼굴 촬영용 카메라 화면 (전면 카메라)
class FaceCameraScreen extends StatefulWidget {
  final String positionName;
  final String positionDescription;
  final int targetAngle;

  const FaceCameraScreen({
    super.key,
    required this.positionName,
    required this.positionDescription,
    required this.targetAngle,
  });

  @override
  State<FaceCameraScreen> createState() => _FaceCameraScreenState();
}

class _FaceCameraScreenState extends State<FaceCameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  bool _isAnalyzing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isCameraError = true;
          _errorMessage = '사용 가능한 카메라가 없습니다.';
        });
        return;
      }

      // 전면 카메라 선택 (셀카용)
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isCameraError = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCameraError = true;
        _errorMessage = '카메라 초기화 실패: ${e.toString()}';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();

      // 이미지 품질 분석
      final qualityResult = await ImageQualityService.analyzeImage(image.path);

      if (!mounted) return;

      if (qualityResult.isAcceptable) {
        // 품질 통과 - 결과 반환
        Navigator.pop(context, image);
      } else {
        // 품질 불합격 - 다시 촬영 안내
        setState(() {
          _isAnalyzing = false;
        });
        _showQualityFailureDialog(qualityResult, image);
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('촬영 실패: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showQualityFailureDialog(ImageQualityResult result, XFile image) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            SizedBox(width: 8),
            Text('이미지 품질 확인'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 품질 점수 표시
            _buildQualityScoreRow(
              '조도',
              ImageQualityService.getBrightnessPercent(result.brightnessScore),
              result.brightnessScore >= ImageQualityService.minBrightness &&
                  result.brightnessScore <= ImageQualityService.maxBrightness,
            ),
            const SizedBox(height: 8),
            _buildQualityScoreRow(
              '선명도',
              ImageQualityService.getSharpnessPercent(result.blurScore),
              result.blurScore >= ImageQualityService.minBlurScore,
            ),
            const SizedBox(height: 8),
            _buildQualityScoreRow(
              '노이즈',
              ImageQualityService.getNoisePercent(result.noiseScore),
              result.noiseScore <= ImageQualityService.maxNoiseScore,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '개선 필요 사항:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...result.issues.map((issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          issue,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context, image); // 그래도 사용
            },
            child: const Text('그래도 사용'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기, 카메라 유지
            },
            child: const Text('다시 촬영'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityScoreRow(String label, int score, bool isPassed) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPassed ? AppColors.success : AppColors.error,
              ),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isPassed ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: isPassed ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.positionName),
      ),
      body: Stack(
        children: [
          // 카메라 프리뷰
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else if (_isCameraError)
            _buildErrorView()
          else
            _buildLoadingView(),

          // 얼굴 가이드 프레임 (원형)
          if (_isCameraInitialized && !_isAnalyzing)
            Center(
              child: Container(
                width: 280,
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(140),
                ),
              ),
            ),

          // 각도 가이드 표시
          if (_isCameraInitialized && !_isAnalyzing)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: _buildAngleGuide(),
            ),

          // 분석 중 오버레이
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      '이미지 품질 분석 중...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // 상단 가이드
          if (!_isAnalyzing)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGuideChip(Icons.wb_sunny_outlined, '밝은 조명'),
                  const SizedBox(width: 8),
                  _buildGuideChip(Icons.face, '얼굴 전체'),
                ],
              ),
            ),

          // 하단 위치 설명 및 촬영 버튼
          if (!_isAnalyzing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.positionDescription,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isCameraInitialized ? _takePicture : null,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: _isCameraInitialized
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAngleGuide() {
    String guideText;
    IconData guideIcon;

    if (widget.targetAngle == 0) {
      guideText = '정면을 바라보세요';
      guideIcon = Icons.arrow_upward;
    } else if (widget.targetAngle < 0) {
      guideText = '← 고개를 오른쪽으로';
      guideIcon = Icons.arrow_back;
    } else {
      guideText = '고개를 왼쪽으로 →';
      guideIcon = Icons.arrow_forward;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.targetAngle < 0)
            Icon(guideIcon, color: Colors.white, size: 20),
          if (widget.targetAngle < 0)
            const SizedBox(width: 8),
          Text(
            guideText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.targetAngle > 0)
            const SizedBox(width: 8),
          if (widget.targetAngle > 0)
            Icon(guideIcon, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildGuideChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            '카메라 초기화 중...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _initializeCamera,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

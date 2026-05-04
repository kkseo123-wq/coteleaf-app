import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

class ImageQualityResult {
  final bool isAcceptable;
  final double brightnessScore;
  final double blurScore;
  final double noiseScore;
  final List<String> issues;

  ImageQualityResult({
    required this.isAcceptable,
    required this.brightnessScore,
    required this.blurScore,
    required this.noiseScore,
    required this.issues,
  });
}

class ImageQualityService {
  // 임계값 설정
  static const double minBrightness = 0.25; // 최소 밝기 (0~1)
  static const double maxBrightness = 0.85; // 최대 밝기 (0~1)
  static const double minBlurScore = 100.0; // 최소 선명도 (Laplacian variance)
  static const double maxNoiseScore = 30.0; // 최대 노이즈 레벨

  /// 이미지 품질 분석
  static Future<ImageQualityResult> analyzeImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return ImageQualityResult(
        isAcceptable: false,
        brightnessScore: 0,
        blurScore: 0,
        noiseScore: 0,
        issues: ['이미지를 읽을 수 없습니다.'],
      );
    }

    // 분석을 위해 이미지 리사이즈 (성능 최적화)
    final resized = img.copyResize(image, width: 400);

    final brightnessScore = _analyzeBrightness(resized);
    final blurScore = _analyzeBlur(resized);
    final noiseScore = _analyzeNoise(resized);

    final issues = <String>[];

    // 밝기 체크
    if (brightnessScore < minBrightness) {
      issues.add('이미지가 너무 어둡습니다. 밝은 곳에서 다시 촬영해주세요.');
    } else if (brightnessScore > maxBrightness) {
      issues.add('이미지가 너무 밝습니다. 직사광선을 피해 촬영해주세요.');
    }

    // 블러 체크
    if (blurScore < minBlurScore) {
      issues.add('이미지가 흐릿합니다. 카메라를 고정하고 다시 촬영해주세요.');
    }

    // 노이즈 체크
    if (noiseScore > maxNoiseScore) {
      issues.add('이미지에 노이즈가 많습니다. 조명을 밝게 하고 다시 촬영해주세요.');
    }

    return ImageQualityResult(
      isAcceptable: issues.isEmpty,
      brightnessScore: brightnessScore,
      blurScore: blurScore,
      noiseScore: noiseScore,
      issues: issues,
    );
  }

  /// 밝기 분석 (0~1 범위, 0.5가 적정)
  static double _analyzeBrightness(img.Image image) {
    double totalBrightness = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // RGB to luminance (perceived brightness)
        final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
        totalBrightness += luminance;
        pixelCount++;
      }
    }

    return totalBrightness / pixelCount;
  }

  /// 블러 분석 (Laplacian variance - 높을수록 선명)
  static double _analyzeBlur(img.Image image) {
    // Grayscale 변환
    final gray = img.grayscale(image);

    // Laplacian 커널 적용
    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        // 3x3 Laplacian
        final center = gray.getPixel(x, y).r.toDouble();
        final top = gray.getPixel(x, y - 1).r.toDouble();
        final bottom = gray.getPixel(x, y + 1).r.toDouble();
        final left = gray.getPixel(x - 1, y).r.toDouble();
        final right = gray.getPixel(x + 1, y).r.toDouble();

        final laplacian = (4 * center - top - bottom - left - right).abs();
        sum += laplacian;
        sumSq += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return 0;

    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);

    return variance;
  }

  /// 노이즈 분석 (인접 픽셀 차이의 표준편차)
  static double _analyzeNoise(img.Image image) {
    final gray = img.grayscale(image);

    List<double> differences = [];

    // 샘플링으로 성능 최적화
    final stepX = max(1, gray.width ~/ 100);
    final stepY = max(1, gray.height ~/ 100);

    for (int y = 0; y < gray.height - 1; y += stepY) {
      for (int x = 0; x < gray.width - 1; x += stepX) {
        final current = gray.getPixel(x, y).r.toDouble();
        final right = gray.getPixel(x + 1, y).r.toDouble();
        final bottom = gray.getPixel(x, y + 1).r.toDouble();

        differences.add((current - right).abs());
        differences.add((current - bottom).abs());
      }
    }

    if (differences.isEmpty) return 0;

    // 표준편차 계산
    final mean = differences.reduce((a, b) => a + b) / differences.length;
    final variance = differences.map((d) => pow(d - mean, 2)).reduce((a, b) => a + b) / differences.length;

    return sqrt(variance);
  }

  /// 품질 점수를 퍼센트로 변환 (UI 표시용)
  static int getBrightnessPercent(double score) {
    // 0.5가 100%가 되도록 조정
    if (score <= 0.5) {
      return (score / 0.5 * 100).round().clamp(0, 100);
    } else {
      return ((1 - score) / 0.5 * 100).round().clamp(0, 100);
    }
  }

  static int getSharpnessPercent(double blurScore) {
    // 200 이상이면 100%
    return (blurScore / 200 * 100).round().clamp(0, 100);
  }

  static int getNoisePercent(double noiseScore) {
    // 노이즈가 낮을수록 좋음
    return (100 - (noiseScore / maxNoiseScore * 100)).round().clamp(0, 100);
  }
}

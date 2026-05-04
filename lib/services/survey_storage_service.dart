import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skin_survey_data.dart';

class SurveyStorageService {
  static const _key = 'saved_skin_surveys';

  /// 설문 결과 저장
  static Future<void> save(SkinSurveyData data) async {
    data.savedAt = DateTime.now().toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    final list = await loadAll();
    list.insert(0, data); // 최신순
    final jsonList = list.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// 저장된 설문 전체 불러오기 (최신순)
  static Future<List<SkinSurveyData>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((s) => SkinSurveyData.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  /// 특정 인덱스의 설문 삭제
  static Future<void> deleteAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < jsonList.length) {
      jsonList.removeAt(index);
      await prefs.setStringList(_key, jsonList);
    }
  }
}

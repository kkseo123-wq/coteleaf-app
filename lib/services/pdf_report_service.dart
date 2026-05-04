import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/skin_survey_data.dart';

class PdfReportService {
  static Future<Uint8List> generate(SkinSurveyData data) async {
    final fontData = await rootBundle.load('assets/fonts/NotoSansKR.ttf');
    final ttf = pw.Font.ttf(fontData);
    final bold = ttf; // variable font - same file

    final pdf = pw.Document();
    final baseStyle = pw.TextStyle(font: ttf, fontSize: 10);
    final boldStyle = pw.TextStyle(font: bold, fontSize: 10, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(font: bold, fontSize: 14, fontWeight: pw.FontWeight.bold);
    final subHeaderStyle = pw.TextStyle(font: bold, fontSize: 11, fontWeight: pw.FontWeight.bold);
    final smallStyle = pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey700);

    final savedDate = data.savedAt != null
        ? DateTime.tryParse(data.savedAt!)
        : DateTime.now();
    final dateStr = savedDate != null
        ? '${savedDate.year}.${savedDate.month.toString().padLeft(2, '0')}.${savedDate.day.toString().padLeft(2, '0')}'
        : '-';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(dateStr, headerStyle, smallStyle),
        footer: (context) => _buildFooter(context, smallStyle),
        build: (context) => [
          // 기본 정보
          _sectionTitle('1. 기본정보', subHeaderStyle),
          _gap(8),
          _infoTable([
            ['성별', data.gender ?? '-'],
            ['연령대', data.ageGroup ?? '-'],
            ['피부유형', _selectedItems(data.skinTypes)],
            ['민족적 배경', data.ethnicity ?? '-'],
          ], baseStyle, boldStyle),

          _gap(16),

          // 피부관심
          _sectionTitle('2. 피부관심', subHeaderStyle),
          _gap(8),
          _chipList(_selectedItems(data.skinInterests), baseStyle),

          _gap(16),

          // 피부고민
          _sectionTitle('3. 피부고민', subHeaderStyle),
          _gap(8),
          _chipList(_selectedItems(data.skinConcerns), baseStyle),
          if (data.skinConcernsOther != null && data.skinConcernsOther!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text('기타: ${data.skinConcernsOther}', style: baseStyle),
            ),

          _gap(16),

          // 알러지
          _sectionTitle('4. 알러지 유무', subHeaderStyle),
          _gap(8),
          _infoTable([
            ['한약/허브/풀/콩', _allergyText(data.allergyHerb, data.allergyHerbDetail)],
            ['햇빛', _allergyText(data.allergySunlight, data.allergySunlightDetail)],
            ['화장품', _allergyText(data.allergyCosmetics, data.allergyCosmeticsBrand)],
          ], baseStyle, boldStyle),

          _gap(16),

          // 현재 사용 제품
          _sectionTitle('5. 현재 사용 제품', subHeaderStyle),
          _gap(8),
          _chipList(_selectedItems(data.currentProducts), baseStyle),
          if (data.productBrand != null && data.productBrand!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text('브랜드: ${data.productBrand}', style: baseStyle),
            ),
          if (data.usageFrequency != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text('사용 빈도: ${data.usageFrequency}', style: baseStyle),
            ),

          _gap(16),

          // 개선 목표
          _sectionTitle('6. 개선 목표', subHeaderStyle),
          _gap(8),
          _chipList(_selectedItems(data.improvementGoals), baseStyle),
          _infoTable([
            ['1순위', data.priorityFirst ?? '-'],
            ['2순위', data.prioritySecond ?? '-'],
          ], baseStyle, boldStyle),

          _gap(16),

          // 추천 조건
          _sectionTitle('7. 추천 조건', subHeaderStyle),
          _gap(8),
          _infoTable([
            ['선호 제형', _selectedItems(data.preferredFormula)],
            ['금액대', data.priceRange ?? '-'],
          ], baseStyle, boldStyle),

          _gap(16),

          // AI 리포트 연동
          _sectionTitle('8. AI 리포트 연동', subHeaderStyle),
          _gap(8),
          _infoTable([
            ['맞춤형 화장품 주문', data.wantRecommendation == true ? '예' : data.wantRecommendation == false ? '아니오' : '-'],
            ['2개월 후 재진단 알림', data.wantFollowUpAlert == true ? '예' : data.wantFollowUpAlert == false ? '아니오' : '-'],
          ], baseStyle, boldStyle),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String date, pw.TextStyle headerStyle, pw.TextStyle smallStyle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('피부 설문 리포트', style: headerStyle),
            pw.Text('작성일: $date', style: smallStyle),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.pink),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.TextStyle style) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated by Coteleaf App', style: style),
            pw.Text('${context.pageNumber} / ${context.pagesCount}', style: style),
          ],
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title, pw.TextStyle style) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.pink50,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(title, style: style),
    );
  }

  static pw.Widget _gap(double height) {
    return pw.SizedBox(height: height);
  }

  static pw.Widget _infoTable(List<List<String>> rows, pw.TextStyle baseStyle, pw.TextStyle boldStyle) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: rows.map((row) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text(row[0], style: boldStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text(row[1], style: baseStyle),
            ),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _chipList(String items, pw.TextStyle style) {
    if (items == '선택 없음') {
      return pw.Text(items, style: style);
    }
    final list = items.split(', ');
    return pw.Wrap(
      spacing: 6,
      runSpacing: 4,
      children: list.map((item) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.pink300),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(item, style: style),
        );
      }).toList(),
    );
  }

  static String _selectedItems(Map<String, bool> map) {
    final selected = map.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selected.isEmpty) return '선택 없음';
    return selected.join(', ');
  }

  static String _allergyText(bool? has, String? detail) {
    if (has == null) return '-';
    if (has == false) return '없다';
    final d = (detail != null && detail.isNotEmpty) ? ' ($detail)' : '';
    return '있다$d';
  }
}

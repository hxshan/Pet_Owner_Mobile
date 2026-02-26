import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class MealPlanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> plan;

  const MealPlanDetailsScreen({
    Key? key,
    required this.plan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final profile = (plan['profile'] as Map?)?.cast<String, dynamic>() ?? {};
    final nutrition = (plan['nutrition'] as Map?)?.cast<String, dynamic>() ?? {};
    final meals = (plan['meals'] as List?)?.cast<dynamic>() ?? [];
    final warnings =
        (plan['warnings'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final tips = (plan['tips'] as List?)?.map((e) => e.toString()).toList() ?? [];

    final petName = (plan['petName'] ?? 'Pet').toString();
    final petBreed = (profile['breed'] ?? '').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, sw, sh),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPetInfo(
                      sw,
                      sh,
                      petName.isEmpty ? 'Pet' : petName,
                      petBreed,
                    ),
                    SizedBox(height: sh * 0.02),
                    _buildNutritionSummary(sw, sh, nutrition),
                    SizedBox(height: sh * 0.02),

                    _sectionTitle(sw, 'Daily Meal Plan'),
                    SizedBox(height: sh * 0.01),
                    ...meals
                        .map((m) => _mealCard(
                            sw, sh, (m as Map).cast<String, dynamic>()))
                        .toList(),

                    SizedBox(height: sh * 0.02),
                    if (warnings.isNotEmpty) ...[
                      _sectionTitle(sw, 'Warnings'),
                      _bullets(sw, warnings),
                      SizedBox(height: sh * 0.02),
                    ],

                    if (tips.isNotEmpty) ...[
                      _sectionTitle(sw, 'Tips'),
                      _bullets(sw, tips),
                      SizedBox(height: sh * 0.02),
                    ],

                    _downloadButton(
                      context: context,
                      sw: sw,
                      sh: sh,
                      petName: petName.isEmpty ? 'Pet' : petName,
                      petBreed: petBreed,
                      profile: profile,
                      nutrition: nutrition,
                      meals: meals,
                      warnings: warnings,
                      tips: tips,
                    ),

                    SizedBox(height: sh * 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _downloadButton({
    required BuildContext context,
    required double sw,
    required double sh,
    required String petName,
    required String petBreed,
    required Map<String, dynamic> profile,
    required Map<String, dynamic> nutrition,
    required List<dynamic> meals,
    required List<String> warnings,
    required List<String> tips,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPink,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: sh * 0.016),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            await _downloadPdf(
              context: context,
              petName: petName,
              petBreed: petBreed,
              profile: profile,
              nutrition: nutrition,
              meals: meals,
              warnings: warnings,
              tips: tips,
            );
          },
          icon: Icon(Icons.download_rounded, size: sw * 0.055),
          label: Text(
            'Download PDF',
            style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdf({
    required BuildContext context,
    required String petName,
    required String petBreed,
    required Map<String, dynamic> profile,
    required Map<String, dynamic> nutrition,
    required List<dynamic> meals,
    required List<String> warnings,
    required List<String> tips,
  }) async {
    try {
      _showSnack(context, 'Generating PDF...', isLoading: true);

      final pdfBytes = await _buildPdfBytes(
        petName: petName,
        petBreed: petBreed,
        profile: profile,
        nutrition: nutrition,
        meals: meals,
        warnings: warnings,
        tips: tips,
      );

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final fileName = _safeFileName('Meal_Plan_$dateStr.pdf');

       final docsDir = await getApplicationDocumentsDirectory();
      final filePath = p.join(docsDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnack(context, 'Saved: $fileName');
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnack(context, 'Failed to download PDF: $e');
    }
  }

  void _showSnack(BuildContext context, String msg, {bool isLoading = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isLoading) ...[
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(msg)),
          ],
        ),
        duration: isLoading ? const Duration(minutes: 1) : const Duration(seconds: 3),
      ),
    );
  }

  String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  
  Future<Uint8List> _buildPdfBytes({
    required String petName,
    required String petBreed,
    required Map<String, dynamic> profile,
    required Map<String, dynamic> nutrition,
    required List<dynamic> meals,
    required List<String> warnings,
    required List<String> tips,
  }) async {
    final doc = pw.Document();

    String v(String key, {String suffix = ''}) {
      final x = nutrition[key];
      if (x is num) return '${x.toStringAsFixed(2)}$suffix';
      return '0$suffix';
    }

    String vInt(String key, {String suffix = ''}) {
      final x = nutrition[key];
      if (x is num) return '${x.toInt()}$suffix';
      return '0$suffix';
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'Meal Plan Details',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Pet: $petName',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (petBreed.trim().isNotEmpty) pw.Text('Breed: $petBreed'),
                pw.SizedBox(height: 6),
                pw.Text('Plan valid for 14 days'),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          pw.Text('Nutrition Summary',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _pdfRow('Protein', v('protein_g', suffix: ' g')),
              _pdfRow('Carbs', v('carbs_g', suffix: ' g')),
              _pdfRow('Fats', v('fats_g', suffix: ' g')),
              _pdfRow('Calories', v('calories_kcal', suffix: ' kcal')),
              _pdfRow('Meals per day', vInt('meals_per_day')),
            ],
          ),
          pw.SizedBox(height: 14),

          pw.Text('Daily Meal Plan',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),

          ...meals.map((m) {
            final meal = (m as Map).cast<String, dynamic>();
            final title = (meal['title'] ?? 'Meal').toString();
            final timeLabel = (meal['timeLabel'] ?? '').toString();
            final ingredients = (meal['ingredients'] as List?)?.cast<dynamic>() ?? [];

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  if (timeLabel.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        timeLabel,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ),
                  pw.SizedBox(height: 8),
                  pw.Text('Ingredients:',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  ...ingredients.map((ing) {
                    final mm = (ing as Map).cast<String, dynamic>();
                    final food = (mm['food'] ?? '').toString();
                    final grams = (mm['grams'] ?? 0).toString();
                    return pw.Bullet(text: '$food — $grams g');
                  }).toList(),
                ],
              ),
            );
          }).toList(),

          if (warnings.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Warnings',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...warnings.map((w) => pw.Bullet(text: w)).toList(),
          ],

          if (tips.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Tips',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...tips.map((t) => pw.Bullet(text: t)).toList(),
          ],
        ],
      ),
    );

    return doc.save();
  }

  pw.TableRow _pdfRow(String left, String right) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(right),
        ),
      ],
    );
  }

 
  Widget _buildHeader(BuildContext context, double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      child: Row(
        children: [
          CustomBackButton(showPadding: false),
          Expanded(
            child: Center(
              child: Text(
                'Meal Plan Details',
                style: TextStyle(
                  fontSize: sw * 0.048,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPetInfo(double sw, double sh, String petName, String petBreed) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mainColor.withOpacity(0.4),
            AppColors.darkPink.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.18,
            height: sw * 0.18,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.pets, size: sw * 0.09, color: Colors.grey[400]),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(petName, style: TextStyle(fontSize: sw * 0.055, fontWeight: FontWeight.bold)),
                SizedBox(height: sh * 0.005),
                Text(petBreed, style: TextStyle(fontSize: sw * 0.038, color: Colors.black54)),
                SizedBox(height: sh * 0.008),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.006),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(sw * 0.015)),
                  child: Text(
                    'Plan valid for 14 days',
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(double sw, double sh, Map<String, dynamic> nutrition) {
    String v(String key, {String suffix = ''}) {
      final x = nutrition[key];
      if (x is num) return '${x.toStringAsFixed(2)}$suffix';
      return '0$suffix';
    }

    String vInt(String key, {String suffix = ''}) {
      final x = nutrition[key];
      if (x is num) return '${x.toInt()}$suffix';
      return '0$suffix';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPink, AppColors.mainColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Nutrition Summary',
            style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: sh * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nutItem(sw, sh, v('protein_g', suffix: 'g'), 'Protein', Icons.fitness_center),
              _nutItem(sw, sh, v('carbs_g', suffix: 'g'), 'Carbs', Icons.bakery_dining),
              _nutItem(sw, sh, v('fats_g', suffix: 'g'), 'Fats', Icons.water_drop),
            ],
          ),
          SizedBox(height: sh * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _nutItem(sw, sh, v('calories_kcal'), 'kcal', Icons.local_fire_department),
              _nutItem(sw, sh, vInt('meals_per_day'), 'meals', Icons.restaurant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutItem(double sw, double sh, String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(sw * 0.025),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(icon, size: sw * 0.06, color: Colors.white),
        ),
        SizedBox(height: sh * 0.008),
        Text(value, style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: sw * 0.03, color: Colors.white70)),
      ],
    );
  }

  Widget _sectionTitle(double sw, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _mealCard(double sw, double sh, Map<String, dynamic> meal) {
    final title = (meal['title'] ?? 'Meal').toString();
    final timeLabel = (meal['timeLabel'] ?? '').toString();
    final ingredients = (meal['ingredients'] as List?)?.cast<dynamic>() ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sh * 0.008),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(sw * 0.04),
                topRight: Radius.circular(sw * 0.04),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.025),
                  decoration: BoxDecoration(
                    color: AppColors.darkPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Icon(Icons.restaurant_menu, size: sw * 0.055, color: AppColors.darkPink),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: sw * 0.042, fontWeight: FontWeight.bold)),
                      SizedBox(height: sh * 0.003),
                      Text(timeLabel, style: TextStyle(fontSize: sw * 0.032, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingredients', style: TextStyle(fontSize: sw * 0.036, fontWeight: FontWeight.bold)),
                SizedBox(height: sh * 0.01),
                ...ingredients.map((ing) {
                  final m = (ing as Map).cast<String, dynamic>();
                  final food = (m['food'] ?? '').toString();
                  final grams = (m['grams'] ?? 0).toString();

                  return Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.008),
                    child: Row(
                      children: [
                        Container(
                          width: sw * 0.015,
                          height: sw * 0.015,
                          decoration: const BoxDecoration(color: AppColors.darkPink, shape: BoxShape.circle),
                        ),
                        SizedBox(width: sw * 0.025),
                        Expanded(child: Text(food, style: TextStyle(fontSize: sw * 0.035))),
                        Text(
                          '$grams g',
                          style: TextStyle(
                            fontSize: sw * 0.034,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullets(double sw, List<String> items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: Column(
        children: items
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(t)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
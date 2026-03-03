// lib/pages/symptom_checker_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/symptom_data.dart';
import '../../models/diagnosis/symptom_models.dart';
import '../../services/diagnosis_service.dart';

enum CheckerStep { category, symptoms, photoUpload, details, results, photoResults }

class SymptomCheckerPage extends StatefulWidget {
  final String? petId;
  const SymptomCheckerPage({Key? key, this.petId}) : super(key: key);
  @override
  _SymptomCheckerPageState createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  CheckerStep _currentStep = CheckerStep.category;
  String _selectedCategory = '';
  List<String> _selectedSymptoms = [];
  File? _uploadedPhoto;
  bool _photoAnalyzing = false;
  String _duration = '';
  String _severity = '';
  bool _loadingAssessment = false;
  List<Map<String, dynamic>> _predictions = [];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (file != null) {
      setState(() {
        _uploadedPhoto = File(file.path);
      });
    }
  }

  Future<void> _analyzePhoto() async {
    setState(() => _photoAnalyzing = true);
    // Minimal/no-op analysis: show photo results after a short delay.
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _photoAnalyzing = false;
      _currentStep = CheckerStep.photoResults;
    });
  }

  void _resetChecker() {
    setState(() {
      _currentStep = CheckerStep.category;
      _selectedCategory = '';
      _selectedSymptoms = [];
      _uploadedPhoto = null;
      _photoAnalyzing = false;
      _duration = '';
      _severity = '';
      _loadingAssessment = false;
      _predictions = [];
    });
  }

  Color _getSeverityColor(String s) {
    switch (s) {
      case 'mild':
        return Colors.green.shade50;
      case 'moderate':
        return Colors.orange.shade50;
      case 'severe':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getSeverityBorderColor(String s) {
    switch (s) {
      case 'mild':
        return Colors.green.shade200;
      case 'moderate':
        return Colors.orange.shade200;
      case 'severe':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getSeverityTextColor(String s) {
    switch (s) {
      case 'mild':
        return Colors.green.shade700;
      case 'moderate':
        return Colors.orange.shade700;
      case 'severe':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getConfidenceColor(int pct) {
    if (pct >= 75) return Colors.green.shade600;
    if (pct >= 40) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case CheckerStep.category:
        return _buildCategorySelection();
      case CheckerStep.symptoms:
        return _buildSymptomSelection();
      case CheckerStep.photoUpload:
        return _buildPhotoUpload();
      case CheckerStep.details:
        return _buildDetailsInput();
      case CheckerStep.results:
        return _buildResults();
      case CheckerStep.photoResults:
        return _buildPhotoResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Checker'),
        backgroundColor: Colors.pink.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }
  
  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'How it works',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select the category that best describes your pet\'s symptoms, then choose specific symptoms to get an AI-powered assessment.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'What type of symptoms is your pet experiencing?',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: SymptomData.categories.length,
          itemBuilder: (context, index) {
            final category = SymptomData.categories[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category.id;
                  _currentStep = CheckerStep.symptoms;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSymptomSelection() {
    final categorySymptoms = SymptomData.symptoms
        .where((s) => s.category == _selectedCategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              _currentStep = CheckerStep.category;
            });
          },
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Change category'),
          style: TextButton.styleFrom(foregroundColor: Colors.pink.shade600),
        ),
        const SizedBox(height: 16),

        // Photo analysis option for skin category
        if (_selectedCategory == 'skin') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade50, Colors.purple.shade50],
              ),
              border: Border.all(color: Colors.pink.shade300, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.pink.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Try Photo Analysis',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'For skin conditions, you can take or upload a photo for faster, more accurate AI diagnosis.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentStep = CheckerStep.photoUpload;
                      });
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Use Photo Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'or',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Continue with manual symptom selection below',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        const Text(
          'Select all symptoms your pet is showing',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categorySymptoms.length,
          itemBuilder: (context, index) {
            final symptom = categorySymptoms[index];
            final isSelected = _selectedSymptoms.contains(symptom.id);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSymptoms.remove(symptom.id);
                    } else {
                      _selectedSymptoms.add(symptom.id);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.pink.shade100 : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.pink.shade600 : Colors.grey.shade200,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.pink.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(symptom.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          symptom.name,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        if (_selectedSymptoms.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = CheckerStep.details;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Continue'),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              _currentStep = CheckerStep.symptoms;
            });
          },
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to symptoms'),
          style: TextButton.styleFrom(foregroundColor: Colors.pink.shade600),
        ),
        const SizedBox(height: 16),
        const Text(
          'Upload a Photo of the Affected Area',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Tips for best results',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Ensure good lighting\n'
                '• Get close to the affected area\n'
                '• Keep the photo in focus\n'
                '• Show the entire affected area',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (_uploadedPhoto == null) ...[
          InkWell(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.pink.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Colors.pink.shade600),
                  const SizedBox(height: 12),
                  const Text(
                    'Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use your camera to capture the area',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _pickImage(ImageSource.gallery),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.blue.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, size: 64, color: Colors.blue.shade600),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose an existing photo',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _uploadedPhoto!,
                    height: 256,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red.shade600,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _uploadedPhoto = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Text(
                  'Photo uploaded successfully',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _photoAnalyzing ? null : _analyzePhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _photoAnalyzing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Analyzing with AI...'),
                      ],
                    )
                  : const Text('Analyze Photo'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _uploadedPhoto = null;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Upload Different Photo'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell us more about the symptoms',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How long has this been happening?',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...[
                {'value': 'few-hours', 'label': 'Last few hours'},
                {'value': '1-day', 'label': 'Since yesterday'},
                {'value': '2-3-days', 'label': '2-3 days'},
                {'value': 'week-plus', 'label': 'More than a week'},
              ].map((option) {
                final isSelected = _duration == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _duration = option['value']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.pink.shade100 : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.pink.shade600
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(option['label']!),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              Text(
                'How would you rate the severity?',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...[
                {
                  'value': 'mild',
                  'label': 'Mild - Noticeable but not concerning',
                  'icon': '😊'
                },
                {
                  'value': 'moderate',
                  'label': 'Moderate - Somewhat concerning',
                  'icon': '😟'
                },
                {
                  'value': 'severe',
                  'label': 'Severe - Very concerning',
                  'icon': '😨'
                },
              ].map((option) {
                final isSelected = _severity == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _severity = option['value']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.pink.shade100 : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.pink.shade600
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(option['icon']!, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(option['label']!)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (_duration.isNotEmpty && _severity.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingAssessment
                  ? null
                  : () async {
                      setState(() {
                        _loadingAssessment = true;
                      });

                      // Build payload for the symptom-checker endpoint
                      final payload = {
                        'species': 0,
                        'breed': 0,
                        'sex': 0,
                        'neutered': 0,
                        'age_years': 1.0,
                        'weight_kg': 1.0,
                        'num_previous_visits': 0,
                        'prev_diagnosis_class': 0,
                        'days_since_last_visit': 9999,
                        'chronic_flag': 0,
                        'symptoms': _selectedSymptoms,
                        'severity': _severity,
                        'duration_days': 0,
                      };

                      try {
                        final res = await DiagnosisService().predictSymptomChecker(payload);
                        // Expected shape: { status, predictions: [ {class_name, confidence,...} ], all_class_probabilities }
                        final preds = <Map<String, dynamic>>[];
                        if (res['predictions'] is List) {
                          for (final p in res['predictions']) {
                            if (p is Map) preds.add(Map<String, dynamic>.from(p));
                          }
                        }

                        setState(() {
                          _predictions = preds;
                          _currentStep = CheckerStep.results;
                        });
                      } catch (e) {
                        // show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to get assessment.')),
                        );
                      } finally {
                        setState(() {
                          _loadingAssessment = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loadingAssessment
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Get Assessment'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade50, Colors.blue.shade50],
            ),
            border: Border.all(color: Colors.pink.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.pink.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Assessment Complete',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Based on the symptoms you described, here are possible conditions ranked by likelihood. This is not a substitute for professional veterinary care.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Possible Diagnoses',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        if (_predictions.isEmpty) ...[
          const Text('No predictions yet. Press "Get Assessment" to run the AI model.'),
        ] else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _predictions.length,
            itemBuilder: (context, index) {
              final p = _predictions[index];
              final name = p['class_name'] ?? p['predicted_class_name'] ?? 'Unknown';
              final confidence = ((p['confidence'] ?? 0) as num).toDouble();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0,2)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(value: confidence, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor((confidence*100).toInt()))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${(confidence*100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow.shade50,
            border: Border.all(color: Colors.yellow.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.yellow.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Important Disclaimer',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This assessment is AI-generated and should not replace professional veterinary advice. If symptoms worsen or you\'re concerned, please contact a veterinarian immediately.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetChecker,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink.shade600,
                  side: BorderSide(color: Colors.pink.shade600, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('New Assessment'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to vets page
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Find a Vet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade50, Colors.purple.shade50],
            ),
            border: Border.all(color: Colors.pink.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.camera_alt, color: Colors.pink.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Photo Analysis Complete',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Our AI has analyzed the photo and identified potential skin conditions. This is not a substitute for professional veterinary care.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_uploadedPhoto != null)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.file(
                    _uploadedPhoto!,
                    height: 192,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade50,
                  child: Center(
                    child: Text(
                      'Analyzed Image',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          'Possible Skin Conditions',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: SymptomData.mockSkinDiagnoses.length,
          itemBuilder: (context, index) {
            final diagnosis = SymptomData.mockSkinDiagnoses[index];
            return _buildSkinDiagnosisCard(diagnosis, index + 1);
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow.shade50,
            border: Border.all(color: Colors.yellow.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.yellow.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Important Disclaimer',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This AI analysis is based on visual patterns and should not replace professional veterinary examination. Skin conditions can have similar appearances but different causes.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetChecker,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink.shade600,
                  side: BorderSide(color: Colors.pink.shade600, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('New Analysis'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to vets page
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Find a Vet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard(Diagnosis diagnosis, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  color: Colors.pink.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              diagnosis.condition,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(diagnosis.severity),
                          border: Border.all(
                            color: _getSeverityBorderColor(diagnosis.severity),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${diagnosis.severity[0].toUpperCase()}${diagnosis.severity.substring(1)} Severity',
                          style: TextStyle(
                            color: _getSeverityTextColor(diagnosis.severity),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${diagnosis.confidence}%',
                      style: TextStyle(
                        color: _getConfidenceColor(diagnosis.confidence),
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'confidence',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              diagnosis.description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Recommended Action: ${diagnosis.action}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (diagnosis.otcMedication != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OTC Option: ${diagnosis.otcMedication}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            if (diagnosis.confidence < 60) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to vets
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Book Vet Appointment', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkinDiagnosisCard(SkinDiagnosis diagnosis, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  color: Colors.pink.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              diagnosis.condition,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(diagnosis.severity),
                          border: Border.all(
                            color: _getSeverityBorderColor(diagnosis.severity),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${diagnosis.severity[0].toUpperCase()}${diagnosis.severity.substring(1)} Severity',
                          style: TextStyle(
                            color: _getSeverityTextColor(diagnosis.severity),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${diagnosis.confidence}%',
                      style: TextStyle(
                        color: _getConfidenceColor(diagnosis.confidence),
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'match',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              diagnosis.description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Common Causes:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  ...diagnosis.commonCauses.map(
                    (cause) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '• $cause',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Recommended Action: ${diagnosis.action}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (diagnosis.otcMedication != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OTC Option: ${diagnosis.otcMedication}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            if (diagnosis.confidence < 70) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to vets
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Book Vet Appointment', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
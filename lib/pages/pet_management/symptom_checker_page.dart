// lib/pages/symptom_checker_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/symptom_data.dart';
import '../../models/diagnosis/symptom_models.dart';  
import '../../services/pet_service.dart';

enum CheckerStep { category, symptoms, details, results, photoUpload, photoResults }

class SymptomCheckerPage extends StatefulWidget {
  final String? petId;

  const SymptomCheckerPage({Key? key, this.petId}) : super(key: key);

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  CheckerStep _currentStep = CheckerStep.category;
  String _selectedCategory = '';
  List<String> _selectedSymptoms = [];
  String? _petName;
  String _duration = '';
  String _severity = '';
  File? _uploadedPhoto;
  bool _photoAnalyzing = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // If a petId was passed, fetch pet metadata to show the friendly name
    if (widget.petId != null && widget.petId!.isNotEmpty) {
      PetService().getPetById(widget.petId!).then((data) {
        setState(() {
          _petName = (data['name'] ?? '') as String;
        });
      }).catchError((e) {
        // ignore - keep showing id if name fetch fails
      });
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.green.shade100;
      case 'medium':
        return Colors.yellow.shade100;
      case 'high':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getSeverityBorderColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.green.shade300;
      case 'medium':
        return Colors.yellow.shade300;
      case 'high':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getSeverityTextColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.green.shade700;
      case 'medium':
        return Colors.yellow.shade900;
      case 'high':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 70) return Colors.green.shade600;
    if (confidence >= 50) return Colors.yellow.shade700;
    return Colors.red.shade600;
  }

  double _getProgressValue() {
    switch (_currentStep) {
      case CheckerStep.category:
        return 0.25;
      case CheckerStep.symptoms:
      case CheckerStep.photoUpload:
        return 0.50;
      case CheckerStep.details:
        return 0.75;
      case CheckerStep.results:
      case CheckerStep.photoResults:
        return 1.0;
    }
  }

  String _getStepLabel() {
    switch (_currentStep) {
      case CheckerStep.category:
        return 'Category';
      case CheckerStep.symptoms:
        return 'Symptoms';
      case CheckerStep.photoUpload:
        return 'Photo';
      case CheckerStep.details:
        return 'Details';
      case CheckerStep.results:
      case CheckerStep.photoResults:
        return 'Results';
    }
  }

  int _getStepNumber() {
    switch (_currentStep) {
      case CheckerStep.category:
        return 1;
      case CheckerStep.symptoms:
      case CheckerStep.photoUpload:
        return 2;
      case CheckerStep.details:
        return 3;
      case CheckerStep.results:
      case CheckerStep.photoResults:
        return 4;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _uploadedPhoto = File(image.path);
      });
    }
  }

  Future<void> _analyzePhoto() async {
    setState(() {
      _photoAnalyzing = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
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
      _duration = '';
      _severity = '';
      _uploadedPhoto = null;
      _photoAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.pink.shade600,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Symptom Checker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _petName != null && _petName!.isNotEmpty
                              ? 'For: ${_petName}'
                              : (widget.petId != null && widget.petId!.isNotEmpty ? 'For pet: ${widget.petId}' : 'AI-powered health assessment'),
                          style: TextStyle(
                            color: Colors.pink.shade100,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_getStepNumber()} of 4',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getStepLabel(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _getProgressValue(),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade600),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
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
              onPressed: () {
                setState(() {
                  _currentStep = CheckerStep.results;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Get Assessment'),
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: SymptomData.mockDiagnoses.length,
          itemBuilder: (context, index) {
            final diagnosis = SymptomData.mockDiagnoses[index];
            return _buildDiagnosisCard(diagnosis, index + 1);
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
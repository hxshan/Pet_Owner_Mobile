// lib/pages/pet_management/symptom_checker_page.dart

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../consts/cnn_skin_conditions.dart';
import '../../data/symptom_data.dart';
import '../../models/diagnosis/symptom_models.dart';
import '../../services/diagnosis_service.dart';
import '../../services/pet_service.dart';
import '../../consts/diagnosis_predictions_constants.dart';
import '../../theme/app_colors.dart';

enum CheckerStep { landing, symptoms, photoUpload, details, results, photoResults }

class SymptomCheckerPage extends StatefulWidget {
  final String? petId;
  const SymptomCheckerPage({Key? key, this.petId}) : super(key: key);
  @override
  _SymptomCheckerPageState createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  CheckerStep _currentStep = CheckerStep.landing;
  List<String> _selectedSymptoms = [];
  File? _uploadedPhoto;
  bool _photoAnalyzing = false;
  String _photoPhase = '';         // animated loading phase text
  Timer? _phaseTimer;
  List<Map<String, dynamic>> _cnnPredictions = [];  // top_k from CNN API

  // Pet context  prefilled from API, user fills in anything missing
  bool _petLoading = false;
  String _petName = '';
  String _petBreed = 'Unknown';
  double _petAgeYears = 1.0;
  double _petWeightKg = 5.0;
  String _species = '';    // 'dog' | 'cat'
  String _sex = '';        // 'male' | 'female'
  String _neutered = '';   // 'yes' | 'no'
  String _vaccinated = ''; // '1' | '0'

  bool _loadingAssessment = false;
  List<Map<String, dynamic>> _predictions = [];

  @override
  void initState() {
    super.initState();
    if (widget.petId != null) _loadPetData(widget.petId!);
  }

  Future<void> _loadPetData(String petId) async {
    setState(() => _petLoading = true);
    try {
      final data = await PetService().getPetById(petId);
      setState(() {
        // Name
        _petName = (data['name'] as String?) ?? '';

        // Species: "Dog" ? 'dog', "Cat" ? 'cat'
        final rawSpecies = (data['species'] as String? ?? '').toLowerCase();
        if (rawSpecies == 'dog' || rawSpecies == 'cat') _species = rawSpecies;

        // Breed
        _petBreed = (data['breed'] as String? ?? 'Unknown');
        if (_petBreed.isEmpty) _petBreed = 'Unknown';

        // Sex / gender: "Male" ? 'male', "Female" ? 'female', "Unknown" ? ''
        final rawGender = (data['gender'] as String? ?? '').toLowerCase();
        if (rawGender == 'male' || rawGender == 'female') _sex = rawGender;

        // Neutered: boolean field
        final neuteredVal = data['neutered'];
        if (neuteredVal is bool) {
          _neutered = neuteredVal ? 'yes' : 'no';
        }

        // Vaccinated: non-empty vaccinations array means vaccinated
        final vax = data['vaccinations'];
        if (vax is List) {
          _vaccinated = vax.isNotEmpty ? '1' : '0';
        }

        // Weight: last entry in weightHistory
        final wh = data['weightHistory'];
        if (wh is List && wh.isNotEmpty) {
          final lastWeight = (wh.last['weight'] as num?)?.toDouble();
          if (lastWeight != null && lastWeight > 0) _petWeightKg = lastWeight;
        }

        // Age: use computedAge (years) if available
        final age = data['computedAge'] ?? data['age'];
        if (age != null) {
          final ageNum = (age as num).toDouble();
          if (ageNum > 0) _petAgeYears = ageNum;
        }
      });
    } catch (_) {
      // If fetch fails, user will fill in all fields manually
    } finally {
      setState(() => _petLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file =
        await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (file != null) setState(() => _uploadedPhoto = File(file.path));
  }

  static const _loadingPhases = [
    'Looking at the image',
    'Identifying patterns',
    'Analysing skin condition',
    'Cross-referencing database',
    'Thinking',
    'Almost there',
  ];

  void _startPhaseAnimation() {
    int idx = 0;
    setState(() => _photoPhase = _loadingPhases[0]);
    _phaseTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      idx = (idx + 1) % _loadingPhases.length;
      if (mounted) setState(() => _photoPhase = _loadingPhases[idx]);
    });
  }

  void _stopPhaseAnimation() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
  }

  Future<void> _analyzePhoto() async {
    setState(() {
      _photoAnalyzing = true;
      _cnnPredictions = [];
    });
    _startPhaseAnimation();
    try {
      final result = await DiagnosisService().predictCnn(_uploadedPhoto!);
      final topK = result['top_k'];
      final preds = <Map<String, dynamic>>[];
      if (topK is List) {
        for (final p in topK) {
          if (p is Map) preds.add(Map<String, dynamic>.from(p));
        }
      }
      if (!mounted) return;
      setState(() {
        _cnnPredictions = preds;
        _currentStep = CheckerStep.photoResults;
      });
    } catch (e) {
      if (!mounted) return;
      String msg = 'Photo analysis failed. Please try again.';
      if (e is DioException) {
        if (e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionTimeout) {
          msg = 'Analysis is taking too long. Please try again in a moment.';
        } else if (e.response?.statusCode != null) {
          msg = 'Server error (${e.response!.statusCode}). Please try again.';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
      );
    } finally {
      _stopPhaseAnimation();
      if (mounted) setState(() => _photoAnalyzing = false);
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _resetChecker() {
    _stopPhaseAnimation();
    setState(() {
      _currentStep = CheckerStep.landing;
      _selectedSymptoms = [];
      _uploadedPhoto = null;
      _photoAnalyzing = false;
      _photoPhase = '';
      _cnnPredictions = [];
      _petName = '';
      _petBreed = 'Unknown';
      _petAgeYears = 1.0;
      _petWeightKg = 5.0;
      _species = '';
      _sex = '';
      _neutered = '';
      _vaccinated = '';
      _loadingAssessment = false;
      _predictions = [];
    });
    // Re-fetch pet data so prefills are restored on restart
    if (widget.petId != null) _loadPetData(widget.petId!);
  }

  /// Converts a PascalCase class name like "TickFever" ? "Tick Fever"
  String _formatClassName(String name) {
    return name.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'),
      (m) => ' ',
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case CheckerStep.landing:
        return _buildLanding();
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

  // Returns true if we're past the landing screen (so back should step back, not pop)
  bool get _isOnSubStep => _currentStep != CheckerStep.landing;

  void _handleBack() {
    switch (_currentStep) {
      case CheckerStep.landing:
        Navigator.of(context).maybePop();
        break;
      case CheckerStep.symptoms:
        setState(() => _currentStep = CheckerStep.landing);
        break;
      case CheckerStep.photoUpload:
        setState(() {
          _uploadedPhoto = null;
          _currentStep = CheckerStep.landing;
        });
        break;
      case CheckerStep.details:
        setState(() => _currentStep = CheckerStep.symptoms);
        break;
      case CheckerStep.results:
        setState(() => _currentStep = CheckerStep.details);
        break;
      case CheckerStep.photoResults:
        setState(() {
          _cnnPredictions = [];
          _currentStep = CheckerStep.photoUpload;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isOnSubStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: const Text(
            'Symptom Checker',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.darkPink,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  // -- Landing ----------------------------------------------------------------
  Widget _buildLanding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Describe your pet\'s symptoms for an AI-powered health assessment, or upload a photo of a skin condition for visual analysis.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'How would you like to proceed?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _PathCard(
          icon: Icons.checklist_rounded,
          iconColor: AppColors.darkPink,
          iconBg: Colors.pink.shade50,
          title: 'Manual Symptom Selection',
          description:
              'Choose from a list of symptoms your pet is showing across different body systems to get a detailed AI assessment.',
          buttonLabel: 'Select Symptoms',
          onTap: () => setState(() {
            _selectedSymptoms = [];
            _currentStep = CheckerStep.symptoms;
          }),
        ),
        const SizedBox(height: 14),
        _PathCard(
          icon: Icons.camera_alt_outlined,
          iconColor: Colors.purple.shade600,
          iconBg: Colors.purple.shade50,
          title: 'Skin Photo Analysis',
          description:
              'Upload or take a photo of your pet\'s affected skin area. Our AI will analyze it and identify possible conditions.',
          buttonLabel: 'Upload Photo',
          buttonColor: Colors.purple.shade600,
          onTap: () => setState(() {
            _uploadedPhoto = null;
            _currentStep = CheckerStep.photoUpload;
          }),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow.shade50,
            border: Border.all(color: Colors.yellow.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.yellow.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Results are AI-generated and are not a substitute for professional veterinary advice.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -- Manual symptom selection -----------------------------------------------
  Widget _buildSymptomSelection() {
    final Map<String, List<Symptom>> grouped = {};
    for (final cat in SymptomData.categories) {
      final list =
          SymptomData.symptoms.where((s) => s.category == cat.id).toList();
      if (list.isNotEmpty) grouped[cat.id] = list;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Select all symptoms your pet is showing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap each symptom that applies. You can select from multiple categories.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ...SymptomData.categories.map((cat) {
          final list = grouped[cat.id];
          if (list == null) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSymptoms.remove(symptom.id);
                        } else {
                          _selectedSymptoms.add(symptom.id);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.darkPink : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.darkPink
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            symptom.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
        if (_selectedSymptoms.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.darkPink, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_selectedSymptoms.length} symptom${_selectedSymptoms.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                      color: Colors.pink.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  setState(() => _currentStep = CheckerStep.details),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Continue',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // -- Photo upload -----------------------------------------------------------
  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Upload a Photo of the Affected Area',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.blue.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Tips for best results',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '  Ensure good lighting\n'
                '  Get close to the affected area\n'
                '  Keep the photo in focus\n'
                '  Show the entire affected area',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_uploadedPhoto == null) ...[
          _PhotoOptionTile(
            icon: Icons.camera_alt_outlined,
            iconColor: AppColors.darkPink,
            borderColor: Colors.pink.shade300,
            title: 'Take a Photo',
            subtitle: 'Use your camera to capture the affected area',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _PhotoOptionTile(
            icon: Icons.photo_library_outlined,
            iconColor: Colors.purple.shade600,
            borderColor: Colors.purple.shade300,
            title: 'Upload from Gallery',
            subtitle: 'Choose an existing photo from your device',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ] else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.file(
                  _uploadedPhoto!,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.red.shade600,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => _uploadedPhoto = null),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Photo ready for analysis',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_photoAnalyzing) ...[
            // -- Animated loading card -------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                border: Border.all(color: Colors.purple.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      color: Colors.purple.shade600,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _photoPhase,
                      key: ValueKey(_photoPhase),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI is examining your photo',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _analyzePhoto,
                icon: const Icon(Icons.search),
                label: const Text('Analyze Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _uploadedPhoto = null),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Use a Different Photo'),
              ),
            ),
          ],
        ],
      ],
    );
  }

  // -- Details input ----------------------------------------------------------
  Widget _buildDetailsInput() {
    // While pet data is loading, show a spinner
    if (_petLoading) {
      return Column(
        children: [
          const SizedBox(height: 40),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          Center(
            child: Text('Loading pet details',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
        ],
      );
    }

    final bool needsSpecies = _species.isEmpty;
    final bool needsSex = _sex.isEmpty;
    final bool needsNeutered = _neutered.isEmpty;
    final bool needsVaccinated = _vaccinated.isEmpty;
    final bool anyMissing = needsSpecies || needsSex || needsNeutered || needsVaccinated;
    final bool allAnswered = !anyMissing;

    // Build a short description of what was prefilled for the info card
    final List<String> prefilled = [];
    if (!needsSpecies) prefilled.add(_species == 'dog' ? 'Dog' : 'Cat');
    if (!needsSex) prefilled.add(_sex == 'male' ? 'Male' : 'Female');
    if (!needsNeutered) prefilled.add(_neutered == 'yes' ? 'Neutered' : 'Not neutered');
    if (!needsVaccinated) prefilled.add(_vaccinated == '1' ? 'Vaccinated' : 'Not vaccinated');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          anyMissing ? 'A few quick questions' : 'Pet details confirmed',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          anyMissing
              ? 'Some details couldn\'t be found on your pet\'s profile. Please fill them in.'
              : 'All details were loaded from your pet\'s profile.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // -- Prefilled summary card --------------------------------------
        if (prefilled.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green.shade600, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _petName.isNotEmpty
                            ? 'Loaded from $_petName\'s profile'
                            : 'Loaded from pet profile',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prefilled.join('  '),
                        style: TextStyle(
                            fontSize: 13, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // -- Species (only if not known) ----------------------------------
        if (needsSpecies) ...[
          _SectionBox(
            title: 'What species is your pet?',
            child: Column(
              children: [
                _OptionTile(
                    label: 'Dog',
                    selected: _species == 'dog',
                    onTap: () => setState(() => _species = 'dog')),
                _OptionTile(
                    label: 'Cat',
                    selected: _species == 'cat',
                    onTap: () => setState(() => _species = 'cat')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // -- Sex (only if unknown / not set) ------------------------------
        if (needsSex) ...[
          _SectionBox(
            title: 'What is your pet\'s sex?',
            child: Column(
              children: [
                _OptionTile(
                    label: 'Male',
                    selected: _sex == 'male',
                    onTap: () => setState(() => _sex = 'male')),
                _OptionTile(
                    label: 'Female',
                    selected: _sex == 'female',
                    onTap: () => setState(() => _sex = 'female')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // -- Neutered (only if not known) ---------------------------------
        if (needsNeutered) ...[
          _SectionBox(
            title: 'Is your pet neutered / spayed?',
            child: Column(
              children: [
                _OptionTile(
                    label: 'Yes',
                    selected: _neutered == 'yes',
                    onTap: () => setState(() => _neutered = 'yes')),
                _OptionTile(
                    label: 'No',
                    selected: _neutered == 'no',
                    onTap: () => setState(() => _neutered = 'no')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // -- Vaccinated (only if not known) -------------------------------
        if (needsVaccinated) ...[
          _SectionBox(
            title: 'Up to date on vaccinations?',
            child: Column(
              children: [
                _OptionTile(
                    label: 'Yes',
                    selected: _vaccinated == '1',
                    onTap: () => setState(() => _vaccinated = '1')),
                _OptionTile(
                    label: 'No / not sure',
                    selected: _vaccinated == '0',
                    onTap: () => setState(() => _vaccinated = '0')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 8),

        if (allAnswered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingAssessment ? null : _runAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _loadingAssessment
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Get Assessment',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _runAssessment() async {
    setState(() => _loadingAssessment = true);

    // All 18 recognised symptom IDs  each becomes a 0/1 flag in the payload
    const allSymptoms = [
      'vomiting', 'diarrhea', 'dehydration', 'loss_appetite',
      'fever', 'lethargy', 'itching', 'red_skin', 'hair_loss',
      'skin_lesions', 'wounds', 'dark_urine', 'pale_gums',
      'pale_eyelids', 'tick_exposure', 'pain_urinating',
      'frequent_urination', 'blood_in_urine',
    ];

    final Map<String, dynamic> payload = {
      'species': _species.isEmpty ? 'dog' : _species,
      'breed': _petBreed,
      'sex': _sex.isEmpty ? 'male' : _sex,
      'neutered': (_neutered == 'yes' || _neutered == 'no') ? _neutered : 'no',
      'age_years': _petAgeYears,
      'weight_kg': _petWeightKg,
      'vaccinated': _vaccinated == '1' ? 1 : 0,
      'num_previous_visits': 0,
      'prev_diagnosis_class': -1,
      'days_since_last_visit': 0,
      'chronic_flag': 0,
    };

    // Add a 1 for each selected symptom, 0 for the rest
    for (final s in allSymptoms) {
      payload[s] = _selectedSymptoms.contains(s) ? 1 : 0;
    }

    try {
      final res = await DiagnosisService().predictSymptomCheckerV2(payload);
      // Response shape: { predicted_class, confidence, top_3: [{class, probability}], probability_map }
      final top3 = res['top_3'];
      final preds = <Map<String, dynamic>>[];
      if (top3 is List) {
        for (final p in top3) {
          if (p is Map) preds.add(Map<String, dynamic>.from(p));
        }
      }
      setState(() {
        _predictions = preds;
        _currentStep = CheckerStep.results;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get assessment.')),
      );
    } finally {
      setState(() => _loadingAssessment = false);
    }
  }

  // -- Results (manual) -------------------------------------------------------
  Widget _buildResults() {
    final confidentPreds = _predictions
        .where((p) => ((p['probability'] ?? 0) as num).toDouble() >= 0.5)
        .toList();
    final bool hasConfident = confidentPreds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Header banner --------------------------------------------------
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            border: Border.all(color: Colors.pink.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, color: AppColors.darkPink, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Assessment complete. Results are ranked by likelihood. Always consult a vet for a definitive diagnosis.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // -- Book vet button (always at the top) ----------------------------
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.goNamed('VetHomeScreen'),
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: const Text('Book Vet Appointment',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Possible Diagnoses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        if (_predictions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('No predictions returned.',
                  style: TextStyle(color: Colors.grey.shade500)),
            ),
          )
        else if (!hasConfident) ...[
          // -- Low confidence error state ------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Symptoms could not be diagnosed with confidence',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The symptoms provided did not match any condition with sufficient confidence. An immediate vet visit is recommended for a proper examination.',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else
          ...confidentPreds.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final className = (p['class'] ?? 'Unknown') as String;
            final confidence =
                ((p['probability'] ?? 0) as num).toDouble();
            final info = diagnosisInfo.containsKey(className)
                ? diagnosisInfo[className] as Map<String, dynamic>
                : null;
            final displayName =
                info?['common_name'] ?? _formatClassName(className);
            return _DiagnosisCard(
              rank: i + 1,
              conditionDisplay: displayName,
              confidence: confidence,
              info: info,
            );
          }).toList(),

        const SizedBox(height: 16),
        _DisclaimerBox(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetChecker,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkPink,
              side: BorderSide(color: AppColors.darkPink),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('New Assessment'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // -- Photo results ----------------------------------------------------------
  Widget _buildPhotoResults() {
    final confidentPreds = _cnnPredictions
        .where((p) => ((p['prob'] ?? 0) as num).toDouble() >= 0.5)
        .toList();
    final bool hasConfident = confidentPreds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Header banner --------------------------------------------------
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            border: Border.all(color: Colors.purple.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: Colors.purple.shade600, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI photo analysis complete. Results are ranked by likelihood. This is not a substitute for veterinary examination.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // -- Book vet button (always at the top) ----------------------------
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.goNamed('VetHomeScreen'),
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: const Text('Book Vet Appointment',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // -- Analyzed photo thumbnail ---------------------------------------
        if (_uploadedPhoto != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _uploadedPhoto!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Analyzed image',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // -- Results title --------------------------------------------------
        const Text(
          'Possible Skin Conditions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // -- CNN prediction cards -------------------------------------------
        if (_cnnPredictions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No predictions returned.',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          )
        else if (!hasConfident) ...[
          // -- Low confidence error state ------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Symptoms could not be diagnosed with confidence',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The photo provided did not match any condition with sufficient confidence. An immediate vet visit is recommended for a proper examination.',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else
          ...confidentPreds.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final p = entry.value;
            final rawClass = (p['class'] ?? 'Unknown') as String;
            final prob = ((p['prob'] ?? 0) as num).toDouble();
            final info =
                cnnSkinConditionInfo[rawClass] ?? cnnFallbackInfo(rawClass);
            return _CnnResultCard(
              rank: rank,
              rawClass: rawClass,
              info: info,
              confidence: prob,
            );
          }).toList(),

        const SizedBox(height: 16),
        _DisclaimerBox(
          message:
              'This AI analysis is based on visual patterns and should not replace a professional veterinary examination.',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetChecker,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkPink,
              side: BorderSide(color: AppColors.darkPink),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('New Analysis'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// -------------------------------------------------------------------------------
// Helper widgets
// -------------------------------------------------------------------------------

class _PathCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final String buttonLabel;
  final Color? buttonColor;
  final VoidCallback onTap;

  const _PathCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = buttonColor ?? AppColors.darkPink;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(buttonLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
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

class _PhotoOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoOptionTile({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey.shade800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.pink.shade50 : Colors.white,
            border: Border.all(
              color: selected ? Colors.pink.shade500 : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected
                                ? Colors.pink.shade700
                                : Colors.grey.shade800)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle,
                    color: Colors.pink.shade500, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisclaimerBox extends StatelessWidget {
  final String? message;
  const _DisclaimerBox({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        border: Border.all(color: Colors.yellow.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.yellow.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ??
                  'This assessment is AI-generated and should not replace professional veterinary advice. If symptoms worsen, contact a veterinarian immediately.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final int rank;
  final String conditionDisplay;
  final double confidence;
  final Map<String, dynamic>? info;

  const _DiagnosisCard({
    required this.rank,
    required this.conditionDisplay,
    required this.confidence,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toStringAsFixed(0);
    Color confColor;
    if (confidence >= 0.75) {
      confColor = Colors.green.shade600;
    } else if (confidence >= 0.4) {
      confColor = Colors.orange.shade600;
    } else {
      confColor = Colors.red.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                      color: Colors.pink.shade100, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$rank',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.pink.shade700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(conditionDisplay,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Text('$pct%',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: confColor)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(confColor),
              ),
            ),
            if (info != null) ...[
              const SizedBox(height: 10),
              Text(info!['description'] ?? '',
                  style:
                      TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              if ((info!['common_symptoms'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text('Common symptoms',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.grey.shade800)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (info!['common_symptoms'] as List)
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(s.toString(),
                                style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// -- CNN result card ------------------------------------------------------------
class _CnnResultCard extends StatelessWidget {
  final int rank;
  final String rawClass;
  final Map<String, dynamic> info;
  final double confidence; // 0.0 – 1.0

  const _CnnResultCard({
    required this.rank,
    required this.rawClass,
    required this.info,
    required this.confidence,
  });

  Color get _severityAccent {
    switch ((info['severity'] as String?) ?? '') {
      case 'mild': return Colors.green.shade600;
      case 'moderate': return Colors.orange.shade600;
      case 'severe': return Colors.red.shade600;
      case 'none': return Colors.green.shade600;
      default: return Colors.grey.shade600;
    }
  }

  Color get _severityBg {
    switch ((info['severity'] as String?) ?? '') {
      case 'mild': return Colors.green.shade50;
      case 'moderate': return Colors.orange.shade50;
      case 'severe': return Colors.red.shade50;
      case 'none': return Colors.green.shade50;
      default: return Colors.grey.shade50;
    }
  }

  Color get _confColor {
    if (confidence >= 0.75) return Colors.green.shade600;
    if (confidence >= 0.40) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (info['display_name'] as String?) ?? rawClass;
    final description = (info['description'] as String?) ?? '';
    final action = (info['action'] as String?) ?? '';
    final otcMed = info['otc_medication'] as String?;
    final causes = (info['common_causes'] as List?)?.cast<String>() ?? [];
    final pct = (confidence * 100).toStringAsFixed(0);
    final severity = (info['severity'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Title row --------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (severity.isNotEmpty && severity != 'unknown') ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _severityBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _severityAccent.withOpacity(0.4)),
                          ),
                          child: Text(
                            severity[0].toUpperCase() + severity.substring(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _severityAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: _confColor,
                      ),
                    ),
                    Text(
                      'match',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // -- Confidence bar ---------------------------------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_confColor),
              ),
            ),
            const SizedBox(height: 12),
            // -- Description ------------------------------------------------
            if (description.isNotEmpty)
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            // -- Common causes ----------------------------------------------
            if (causes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Common causes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: causes
                          .map((c) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.purple.shade200),
                                ),
                                child: Text(c,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.purple.shade800)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
            // -- Recommended action -----------------------------------------
            if (action.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.medical_services_outlined,
                        size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // -- OTC medication ---------------------------------------------
            if (otcMed != null && otcMed.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.local_pharmacy_outlined,
                        size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OTC option: $otcMed',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
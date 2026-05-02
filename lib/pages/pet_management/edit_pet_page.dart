import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/store/pet_scope.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class EditPetScreen extends StatefulWidget {
  final String petId;
  const EditPetScreen({Key? key, required this.petId}) : super(key: key);

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _ageController = TextEditingController();

  // State
  bool _loading = true;
  bool _submitting = false;
  String? _selectedSpecies;
  String? _selectedGender;
  bool _neutered = false;

  final List<String> _animals = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Hamster', 'Other'];
  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadPet() async {
    try {
      final data = await PetService().getPetById(widget.petId);

      // Compute age from dob if available, otherwise fall back to 'age' field
      int age = 0;
      if (data['dob'] != null) {
        try {
          final dob = DateTime.parse(data['dob'] as String);
          age = DateTime.now().year - dob.year;
        } catch (_) {}
      }
      if (age == 0) {
        final rawAge = data['age'];
        if (rawAge != null) age = int.tryParse(rawAge.toString()) ?? 0;
      }

      // Latest weight from history
      String weight = '';
      final wh = data['weightHistory'];
      if (wh is List && wh.isNotEmpty) {
        final w = wh.last['weight'];
        if (w != null) weight = w.toString();
      }

      // Normalize species to match dropdown items
      final rawSpecies = data['species'] as String? ?? '';
      final matchedSpecies = _animals.firstWhere(
        (a) => a.toLowerCase() == rawSpecies.toLowerCase(),
        orElse: () => '',
      );

      // Normalize gender
      final rawGender = data['gender'] as String? ?? '';
      final matchedGender = _genders.firstWhere(
        (g) => g.toLowerCase() == rawGender.toLowerCase(),
        orElse: () => '',
      );

      setState(() {
        _petNameController.text = data['name'] ?? '';
        _breedController.text = data['breed'] ?? '';
        _colorController.text = data['color'] ?? '';
        _weightController.text = weight;
        _ageController.text = age > 0 ? '$age' : '';
        _selectedSpecies = matchedSpecies.isEmpty ? null : matchedSpecies;
        _selectedGender = matchedGender.isEmpty ? null : matchedGender;
        final neuteredVal = data['neutered'];
        _neutered = neuteredVal == true || neuteredVal == 'yes';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load pet details'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  DateTime _dobFromAgeYears(String ageText) {
    final years = int.tryParse(ageText.trim()) ?? 0;
    final now = DateTime.now();
    return DateTime(now.year - years, now.month, now.day);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await PetService().updatePet(
        petId: widget.petId,
        name: _petNameController.text.trim(),
        breed: _breedController.text.trim(),
        species: _selectedSpecies!,
        dob: _dobFromAgeYears(_ageController.text),
        gender: _selectedGender!,
        weight: _weightController.text.trim(),
        color: _colorController.text.trim(),
        neutered: _neutered,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Invalidate cache so pet profile and lists re-fetch fresh data
      final store = PetScope.of(context);
      store.invalidatePetDetail(widget.petId);
      store.refresh();
      // Return true so the profile page knows to refresh
      Navigator.pop(context, true);
    } on DioException catch (e) {
      String message = 'Failed to update pet';
      if (e.response?.data is Map && e.response!.data.containsKey('message')) {
        message = e.response!.data['message'];
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Edit Pet',
          style: TextStyle(
            fontSize: sw * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.05,
                    vertical: sh * 0.02,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Pet Name ──────────────────────────────────────
                        _buildLabel('Pet Name', sw * 0.035),
                        _buildTextField(
                          controller: _petNameController,
                          hintText: 'Enter pet name',
                          sw: sw,
                          sh: sh,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter pet name' : null,
                        ),

                        SizedBox(height: sh * 0.02),

                        // ── Species ───────────────────────────────────────
                        _buildLabel('Animal Type', sw * 0.035),
                        _buildDropdown(
                          value: _selectedSpecies,
                          items: _animals,
                          hintText: 'Select animal type',
                          onChanged: (v) => setState(() => _selectedSpecies = v),
                          sw: sw,
                          sh: sh,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please select animal type' : null,
                        ),

                        SizedBox(height: sh * 0.02),

                        // ── Breed ─────────────────────────────────────────
                        _buildLabel('Breed', sw * 0.035),
                        _buildTextField(
                          controller: _breedController,
                          hintText: 'Enter breed',
                          sw: sw,
                          sh: sh,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter breed' : null,
                        ),

                        SizedBox(height: sh * 0.02),

                        // ── Age ──────────────────────────────────────────
                        _buildLabel('Age (years)', sw * 0.035),
                        _buildTextField(
                          controller: _ageController,
                          hintText: 'e.g. 3',
                          sw: sw,
                          sh: sh,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter age';
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 0) return 'Enter a valid age';
                            return null;
                          },
                        ),

                        SizedBox(height: sh * 0.02),

                        // ── Gender ────────────────────────────────────────
                        _buildLabel('Gender', sw * 0.035),
                        _buildDropdown(
                          value: _selectedGender,
                          items: _genders,
                          hintText: 'Select gender',
                          onChanged: (v) => setState(() => _selectedGender = v),
                          sw: sw,
                          sh: sh,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please select gender' : null,
                        ),

                        SizedBox(height: sh * 0.02),

                        // ── Weight ────────────────────────────────────────
                        _buildLabel('Weight (kg)', sw * 0.035),
                        _buildTextField(
                          controller: _weightController,
                          hintText: 'Enter weight',
                          sw: sw,
                          sh: sh,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter weight';
                            if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                            if (double.parse(v.trim()) <= 0) return 'Weight must be greater than 0';
                            return null;
                          },
                        ),

                        SizedBox(height: sh * 0.02),

                        // ── Color ─────────────────────────────────────────
                        _buildLabel('Color / Appearance', sw * 0.035),
                        _buildTextField(
                          controller: _colorController,
                          hintText: 'Enter color or appearance',
                          sw: sw,
                          sh: sh,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter color' : null,
                        ),

                        SizedBox(height: sh * 0.02),

                        // ── Neutered / Spayed toggle ──────────────────────
                        _buildLabel('Neutered / Spayed', sw * 0.035),
                        SizedBox(height: sh * 0.01),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(sw * 0.02),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: sw * 0.04, vertical: 0),
                            title: Text(
                              _neutered ? 'Yes' : 'No',
                              style: TextStyle(
                                fontSize: sw * 0.032,
                                color: Colors.black87,
                              ),
                            ),
                            value: _neutered,
                            activeColor: AppColors.darkPink,
                            onChanged: (v) => setState(() => _neutered = v),
                          ),
                        ),

                        SizedBox(height: sh * 0.04),

                        // ── Save button ───────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: sh * 0.06,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw * 0.02),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: sw * 0.032,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: sh * 0.015),

                        // ── Cancel button ─────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: sh * 0.06,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw * 0.02),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: sw * 0.032,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: sh * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ── Shared form widgets ────────────────────────────────────────────────────

  Widget _buildLabel(String label, double fontSize) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required double sw,
    required double sh,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: sh * 0.01),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.018,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.darkPink, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.errorMessage),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.errorMessage, width: 2),
          ),
        ),
        style: TextStyle(fontSize: sw * 0.032),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hintText,
    required Function(String?) onChanged,
    required double sw,
    required double sh,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: sh * 0.01),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: sw * 0.032)),
                ))
            .toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.018,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.darkPink, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.errorMessage),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.errorMessage, width: 2),
          ),
        ),
      ),
    );
  }

}

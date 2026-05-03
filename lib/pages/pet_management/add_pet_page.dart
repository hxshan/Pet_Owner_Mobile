import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/store/pet_scope.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();

  String? _selectedAnimal;
  String? _selectedHealth;
  String? _selectedLifeStatus;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _animals = [
    'Dog',
    'Cat',
    'Bird',
    'Rabbit',
    'Hamster',
    'Other',
  ];
  final List<String> _healthStatus = ['Good', 'Fair', 'Poor', 'Critical'];
  final List<String> _lifeStatus = ['Alive', 'Deceased'];

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final petService = PetService();

      final response = await petService.createPet(
        name: _petNameController.text.trim(),
        breed: _breedController.text.trim(),
        animalType: _selectedAnimal!,
        age: _ageController.text.trim(),
        weight: _weightController.text.trim(),
        color: _colorController.text.trim(),
        health: _selectedHealth!,
        lifeStatus: _selectedLifeStatus!,
        gender: _selectedGender!,
      );

      if (!mounted) return;

      final message =
          response.containsKey('message') ? response['message'] : 'Pet added successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      PetScope.of(context).refresh();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) context.pop();
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = (e.response?.data is Map && e.response!.data.containsKey('message'))
          ? e.response!.data['message']
          : (e.message ?? 'Failed to add pet');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'Add New Pet',
          style: TextStyle(
            fontSize: sw * 0.052,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Divider below appbar
            Container(height: 1, color: const Color(0xFFF0F0F0)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sh * 0.025,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Basic Information ──────────────────────────────
                      _buildSectionHeader('Basic Information', sw),
                      SizedBox(height: sh * 0.015),

                      _buildFieldLabel('Pet Name', sw),
                      _buildTextField(
                        controller: _petNameController,
                        hintText: 'e.g. Buddy',
                        prefixIcon: Icons.pets,
                        sw: sw,
                        sh: sh,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Please enter a pet name' : null,
                      ),

                      SizedBox(height: sh * 0.018),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Animal Type', sw),
                                _buildDropdown(
                                  value: _selectedAnimal,
                                  items: _animals,
                                  hintText: 'Select type',
                                  prefixIcon: Icons.category_outlined,
                                  onChanged: (v) => setState(() => _selectedAnimal = v),
                                  sw: sw,
                                  sh: sh,
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Breed', sw),
                                _buildTextField(
                                  controller: _breedController,
                                  hintText: 'e.g. Labrador',
                                  prefixIcon: Icons.info_outline,
                                  sw: sw,
                                  sh: sh,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: sh * 0.018),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Age (years)', sw),
                                _buildTextField(
                                  controller: _ageController,
                                  hintText: 'e.g. 3',
                                  prefixIcon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                  sw: sw,
                                  sh: sh,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Weight (kg)', sw),
                                _buildTextField(
                                  controller: _weightController,
                                  hintText: 'e.g. 12.5',
                                  prefixIcon: Icons.monitor_weight_outlined,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  sw: sw,
                                  sh: sh,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: sh * 0.018),

                      _buildFieldLabel('Color / Appearance', sw),
                      _buildTextField(
                        controller: _colorController,
                        hintText: 'e.g. Golden with white patches',
                        prefixIcon: Icons.palette_outlined,
                        sw: sw,
                        sh: sh,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Please describe appearance' : null,
                      ),

                      SizedBox(height: sh * 0.028),

                      // ── Health & Status ────────────────────────────────
                      _buildSectionHeader('Health & Status', sw),
                      SizedBox(height: sh * 0.015),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Overall Health', sw),
                                _buildDropdown(
                                  value: _selectedHealth,
                                  items: _healthStatus,
                                  hintText: 'Select',
                                  prefixIcon: Icons.favorite_border,
                                  onChanged: (v) => setState(() => _selectedHealth = v),
                                  sw: sw,
                                  sh: sh,
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Life Status', sw),
                                _buildDropdown(
                                  value: _selectedLifeStatus,
                                  items: _lifeStatus,
                                  hintText: 'Select',
                                  prefixIcon: Icons.monitor_heart_outlined,
                                  onChanged: (v) => setState(() => _selectedLifeStatus = v),
                                  sw: sw,
                                  sh: sh,
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: sh * 0.018),

                      _buildFieldLabel('Gender', sw),
                      _buildDropdown(
                        value: _selectedGender,
                        items: const ['Male', 'Female'],
                        hintText: 'Select gender',
                        prefixIcon: Icons.transgender_outlined,
                        onChanged: (v) => setState(() => _selectedGender = v),
                        sw: sw,
                        sh: sh,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Please select a gender' : null,
                      ),

                      SizedBox(height: sh * 0.04),

                      // ── Action Buttons ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: sh * 0.062,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkPink,
                            disabledBackgroundColor: AppColors.mainColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.03),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Add Pet',
                                  style: TextStyle(
                                    fontSize: sw * 0.038,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: sh * 0.015),

                      SizedBox(
                        width: double.infinity,
                        height: sh * 0.062,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.03),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double sw) {
    return Row(
      children: [
        Container(
          width: 4,
          height: sw * 0.045,
          decoration: BoxDecoration(
            color: AppColors.darkPink,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.04,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.02),
      child: Text(
        label,
        style: TextStyle(
          fontSize: sw * 0.033,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required double sw,
    required double sh,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: sw * 0.035, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: sw * 0.033),
        prefixIcon: Icon(prefixIcon, color: AppColors.darkPink, size: sw * 0.048),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.018,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: BorderSide(color: AppColors.darkPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: BorderSide(color: AppColors.errorMessage, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: BorderSide(color: AppColors.errorMessage, width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: sw * 0.028),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hintText,
    required IconData prefixIcon,
    required Function(String?) onChanged,
    required double sw,
    required double sh,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500], size: sw * 0.05),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(fontSize: sw * 0.034, color: Colors.black87)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: sw * 0.034, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: sw * 0.033),
        prefixIcon: Icon(prefixIcon, color: AppColors.darkPink, size: sw * 0.048),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.018,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: BorderSide(color: AppColors.darkPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: BorderSide(color: AppColors.errorMessage, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.025),
          borderSide: BorderSide(color: AppColors.errorMessage, width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: sw * 0.028),
      ),
    );
  }
}

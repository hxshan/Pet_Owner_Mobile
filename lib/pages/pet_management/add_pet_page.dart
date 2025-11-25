import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  // Form state
  String? _selectedAnimal;
  String? _selectedHealth;
  String? _selectedLifeStatus;
  DateTime? _selectedDOB;
  File? _selectedImage;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
      });
    }
  }

  // Image picker
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.05)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sw * 0.05),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.darkPink),
                title: Text('Camera'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.image, color: AppColors.darkPink),
                title: Text('Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              SizedBox(height: sw * 0.02),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process form submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pet "${_petNameController.text}" added successfully!'),
        ),
      );
      // Navigate back or clear form
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: Colors.black, size: sw * 0.06),
        ),
        title: Text(
          'Add New Pet',
          style: TextStyle(
            fontSize: sw * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
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
                  // Pet Avatar Upload Section
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImagePickerDialog(context),
                      child: Container(
                        width: sw * 0.35,
                        height: sw * 0.35,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.mainColor,
                            width: sw * 0.008,
                          ),
                          borderRadius: BorderRadius.circular(sw * 0.25),
                          color: AppColors.lightGray,
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(sw * 0.25),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: sw * 0.12,
                                    color: AppColors.darkPink,
                                  ),
                                  SizedBox(height: sh * 0.01),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      fontSize: sw * 0.035,
                                      color: AppColors.darkPink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
        
                  SizedBox(height: sh * 0.03),
        
                  // Pet Name Field
                  _buildLabel('Pet Name', sw * 0.035),
                  _buildTextField(
                    controller: _petNameController,
                    hintText: 'Enter pet name',
                    sw: sw,
                    sh: sh,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pet name';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Animal Type Dropdown
                  _buildLabel('Animal Type', sw * 0.035),
                  _buildDropdown(
                    value: _selectedAnimal,
                    items: _animals,
                    hintText: 'Select animal type',
                    onChanged: (value) {
                      setState(() {
                        _selectedAnimal = value;
                      });
                    },
                    sw: sw,
                    sh: sh,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select animal type';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Breed Field
                  _buildLabel('Breed', sw * 0.035),
                  _buildTextField(
                    controller: _breedController,
                    hintText: 'Enter breed',
                    sw: sw,
                    sh: sh,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter breed';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Date of Birth
                  _buildLabel('Date of Birth', sw * 0.035),
                  _buildDateField(
                    sw: sw,
                    sh: sh,
                    selectedDate: _selectedDOB,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (_selectedDOB == null) {
                        return 'Please select date of birth';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Age Field
                  _buildLabel('Age (years)', sw * 0.035),
                  _buildTextField(
                    controller: _ageController,
                    hintText: 'Enter age',
                    sw: sw,
                    sh: sh,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter age';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Weight Field
                  _buildLabel('Weight (kg)', sw * 0.035),
                  _buildTextField(
                    controller: _weightController,
                    hintText: 'Enter weight',
                    sw: sw,
                    sh: sh,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter weight';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Color/Appearance Field
                  _buildLabel('Color/Appearance', sw * 0.035),
                  _buildTextField(
                    controller: _colorController,
                    hintText: 'Enter color or appearance',
                    sw: sw,
                    sh: sh,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter color or appearance';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Overall Health Dropdown
                  _buildLabel('Overall Health', sw * 0.035),
                  _buildDropdown(
                    value: _selectedHealth,
                    items: _healthStatus,
                    hintText: 'Select health status',
                    onChanged: (value) {
                      setState(() {
                        _selectedHealth = value;
                      });
                    },
                    sw: sw,
                    sh: sh,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select health status';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Life Status Dropdown
                  _buildLabel('Life Status', sw * 0.035),
                  _buildDropdown(
                    value: _selectedLifeStatus,
                    items: _lifeStatus,
                    hintText: 'Select life status',
                    onChanged: (value) {
                      setState(() {
                        _selectedLifeStatus = value;
                      });
                    },
                    sw: sw,
                    sh: sh,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select life status';
                      }
                      return null;
                    },
                  ),
        
                  SizedBox(height: sh * 0.04),
        
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: sh * 0.06,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.02),
                        ),
                      ),
                      child: Text(
                        'Add Pet',
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
        
                  SizedBox(height: sh * 0.02),
        
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: sh * 0.06,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black, width: 1),
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

  // Lable
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

  // Text field component
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
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.darkPink, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
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
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontSize: sw * 0.032)),
              ),
            )
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
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: AppColors.darkPink, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
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

  Widget _buildDateField({
    required double sw,
    required double sh,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: sh * 0.01),
      child: GestureDetector(
        onTap: onTap,
        child: FormField<String>(
          validator: validator,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sh * 0.018,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: state.hasError
                          ? AppColors.errorMessage
                          : Color(0xFFE0E0E0),
                      width: state.hasError ? 1 : 1,
                    ),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null
                            ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                            : 'Select date',
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          color: selectedDate != null
                              ? Colors.black
                              : Colors.grey[400],
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.darkPink,
                        size: sw * 0.05,
                      ),
                    ],
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: sh * 0.008),
                    child: Text(
                      state.errorText ?? '',
                      style: TextStyle(
                        color: AppColors.errorMessage,
                        fontSize: sw * 0.028,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

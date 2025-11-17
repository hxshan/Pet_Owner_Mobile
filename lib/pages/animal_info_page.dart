import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';

class AnimalInfoPage extends StatefulWidget {
  const AnimalInfoPage({super.key});

  @override
  State<AnimalInfoPage> createState() => _AnimalInfoPageState();
}

class _AnimalInfoPageState extends State<AnimalInfoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? selectedSpecies;
  String? selectedBreed;
  DateTime? selectedDate;

  // Error messages
  String? nameError;
  String? speciesError;
  String? ageError;
  String? breedError;

  final List<String> species = ['Cat', 'Dog'];
  final Map<String, List<String>> breeds = {
    'Cat': [
      'Persian',
      'Siamese',
      'Maine Coon',
      'Bengal',
      'British Shorthair',
      'Ragdoll',
      'Sphynx',
      'Scottish Fold',
    ],
    'Dog': [
      'Labrador',
      'German Shepherd',
      'Golden Retriever',
      'Bulldog',
      'Poodle',
      'Beagle',
      'Rottweiler',
      'Yorkshire Terrier',
    ],
  };

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Calculate age from birth date
        final age = DateTime.now().difference(picked).inDays ~/ 365;
        ageController.text = '$age years old';
      });
    }
  }

  // Show species bottom sheet
  void _showSpeciesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Species',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...species.map((item) {
                return ListTile(
                  title: Text(item),
                  leading: Radio<String>(
                    value: item,
                    groupValue: selectedSpecies,
                    activeColor: AppColors.mainColor,
                    onChanged: (String? value) {
                      setState(() {
                        selectedSpecies = value;
                        selectedBreed = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedSpecies = item;
                      selectedBreed = null;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Show breed bottom sheet
  void _showBreedBottomSheet(BuildContext context) {
    if (selectedSpecies == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Breed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: breeds[selectedSpecies!]!.map((item) {
                        return ListTile(
                          title: Text(item),
                          leading: Radio<String>(
                            value: item,
                            groupValue: selectedBreed,
                            activeColor: AppColors.mainColor,
                            onChanged: (String? value) {
                              setState(() {
                                selectedBreed = value;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          onTap: () {
                            setState(() {
                              selectedBreed = item;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  // Validate form
  void validateAndSubmit() {
    setState(() {
      // Reset all errors
      nameError = null;
      speciesError = null;
      ageError = null;
      breedError = null;

      // Validate name
      if (nameController.text.isEmpty) {
        nameError = 'Pet name is required';
      }

      // Validate species
      if (selectedSpecies == null) {
        speciesError = 'Please select a species';
      }

      // Validate age
      if (ageController.text.isEmpty) {
        ageError = 'Age is required';
      }

      // Validate breed
      if (selectedBreed == null) {
        breedError = 'Please select a breed';
      }
    });

    // Check if all fields are valid
    if (nameError == null &&
        speciesError == null &&
        ageError == null &&
        breedError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet information saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void skipForNow() {
    // Handle skip action - navigate to next screen or show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You can add pet information later'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Pink Background
            Container(
              width: sw,
              decoration: const BoxDecoration(color: AppColors.mainColor),
              padding: EdgeInsets.only(top: sh * 0.02),
              child: Column(
                children: [
                  SizedBox(height: sh * 0.04),
                  // Dog Icon
                  Image.asset(
                    'assets/dog_img.png',
                    width: sw * 0.25,
                    height: sw * 0.25,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.pets,
                        size: sw * 0.25,
                        color: Colors.blue[800],
                      );
                    },
                  ),
                  SizedBox(height: sh * 0.015),
                  // Title
                  Text(
                    'PetCareHub',
                    style: TextStyle(
                      fontSize: sw * 0.065,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  // Subtitle
                  Text(
                    'Join a community of pet lovers!',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: sh * 0.02),
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
                        width: sw * 0.022,
                        height: sw * 0.022,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0 ? Colors.blue[700] : Colors.white,
                          border: Border.all(
                            color: index == 0
                                ? Colors.blue[700]!
                                : Colors.black26,
                            width: 1,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: sh * 0.03),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sh * 0.03),
                  // Pet Info Header
                  Container(
                    padding: EdgeInsets.only(bottom: sh * 0.0001),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: Text(
                      'Pet Info',
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.025),

                  // Name Field
                  _buildTextField(
                    context,
                    'Name',
                    sw,
                    sh,
                    nameController,
                    nameError,
                  ),
                  SizedBox(height: sh * 0.02),

                  // Species Dropdown
                  _buildCustomDropdownField(
                    context,
                    'Species (Cat or Dog)',
                    sw,
                    sh,
                    selectedSpecies,
                    speciesError,
                    () => _showSpeciesBottomSheet(context),
                  ),
                  SizedBox(height: sh * 0.02),

                  // Age Field with Calendar Icon
                  _buildDatePickerField(
                    context,
                    'Age (Estimate)',
                    sw,
                    sh,
                    ageController,
                    ageError,
                  ),
                  SizedBox(height: sh * 0.02),

                  // Breed Dropdown
                  _buildCustomDropdownField(
                    context,
                    'Breed',
                    sw,
                    sh,
                    selectedBreed,
                    breedError,
                    () => _showBreedBottomSheet(context),
                    enabled: selectedSpecies != null,
                  ),

                  SizedBox(height: sh * 0.03),

                  // Skip For Now Button
                  Center(
                    child: TextButton(
                      onPressed: skipForNow,
                      child: Text(
                        'Skip For Now',
                        style: TextStyle(
                          fontSize: sw * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.02),

                  // Get Started Button
                  SizedBox(
                    width: sw,
                    child: ElevatedButton(
                      onPressed: validateAndSubmit,
                      style: AppButtonStyles.blackButton(context),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: sw * 0.06,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.03),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String hint,
    double sw,
    double sh,
    TextEditingController controller,
    String? errorText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: TextStyle(fontSize: sw * 0.04),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: sw * 0.04),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.018,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.errorMessage
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.errorMessage
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.errorMessage
                    : AppColors.mainColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        // Error message
        SizedBox(
          height: sh * 0.025,
          child: errorText != null
              ? Padding(
                  padding: EdgeInsets.only(top: sh * 0.005, left: sw * 0.01),
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: AppColors.errorMessage,
                      fontSize: sw * 0.032,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    String hint,
    double sw,
    double sh,
    TextEditingController controller,
    String? errorText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: sw * 0.04),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: sw * 0.04,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04,
                  vertical: sh * 0.018,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
                  size: sw * 0.05,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: errorText != null
                        ? AppColors.errorMessage
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: errorText != null
                        ? AppColors.errorMessage
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: errorText != null
                        ? AppColors.errorMessage
                        : AppColors.mainColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Error message
        SizedBox(
          height: sh * 0.025,
          child: errorText != null
              ? Padding(
                  padding: EdgeInsets.only(top: sh * 0.005, left: sw * 0.01),
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: AppColors.errorMessage,
                      fontSize: sw * 0.032,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildCustomDropdownField(
    BuildContext context,
    String hint,
    double sw,
    double sh,
    String? value,
    String? errorText,
    VoidCallback onTap, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.018,
            ),
            decoration: BoxDecoration(
              color: enabled ? Colors.grey[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null
                    ? AppColors.errorMessage
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    color: value != null ? Colors.black : Colors.grey[400],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? Colors.grey[600] : Colors.grey[400],
                  size: sw * 0.06,
                ),
              ],
            ),
          ),
        ),
        // Error message
        SizedBox(
          height: sh * 0.025,
          child: errorText != null
              ? Padding(
                  padding: EdgeInsets.only(top: sh * 0.005, left: sw * 0.01),
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: AppColors.errorMessage,
                      fontSize: sw * 0.032,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

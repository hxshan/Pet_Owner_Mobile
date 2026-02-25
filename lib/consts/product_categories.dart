class ProductCategories {
  ProductCategories._();

  // Must match backend EXACTLY (these are the values stored in DB)
  static const String food = "Food";
  static const String toys = "Toys";
  static const String grooming = "Grooming";
  static const String housingAndBedding = "Housing & Bedding";
  static const String healthAndWellness = "Health & Wellness";
  static const String accessories = "Accessories";
  static const String aquarium = "Aquarium";
  static const String other = "Other";

  // For UI filter chips / dropdowns
  static const String all = "All";

  // Use this list to build filter UI
  static const List<String> filterOptions = [
    all,
    food,
    toys,
    grooming,
    housingAndBedding,
    healthAndWellness,
    accessories,
    aquarium,
    other,
  ];

  // When calling API: backend should NOT receive "All"
  static String? toApiCategory(String selected) {
    if (selected == all) return null;
    return selected; // already matches backend enum strings
  }

  static bool isValidBackendCategory(String value) {
    return backendValues.contains(value);
  }

  static const List<String> backendValues = [
    food,
    toys,
    grooming,
    housingAndBedding,
    healthAndWellness,
    accessories,
    aquarium,
    other,
  ];
}
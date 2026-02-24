class DietPlanGenerateRequest {
  final String petId;
  final double ageMonths;
  final double weightKg;
  final String activityLevel; // Low/Medium/High
  final String disease;
  final String allergy;

  DietPlanGenerateRequest({
    required this.petId,
    required this.ageMonths,
    required this.weightKg,
    required this.activityLevel,
    required this.disease,
    required this.allergy,
  });

  Map<String, dynamic> toJson() => {
        "petId": petId,
        "ageMonths": ageMonths,
        "weightKg": weightKg,
        "activityLevel": activityLevel,
        "disease": disease,
        "allergy": allergy,
      };
}

class DietPlanResponse {
  final Map<String, dynamic> raw; // keep raw for fast UI binding
  DietPlanResponse(this.raw);

  Map<String, dynamic> get nutrition => (raw["nutrition"] as Map?)?.cast<String, dynamic>() ?? {};
  List<dynamic> get meals => (raw["meals"] as List?) ?? [];
  List<dynamic> get warnings => (raw["warnings"] as List?) ?? [];
  List<dynamic> get tips => (raw["tips"] as List?) ?? [];

  String get id => (raw["_id"] ?? "").toString();
  String get petId => (raw["petId"] ?? "").toString();
}

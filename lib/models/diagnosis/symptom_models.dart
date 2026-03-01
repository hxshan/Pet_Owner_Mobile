
class Symptom {
  final String id;
  final String name;
  final String category;
  final String icon;

  Symptom({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
}

class SymptomCategory {
  final String id;
  final String name;
  final String icon;

  SymptomCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class Diagnosis {
  final String id;
  final String condition;
  final int confidence;
  final String severity;
  final String description;
  final String action;
  final String? otcMedication;

  Diagnosis({
    required this.id,
    required this.condition,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.action,
    this.otcMedication,
  });
}

class SkinDiagnosis {
  final String id;
  final String condition;
  final int confidence;
  final String severity;
  final String description;
  final String action;
  final String? otcMedication;
  final List<String> commonCauses;

  SkinDiagnosis({
    required this.id,
    required this.condition,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.action,
    this.otcMedication,
    required this.commonCauses,
  });
}
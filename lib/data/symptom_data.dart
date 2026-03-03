// lib/data/symptom_data.dart

import '../models/diagnosis/symptom_models.dart';

class SymptomData {
  static List<SymptomCategory> categories = [
    SymptomCategory(id: 'digestive', name: 'Digestive', icon: '🍽️'),
    SymptomCategory(id: 'behavioral', name: 'Behavioral', icon: '🐾'),
    SymptomCategory(id: 'respiratory', name: 'Respiratory', icon: '🫁'),
    SymptomCategory(id: 'skin', name: 'Skin & Coat', icon: '✨'),
    SymptomCategory(id: 'mobility', name: 'Movement', icon: '🦴'),
    SymptomCategory(id: 'other', name: 'Other', icon: '📋'),
  ];

  static List<Symptom> symptoms = [
    // Symptoms aligned with the ML model FEATURE_COLUMNS (only symptoms are collected from user)
    Symptom(id: 'itching', name: 'Itching / Scratching', category: 'skin', icon: '🔄'),
    Symptom(id: 'vomiting', name: 'Vomiting', category: 'digestive', icon: '🤮'),
    Symptom(id: 'diarrhea', name: 'Diarrhea', category: 'digestive', icon: '💩'),
    Symptom(id: 'loss_appetite', name: 'Loss of appetite', category: 'digestive', icon: '🍖'),
    Symptom(id: 'lethargy', name: 'Lethargy', category: 'behavioral', icon: '😴'),
    Symptom(id: 'coughing', name: 'Coughing', category: 'respiratory', icon: '😷'),
    Symptom(id: 'sneezing', name: 'Sneezing', category: 'respiratory', icon: '🤧'),
    Symptom(id: 'fleas_seen', name: 'Fleas seen', category: 'skin', icon: '🐜'),
    Symptom(id: 'worms_seen', name: 'Worms seen', category: 'digestive', icon: '🐛'),
    Symptom(id: 'red_skin', name: 'Red / irritated skin', category: 'skin', icon: '🩸'),
  ];

  static List<Diagnosis> mockDiagnoses = [
    Diagnosis(
      id: '1',
      condition: 'Gastroenteritis',
      confidence: 78,
      severity: 'medium',
      description: 'Inflammation of the stomach and intestines, often caused by dietary indiscretion or viral infection.',
      action: 'Monitor for 24 hours. Offer small amounts of water frequently.',
      otcMedication: 'Unflavored Pedialyte for hydration',
    ),
    Diagnosis(
      id: '2',
      condition: 'Food Allergy',
      confidence: 45,
      severity: 'low',
      description: 'Allergic reaction to certain ingredients in food, causing digestive upset.',
      action: 'Schedule vet appointment for allergy testing and dietary consultation.',
    ),
    Diagnosis(
      id: '3',
      condition: 'Intestinal Parasites',
      confidence: 62,
      severity: 'medium',
      description: 'Worms or other parasites affecting the digestive system.',
      action: 'Visit vet for fecal examination and appropriate deworming medication.',
    ),
  ];

  static List<SkinDiagnosis> mockSkinDiagnoses = [
    SkinDiagnosis(
      id: '1',
      condition: 'Hot Spot (Acute Moist Dermatitis)',
      confidence: 82,
      severity: 'medium',
      description: 'A localized area of skin inflammation and bacterial infection that appears red, moist, and irritated.',
      action: 'Clean the area gently with antibacterial wash. Keep your pet from licking the area.',
      otcMedication: 'Chlorhexidine antiseptic spray or wipes',
      commonCauses: ['Allergies', 'Insect bites', 'Poor grooming', 'Moisture trapped in fur'],
    ),
    SkinDiagnosis(
      id: '2',
      condition: 'Fungal Infection (Ringworm)',
      confidence: 58,
      severity: 'medium',
      description: 'A contagious fungal infection that causes circular patches of hair loss with crusty, scaly skin.',
      action: 'Schedule vet visit for fungal culture test and prescription antifungal treatment.',
      commonCauses: ['Contact with infected animals', 'Contaminated environment', 'Weakened immune system'],
    ),
    SkinDiagnosis(
      id: '3',
      condition: 'Allergic Dermatitis',
      confidence: 71,
      severity: 'low',
      description: 'Skin inflammation caused by an allergic reaction to environmental allergens, food, or fleas.',
      action: 'Identify and eliminate allergen source. Vet may prescribe antihistamines or steroids.',
      otcMedication: 'Hypoallergenic oatmeal shampoo, antihistamine (consult vet for dosage)',
      commonCauses: ['Pollen', 'Dust mites', 'Food ingredients', 'Flea bites'],
    ),
  ];
}
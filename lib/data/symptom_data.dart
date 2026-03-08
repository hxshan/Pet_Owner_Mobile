// lib/data/symptom_data.dart

import '../models/diagnosis/symptom_models.dart';

class SymptomData {
  static List<SymptomCategory> categories = [
    SymptomCategory(id: 'digestive', name: 'Digestive & Appetite'),
    SymptomCategory(id: 'skin', name: 'Skin & Coat'),
    SymptomCategory(id: 'urinary', name: 'Urinary'),
    SymptomCategory(id: 'general', name: 'General'),
    SymptomCategory(id: 'blood', name: 'Blood & Circulation'),
    SymptomCategory(id: 'wounds', name: 'Wounds & Injuries'),
  ];

  static List<Symptom> symptoms = [
    // Digestive & Appetite
    Symptom(id: 'vomiting', name: 'Vomiting', category: 'digestive'),
    Symptom(id: 'diarrhea', name: 'Diarrhea', category: 'digestive'),
    Symptom(id: 'loss_appetite', name: 'Loss of Appetite', category: 'digestive'),
    Symptom(id: 'dehydration', name: 'Dehydration', category: 'digestive'),

    // Skin & Coat
    Symptom(id: 'itching', name: 'Itching / Scratching', category: 'skin'),
    Symptom(id: 'red_skin', name: 'Red / Irritated Skin', category: 'skin'),
    Symptom(id: 'hair_loss', name: 'Hair Loss', category: 'skin'),
    Symptom(id: 'skin_lesions', name: 'Skin Lesions', category: 'skin'),

    // Wounds & Injuries
    Symptom(id: 'wounds', name: 'Wounds / Cuts', category: 'wounds'),
    Symptom(id: 'tick_exposure', name: 'Tick Exposure', category: 'wounds'),

    // Urinary
    Symptom(id: 'pain_urinating', name: 'Pain When Urinating', category: 'urinary'),
    Symptom(id: 'frequent_urination', name: 'Frequent Urination', category: 'urinary'),
    Symptom(id: 'blood_in_urine', name: 'Blood in Urine', category: 'urinary'),
    Symptom(id: 'dark_urine', name: 'Dark Urine', category: 'urinary'),

    // Blood & Circulation
    Symptom(id: 'pale_gums', name: 'Pale Gums', category: 'blood'),
    Symptom(id: 'pale_eyelids', name: 'Pale Eyelids', category: 'blood'),

    // General
    Symptom(id: 'fever', name: 'Fever', category: 'general'),
    Symptom(id: 'lethargy', name: 'Lethargy / Low Energy', category: 'general'),
  ];

  static List<SkinDiagnosis> mockSkinDiagnoses = [
    SkinDiagnosis(
      id: '1',
      condition: 'Hot Spot (Acute Moist Dermatitis)',
      confidence: 82,
      severity: 'moderate',
      description:
          'A localized area of skin inflammation and bacterial infection that appears red, moist, and irritated.',
      action:
          'Clean the area gently with antibacterial wash. Keep your pet from licking the area.',
      otcMedication: 'Chlorhexidine antiseptic spray or wipes',
      commonCauses: [
        'Allergies',
        'Insect bites',
        'Poor grooming',
        'Moisture trapped in fur',
      ],
    ),
    SkinDiagnosis(
      id: '2',
      condition: 'Fungal Infection (Ringworm)',
      confidence: 58,
      severity: 'moderate',
      description:
          'A contagious fungal infection that causes circular patches of hair loss with crusty, scaly skin.',
      action:
          'Schedule vet visit for fungal culture test and prescription antifungal treatment.',
      commonCauses: [
        'Contact with infected animals',
        'Contaminated environment',
        'Weakened immune system',
      ],
    ),
    SkinDiagnosis(
      id: '3',
      condition: 'Allergic Dermatitis',
      confidence: 71,
      severity: 'mild',
      description:
          'Skin inflammation caused by an allergic reaction to environmental allergens, food, or fleas.',
      action:
          'Identify and eliminate allergen source. Vet may prescribe antihistamines or steroids.',
      otcMedication:
          'Hypoallergenic oatmeal shampoo, antihistamine (consult vet for dosage)',
      commonCauses: ['Pollen', 'Dust mites', 'Food ingredients', 'Flea bites'],
    ),
  ];
}

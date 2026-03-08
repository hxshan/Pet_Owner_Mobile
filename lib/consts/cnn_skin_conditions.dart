/// Info map for CNN skin-condition prediction classes.
/// Keys match the `class` field returned by /predict-cnn exactly (case-sensitive).
const Map<String, Map<String, dynamic>> cnnSkinConditionInfo = {
  'ringworm': {
    'display_name': 'Ringworm (Dermatophytosis)',
    'severity': 'moderate',
    'description':
        'A highly contagious fungal infection caused by dermatophytes. It produces circular, scaly, crusty patches with hair loss. Despite the name, it is not caused by a worm.',
    'common_causes': [
      'Contact with infected animals or humans',
      'Contaminated bedding or grooming tools',
      'Weakened immune system',
      'Young or elderly pets',
    ],
    'action':
        'Isolate your pet and book a vet visit for a fungal culture confirmation. Antifungal treatment (topical or oral) is usually prescribed.',
    'otc_medication':
        'Antifungal sprays or creams containing miconazole or clotrimazole — always confirm with a vet first.',
  },
  'Dermatitis': {
    'display_name': 'Dermatitis (Skin Inflammation)',
    'severity': 'moderate',
    'description':
        'General inflammation of the skin that can have many causes including allergies, irritants, or infections. Presents as red, itchy, or flaky skin.',
    'common_causes': [
      'Environmental allergens (pollen, dust)',
      'Food sensitivities',
      'Flea bites',
      'Contact with irritating substances',
    ],
    'action':
        'Identify and remove the allergen source. A vet may recommend antihistamines, corticosteroids, or medicated shampoos.',
    'otc_medication':
        'Oatmeal-based shampoos and hydrocortisone sprays can provide short-term relief.',
  },
  'Fungal_infections': {
    'display_name': 'Fungal Skin Infection',
    'severity': 'moderate',
    'description':
        'Fungal organisms colonising the skin surface or coat, causing scaling, odour, discolouration, and itching. Includes yeast overgrowth (Malassezia) and other dermatophytes.',
    'common_causes': [
      'Warm, humid environments',
      'Skin folds or wounds',
      'Immune suppression',
      'Prolonged antibiotic use',
    ],
    'action':
        'A vet visit is recommended for a skin scraping test. Antifungal shampoos and systemic medication may be required.',
    'otc_medication':
        'Ketoconazole or miconazole-based pet shampoos for temporary relief.',
  },
  'Mange': {
    'display_name': 'Mange (Mite Infestation)',
    'severity': 'severe',
    'description':
        'A parasitic skin disease caused by microscopic mites. Sarcoptic mange (scabies) is intensely itchy and highly contagious. Demodectic mange is caused by Demodex mites and is less contagious.',
    'common_causes': [
      'Direct contact with an infected animal',
      'Weakened immune system (Demodex)',
      'Poor nutrition or living conditions',
    ],
    'action':
        'Vet visit is essential. Treatment involves prescription anti-parasitic medication. Isolate the pet to prevent spread.',
    'otc_medication': null,
  },
  'Healthy': {
    'display_name': 'Healthy Skin',
    'severity': 'none',
    'description':
        'The skin and coat appear normal with no signs of disease, infection, or parasites.',
    'common_causes': [],
    'action':
        'No treatment needed. Continue regular grooming and routine vet check-ups.',
    'otc_medication': null,
  },
  'Bacterial_infections': {
    'display_name': 'Bacterial Skin Infection (Pyoderma)',
    'severity': 'moderate',
    'description':
        'A bacterial infection of the skin, most commonly caused by Staphylococcus. Presents as pustules, crusts, red patches, or hot spots.',
    'common_causes': [
      'Broken or damaged skin',
      'Underlying allergies',
      'Hormonal imbalances',
      'Moisture trapped in skin folds',
    ],
    'action':
        'Consult a vet. Treatment usually involves topical or oral antibiotics and medicated shampoos.',
    'otc_medication':
        'Chlorhexidine antiseptic wash or spray for mild surface infections.',
  },
  'Hypersensitivity': {
    'display_name': 'Hypersensitivity / Allergic Reaction',
    'severity': 'mild',
    'description':
        'An exaggerated immune response to a specific allergen causing skin redness, hives, swelling, or intense itching.',
    'common_causes': [
      'Insect stings or bites',
      'Vaccination reactions',
      'New food or treats',
      'Environmental allergens',
    ],
    'action':
        'Remove the suspected allergen and monitor closely. Seek vet care if swelling or breathing difficulty occurs.',
    'otc_medication':
        'Diphenhydramine (Benadryl) — consult a vet for weight-appropriate dosage.',
  },
};

/// Fallback info for any CNN class not listed above.
Map<String, dynamic> cnnFallbackInfo(String rawClassName) => {
      'display_name': rawClassName.replaceAll('_', ' '),
      'severity': 'unknown',
      'description':
          'This condition was identified by the AI model. Please consult a veterinarian for a proper diagnosis and treatment plan.',
      'common_causes': [],
      'action': 'Schedule a vet visit for a professional evaluation.',
      'otc_medication': null,
    };

class StaffService {
  static List<Map<String, dynamic>> getDummyServicesByCategory(String categoryId) {
    // Placeholder function that returns dummy services based on category
    // This should be replaced with actual API call when implemented
    
    final Map<String, List<Map<String, dynamic>>> categoryServices = {
      'massage': [
        {'id': 'acupuncture', 'name': 'Acupuncture', 'isClass': false},
        {'id': 'thai_yoga', 'name': 'Thai Yoga Therapy Massage', 'isClass': false},
        {'id': 'sports_massage', 'name': 'Sports & Deep Tissue Massage', 'isClass': false},
        {'id': 'prenatal_massage', 'name': 'Prenatal Massage', 'isClass': false},
        {'id': 'acupuncture_cupping', 'name': 'Acupuncture with cupping', 'isClass': false},
        {'id': 'sports_massage_hot_stone', 'name': 'Sports & Deep Tissue Massage with hot stone', 'isClass': false},
        {'id': 'thai_yoga_hot_stone', 'name': 'Thai Yoga Therapy Massage with hot stone', 'isClass': false},
        {'id': 'prenatal_massage_duo', 'name': 'Prenatal Massage Duo', 'isClass': false},
      ],
      'fitness': [
        {'id': 'yoga_class', 'name': 'Yoga Class', 'isClass': true},
        {'id': 'pilates_class', 'name': 'Pilates Class', 'isClass': true},
        {'id': 'crossfit_class', 'name': 'CrossFit Class', 'isClass': true},
        {'id': 'spinning_class', 'name': 'Spinning Class', 'isClass': true},
      ],
    };

    return categoryServices[categoryId] ?? [];
  }

  static List<Map<String, dynamic>> getAllDummyServices() {
    return [
      // Massage services
      {'id': 'acupuncture', 'name': 'Acupuncture', 'isClass': false, 'categoryId': 'massage'},
      {'id': 'thai_yoga', 'name': 'Thai Yoga Therapy Massage', 'isClass': false, 'categoryId': 'massage'},
      {'id': 'sports_massage', 'name': 'Sports & Deep Tissue Massage', 'isClass': false, 'categoryId': 'massage'},
      {'id': 'prenatal_massage', 'name': 'Prenatal Massage', 'isClass': false, 'categoryId': 'massage'},
      {'id': 'acupuncture_cupping', 'name': 'Acupuncture with cupping', 'isClass': false, 'categoryId': 'massage'},
      {'id': 'sports_massage_hot_stone', 'name': 'Sports & Deep Tissue Massage with hot stone', 'isClass': false, 'categoryId': 'massage'},
      {'id': 'thai_yoga_hot_stone', 'name': 'Thai Yoga Therapy Massage with hot stone', 'isClass': false, 'categoryId': 'massage'},
      {'id': 'prenatal_massage_duo', 'name': 'Prenatal Massage Duo', 'isClass': false, 'categoryId': 'massage'},
      
      // Fitness classes
      {'id': 'yoga_class', 'name': 'Yoga Class', 'isClass': true, 'categoryId': 'fitness'},
      {'id': 'pilates_class', 'name': 'Pilates Class', 'isClass': true, 'categoryId': 'fitness'},
      {'id': 'crossfit_class', 'name': 'CrossFit Class', 'isClass': true, 'categoryId': 'fitness'},
      {'id': 'spinning_class', 'name': 'Spinning Class', 'isClass': true, 'categoryId': 'fitness'},
    ];
  }
}
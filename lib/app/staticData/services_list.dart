// lib/app/staticData/wellness_services.dart

// class Offerings {
//   final String id;
//   final String text;

//   const Offerings({required this.id, required this.text});
// }

class WellnessService {
  final String id;
  final String text;
  final String? parentId;
  final int? level;

  const WellnessService({required this.id, required this.text, this.level, this.parentId});
}

const List<WellnessService> wellnessServices = [
  WellnessService(id: 'acupuncture', text: 'Acupuncture', parentId: '', level: 2),
  WellnessService(id: 'audiology_1', text: 'Audiology'),
  WellnessService(id: 'auricular_therapy', text: 'Auricular therapy'),
  WellnessService(id: 'chiropody', text: 'Chiropody'),
  WellnessService(id: 'chiropractor', text: 'Chiropractor'),
  WellnessService(id: 'counselling', text: 'Counselling'),
  WellnessService(id: 'homeopathy', text: 'Homeopathy'),
  WellnessService(id: 'kinesiology', text: 'Kinesiology'),
  WellnessService(id: 'lactation_consultant', text: 'Lactation consultant'),
  WellnessService(id: 'massage_therapy', text: 'Massage therapy'),
  WellnessService(id: 'naturopathy', text: 'Naturopathy'),
  WellnessService(id: 'nutrition', text: 'Nutrition'),
  WellnessService(id: 'osteopathy', text: 'Osteopathy'),
  WellnessService(id: 'physiotherapy', text: 'Physiotherapy'),
  WellnessService(id: 'pranayama', text: 'Pranayama'),
  WellnessService(id: 'psychotherapy', text: 'Psychotherapy'),
  WellnessService(id: 'reflexology', text: 'Reflexology'),
  WellnessService(id: 'somatic_therapy', text: 'Somatic therapy'),
];

class Services {
  final String id;
  final String? parent_id;
  final String? slug;
  final String name;
  final String? description;
  final int? level;
  final String? is_active;

  const Services({
    required this.id,
    required this.parent_id,
    this.slug,
    required this.name,
    required this.description,
    required this.level,
    this.is_active,
  });
}

const List<Services> servicesList = [
  Services(
    id: "2d47fa8f-8e06-45ef-b54e-2c0f632c305f",
    parent_id: "d758eb48-8c5f-4f5c-a438-31e843a1401d",
    slug: "Body Treatments",
    name: "Body Wraps",
    description: null,
    level: 2,
    is_active: "true",
  ),
  Services(
    id: "4041e82f-f1cf-4e35-b0e6-f6d1d5e9f4b5",
    parent_id: "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
    slug: "health",
    name: "Audiology",
    description: null,
    level: 1,
    is_active: "true",
  ),
  Services(
    id: "5f50c9c3-d3c6-4871-9c30-4d2b59d237ab",
    parent_id: "d758eb48-8c5f-4f5c-a438-31e843a1401d",
    slug: "Body Treatments",
    name: "Body Scrubs",
    description: null,
    level: 2,
    is_active: "true",
  ),
  Services(
    id: "605e4f3d-e7f6-49ee-8aa9-9e5e7bfcac5c",
    parent_id: "e55a7926-103b-496f-a11f-4eb5a09a37a3",
    slug: "fitness",
    name: "Barre",
    description: null,
    level: 1,
    is_active: "true",
  ),
  Services(
    id: "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
    parent_id: null,
    slug: "health",
    name: "Health & Wellness",
    description: "Massage therapist, chiropractor, acupuncture, dietitian, physiotherapy...",
    level: 0,
    is_active: "true",
  ),
  Services(
    id: "88d191b6-ea7c-48f9-9a88-b10a48ec06f2",
    parent_id: "e8c93452-d3ac-4005-bcd1-a8978ab0e340",
    slug: "Eyelash and Eyebrow",
    name: "Eyelash extensions",
    description: null,
    level: 2,
    is_active: "true",
  ),
  Services(
    id: "b35114f0-2823-417b-9a18-0380580f00d2",
    parent_id: "e8c93452-d3ac-4005-bcd1-a8978ab0e340",
    slug: "Eyelash and Eyebrow",
    name: "Eyelash fills & removal",
    description: null,
    level: 2,
    is_active: "true",
  ),
  Services(
    id: "b68854fd-96b2-4643-9a0e-2f61a0ce87e4",
    parent_id: "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
    slug: "health",
    name: "Acupuncture",
    description: null,
    level: 1,
    is_active: "true",
  ),
  Services(
    id: "d06d4da7-dcda-4128-846f-3d9cd5cabe01",
    parent_id: null,
    slug: "beauty",
    name: "Beauty",
    description: "Hair stylist, nail salon, hair removal, makeup, lashes and brows, facial treatments...",
    level: 0,
    is_active: "true",
  ),
  Services(
    id: "d758eb48-8c5f-4f5c-a438-31e843a1401d",
    parent_id: "d06d4da7-dcda-4128-846f-3d9cd5cabe01",
    slug: "beauty",
    name: "Body Treatments",
    description: null,
    level: 1,
    is_active: "true",
  ),
  Services(
    id: "e55a7926-103b-496f-a11f-4eb5a09a37a3",
    parent_id: null,
    slug: "fitness",
    name: "Fitness Classes",
    description: "Group training, fitness classes, personal training...",
    level: 0,
    is_active: "true",
  ),
  Services(
    id: "e8c93452-d3ac-4005-bcd1-a8978ab0e340",
    parent_id: "d06d4da7-dcda-4128-846f-3d9cd5cabe01",
    slug: "beauty",
    name: "Eyelash and Eyebrow",
    description: null,
    level: 1,
    is_active: "true",
  ),
  Services(
    id: "f9977cbe-badb-4dd3-b63a-162b387fa85f",
    parent_id: "e55a7926-103b-496f-a11f-4eb5a09a37a3",
    slug: "fitness",
    name: "Animal Flow",
    description: null,
    level: 1,
    is_active: "true",
  ),
];



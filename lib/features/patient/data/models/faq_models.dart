/// CMS FAQ model grounded in Postman folder `15. CMS Content Management`

class FaqItemDto {
  final String id;
  final String question;
  final String answer;
  final String? category;
  final int? displayOrder;
  final String? status;
  final String? createdAt;

  const FaqItemDto({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.displayOrder,
    this.status,
    this.createdAt,
  });

  factory FaqItemDto.fromJson(Map<String, dynamic> json) {
    return FaqItemDto(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: json['category']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'PUBLISHED',
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    if (category != null) 'category': category,
    if (displayOrder != null) 'displayOrder': displayOrder,
    if (status != null) 'status': status,
    if (createdAt != null) 'createdAt': createdAt,
  };
}


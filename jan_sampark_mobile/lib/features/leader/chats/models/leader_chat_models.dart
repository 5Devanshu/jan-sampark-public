// Leader-specific chat request models.
// Chat list and room models are shared from voter module.

class CreateChatRequest {
  const CreateChatRequest({
    required this.title,
    this.description,
    this.targetGenders = const [],
    this.targetReligions = const [],
    this.targetAgeMin,
    this.targetAgeMax,
  });

  final String title;
  final String? description;
  final List<String> targetGenders;
  final List<String> targetReligions;
  final int? targetAgeMin;
  final int? targetAgeMax;

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    if (targetGenders.isNotEmpty) 'target_genders': targetGenders,
    if (targetReligions.isNotEmpty) 'target_religions': targetReligions,
    if (targetAgeMin != null) 'target_age_min': targetAgeMin,
    if (targetAgeMax != null) 'target_age_max': targetAgeMax,
  };
}

class PostMessageRequest {
  const PostMessageRequest({required this.content});
  final String content;
  Map<String, dynamic> toJson() => {'content': content};
}

class PinMessageRequest {
  const PinMessageRequest({required this.messageId});
  final String messageId;
  Map<String, dynamic> toJson() => {'message_id': messageId};
}

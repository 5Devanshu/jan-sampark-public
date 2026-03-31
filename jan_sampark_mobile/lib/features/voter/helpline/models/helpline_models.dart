class HelplineModel {
  const HelplineModel({
    required this.id,
    required this.name,
    required this.number,
    required this.category,
    required this.isSystem,
    required this.isActive,
    this.description,
    this.createdByCorporatorId,
  });

  final String id;
  final String name;
  final String number;
  final String category;
  final bool isSystem;
  final bool isActive;
  final String? description;
  final String? createdByCorporatorId;

  factory HelplineModel.fromJson(Map<String, dynamic> json) {
    return HelplineModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      number: json['number'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isSystem: json['is_system'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
      createdByCorporatorId: json['created_by_corporator_id'] as String?,
    );
  }
}

class HelplineListResponse {
  const HelplineListResponse({
    required this.data,
    required this.total,
    required this.systemCount,
    required this.customCount,
  });

  final List<HelplineModel> data;
  final int total;
  final int systemCount;
  final int customCount;

  factory HelplineListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => HelplineModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return HelplineListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      systemCount: json['system_count'] as int? ?? 0,
      customCount: json['custom_count'] as int? ?? 0,
    );
  }
}

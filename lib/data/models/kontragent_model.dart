import 'package:odata_admin_panel/domain/entities/kontragent.dart' as domain;

class KontragentModel {
  final String guid;
  final String? name;
  final String? edrpou;
  final bool isFolder;
  final String? parentGuid;
  final String? description;
  final DateTime createdAt;

  const KontragentModel({
    required this.guid,
    this.name,
    this.edrpou,
    required this.isFolder,
    this.parentGuid,
    this.description,
    required this.createdAt,
  });

  factory KontragentModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'] as String;
    final createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();

    return KontragentModel(
      guid: json['guid'] as String,
      name: json['name'] as String?,
      edrpou: json['edrpou'] as String?,
      isFolder: (json['is_folder'] as bool?) ?? false,
      parentGuid: json['parent_guid'] as String?,
      description: json['description'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'guid': guid,
        if (name != null) 'name': name,
        if (edrpou != null) 'edrpou': edrpou,
        'is_folder': isFolder,
        if (parentGuid != null) 'parent_guid': parentGuid,
        if (description != null) 'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  domain.Kontragent toDomain() => domain.Kontragent(
        guid: guid,
        name: name,
        edrpou: edrpou,
        isFolder: isFolder,
        parentGuid: parentGuid,
        description: description,
        createdAt: createdAt,
      );
}


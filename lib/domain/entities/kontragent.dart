import 'package:equatable/equatable.dart';

class Kontragent extends Equatable {
  final String guid;
  final String? name;
  final String? edrpou;
  final bool isFolder;
  final String? parentGuid;
  final String? description;
  final DateTime createdAt;

  const Kontragent({
    required this.guid,
    this.name,
    this.edrpou,
    required this.isFolder,
    this.parentGuid,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        guid,
        name,
        edrpou,
        isFolder,
        parentGuid,
        description,
        createdAt,
      ];
}


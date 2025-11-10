part of 'kontragent_tree_cubit.dart';

/// Абстрактний базовий клас для всіх вузлів дерева
abstract class TreeNode extends Equatable {
  final String id;
  final String name;
  final int level; // 0 = корінь, 1 = перший рівень, 2 = другий рівень, тощо
  final String? parentGuid;

  const TreeNode({
    required this.id,
    required this.name,
    required this.level,
    this.parentGuid,
  });

  bool get isFolder;

  @override
  List<Object?> get props => [id, name, level, parentGuid];
}

/// "Папка" (контрагент з is_folder == true)
class FolderNode extends TreeNode {
  final List<TreeNode> children;

  const FolderNode({
    required super.id,
    required super.name,
    required super.level,
    this.children = const [],
    super.parentGuid,
  });

  @override
  bool get isFolder => true;

  @override
  List<Object?> get props => [id, name, level, parentGuid, children];
}

/// "Лист" (контрагент з is_folder == false)
class LeafNode extends TreeNode {
  const LeafNode({
    required super.id,
    required super.name,
    required super.level,
    super.parentGuid,
  });

  @override
  bool get isFolder => false;

  @override
  List<Object?> get props => [id, name, level, parentGuid];
}

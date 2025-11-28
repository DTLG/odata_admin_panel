part of 'kontragent_tree_cubit.dart';

enum TreeStatus { loading, success, failure }

class KontragentTreeState extends Equatable {
  final TreeStatus status;
  final String? message;

  /// "Джерело правди" - зберігає ВСІ вузли (папки, листи)
  /// у вигляді мапи для швидкого доступу O(1)
  final Map<String, TreeNode> nodes;

  /// Зберігає ID папок, які зараз розгорнуті
  /// Це джерело правди про стан UI (що розгорнуто, що приховано)
  final Set<String> expandedNodeIds;

  /// "Видимий список" - плаский список ID, який показує ListView.builder
  /// Це похідний список (він залежить від 'nodes' та 'expandedNodeIds')
  final List<String> flatVisibleList;

  /// Обрані (позначені чекбоксом) вузли. Якщо позначено папку,
  /// у цей набір додаються також усі її нащадки.
  final Set<String> selectedNodeIds;

  const KontragentTreeState({
    this.status = TreeStatus.loading,
    this.message,
    this.nodes = const {},
    this.expandedNodeIds = const {},
    this.flatVisibleList = const [],
    this.selectedNodeIds = const {},
  });

  KontragentTreeState copyWith({
    TreeStatus? status,
    String? message,
    Map<String, TreeNode>? nodes,
    Set<String>? expandedNodeIds,
    List<String>? flatVisibleList,
    Set<String>? selectedNodeIds,
  }) {
    return KontragentTreeState(
      status: status ?? this.status,
      message: message ?? this.message,
      nodes: nodes ?? this.nodes,
      expandedNodeIds: expandedNodeIds ?? this.expandedNodeIds,
      flatVisibleList: flatVisibleList ?? this.flatVisibleList,
      selectedNodeIds: selectedNodeIds ?? this.selectedNodeIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    nodes,
    expandedNodeIds,
    flatVisibleList,
    selectedNodeIds,
  ];
}

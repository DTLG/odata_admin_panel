import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/domain/entities/kontragent.dart';
import 'package:odata_admin_panel/domain/usecases/3_kontragenty/get_kontragenty.dart';

part 'kontragent_tree_state.dart';
part 'kontragent_tree_node.dart';

class KontragentTreeCubit extends Cubit<KontragentTreeState> {
  final GetKontragenty _getKontragenty;
  final String _schemaName;

  KontragentTreeCubit(this._getKontragenty, this._schemaName)
    : super(const KontragentTreeState()) {
    loadTree();
  }

  /// Завантаження дерева контрагентів
  Future<void> loadTree() async {
    emit(state.copyWith(status: TreeStatus.loading));
    try {
      final kontragenty = await _getKontragenty(_schemaName);

      // Будуємо дерево з контрагентів
      final nodes = _buildTree(kontragenty);

      // Створюємо початковий "плаский" список (лише кореневі елементи)
      // Початковий стан - всі папки згорнуті (expandedNodeIds порожній)
      final flatList = _flattenTree(nodes, const {});

      emit(
        state.copyWith(
          status: TreeStatus.success,
          nodes: nodes,
          expandedNodeIds: const {},
          flatVisibleList: flatList,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: TreeStatus.failure, message: e.toString()));
    }
  }

  /// Головна логіка - перемикання вузла (розгорнути/згорнути)
  /// Тепер це проста операція O(1) - додаємо/видаляємо ID з Set
  void toggleNode(String nodeId) {
    final node = state.nodes[nodeId];
    if (node == null || !node.isFolder) return;

    // Створюємо новий Set з оновленим станом розгорнутості
    final newExpandedIds = Set<String>.from(state.expandedNodeIds);
    if (newExpandedIds.contains(nodeId)) {
      newExpandedIds.remove(nodeId);
    } else {
      newExpandedIds.add(nodeId);
    }

    // "Вирівнюємо" (flatten) дерево на основі нового стану розгорнутості
    final newFlatList = _flattenTree(state.nodes, newExpandedIds);

    // Випромінюємо новий стан (дерево не змінюється, змінюється лише стан UI)
    emit(
      state.copyWith(
        expandedNodeIds: newExpandedIds,
        flatVisibleList: newFlatList,
      ),
    );
  }

  /// "ВИРІВНЮВАЧ" (FLATTENER)
  /// Перетворює вкладену мапу 'nodes' у плаский список 'flatVisibleList'
  /// Тепер використовує 'expandedNodeIds' замість 'node.isExpanded'
  List<String> _flattenTree(
    Map<String, TreeNode> allNodes,
    Set<String> expandedNodeIds,
  ) {
    final flatList = <String>[];

    // Отримуємо вузли верхнього рівня (де parentGuid == null)
    final rootNodes = allNodes.values
        .where((n) => n.parentGuid == null)
        .toList();

    // Рекурсивно додаємо вузли
    for (final node in rootNodes) {
      _flattenNode(node, allNodes, expandedNodeIds, flatList);
    }

    return flatList;
  }

  void _flattenNode(
    TreeNode node,
    Map<String, TreeNode> allNodes,
    Set<String> expandedNodeIds,
    List<String> flatList,
  ) {
    // Додаємо сам вузол
    flatList.add(node.id);

    // Якщо це папка і вона розгорнута, рекурсивно додаємо всіх її нащадків
    if (node is FolderNode && expandedNodeIds.contains(node.id)) {
      for (final child in node.children) {
        _flattenNode(child, allNodes, expandedNodeIds, flatList);
      }
    }
  }

  /// Будує дерево з плаского списку контрагентів
  /// (!!!) ОНОВЛЕНА ВЕРСІЯ, яка коректно обробляє
  /// (!!!) порожні рядки ("") та "сирітські" вузли.
  Map<String, TreeNode> _buildTree(List<Kontragent> kontragenty) {
    final nodes = <String, TreeNode>{};
    final childrenMap = <String?, List<Kontragent>>{};

    // (!!!) КРОК 1: Створюємо 'Set' всіх існуючих GUID'ів
    final allGuids = kontragenty.map((k) => k.guid).toSet();

    // Групуємо контрагенти за parentGuid
    for (final kontragent in kontragenty) {
      // (!!!) КРОК 2: "Нормалізуємо" parentGuid
      String? parentGuid = kontragent.parentGuid;

      // Вузол є кореневим, якщо:
      // 1. parentGuid = null
      // 2. parentGuid = "" (порожній рядок)
      // 3. parentGuid вказує на неіснуючого батька (це "сирота")
      if (parentGuid == null ||
          parentGuid.isEmpty ||
          !allGuids.contains(parentGuid)) {
        parentGuid = null; // Всі кореневі потраплять в 'childrenMap[null]'
      }

      childrenMap.putIfAbsent(parentGuid, () => []).add(kontragent);
    }

    // Функція для побудови вузла
    TreeNode buildNode(Kontragent kontragent, int level) {
      final children = childrenMap[kontragent.guid] ?? [];
      final childNodes = children.map((c) {
        final childLevel = level + 1;
        return buildNode(c, childLevel);
      }).toList();

      // (!!!) ФІКС: Я змінив цю логіку
      // 'isFolder' з вашого SQL-запиту тепер є головним
      // 'children.isNotEmpty' - це запасний варіант
      if (kontragent.isFolder || children.isNotEmpty) {
        return FolderNode(
          id: kontragent.guid,
          name: kontragent.name ?? 'Без назви',
          level: level,
          children: childNodes,
          parentGuid: kontragent.parentGuid,
        );
      } else {
        return LeafNode(
          id: kontragent.guid,
          name: kontragent.name ?? 'Без назви',
          level: level,
          parentGuid: kontragent.parentGuid,
        );
      }
    }

    // КРОК 3: Будуємо дерево з кореневих елементів
    // (Тепер це працює правильно, бо ми "нормалізували" parentGuid)
    final rootKontragenty = childrenMap[null] ?? [];
    for (final kontragent in rootKontragenty) {
      final node = buildNode(kontragent, 0);
      nodes[node.id] = node;
      _addChildrenToMap(node, nodes);
    }

    return nodes;
  }

  /// Рекурсивно додає всі дочірні вузли до мапи
  void _addChildrenToMap(TreeNode node, Map<String, TreeNode> nodes) {
    if (node is FolderNode) {
      for (final child in node.children) {
        nodes[child.id] = child;
        _addChildrenToMap(child, nodes);
      }
    }
  }
}

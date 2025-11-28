import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';
import 'package:odata_admin_panel/domain/usecases/3_kontragenty/get_kontragenty.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/bloc/kontragent_tree_cubit.dart';

class KontragentTreeView extends StatelessWidget {
  final String schemaName;
  final String userName;
  final String agentGuid;

  const KontragentTreeView({
    super.key,
    required this.schemaName,
    required this.userName,
    required this.agentGuid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KontragentTreeCubit(
        GetKontragenty(context.read<IAdminRepository>()),
        context.read<IAdminRepository>(),
        schemaName,
        agentGuid,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('Маршрути для $userName')),
        body: BlocBuilder<KontragentTreeCubit, KontragentTreeState>(
          builder: (context, state) {
            if (state.status == TreeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == TreeStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Помилка завантаження: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<KontragentTreeCubit>().loadTree();
                      },
                      child: const Text('Повторити'),
                    ),
                  ],
                ),
              );
            }

            if (state.flatVisibleList.isEmpty) {
              return const Center(child: Text('Контрагенти не знайдені'));
            }

            return ListView.builder(
              itemCount: state.flatVisibleList.length,
              itemBuilder: (context, index) {
                final nodeId = state.flatVisibleList[index];
                final node = state.nodes[nodeId];

                if (node == null) return const SizedBox.shrink();

                return _TreeNodeWidget(
                  node: node,
                  isExpanded: state.expandedNodeIds.contains(node.id),
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              icon: const Icon(Icons.save),
              label: const Text('Зберегти'),
              onPressed: () async {
                // Отримуємо тільки верхні (кореневі) обрані вузли без нащадків
                final topLevelIds = context
                    .read<KontragentTreeCubit>()
                    .getTopLevelSelectedIds();
                try {
                  await context.read<IAdminRepository>().setAgentRoutes(
                    agentGuid: agentGuid,
                    routeGuids: topLevelIds,
                  );
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Маршрути збережено')),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Помилка збереження: $e')),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

/// Віджет, що відповідає за відмальовку ОДНОГО рядка
class _TreeNodeWidget extends StatelessWidget {
  final TreeNode node;
  final bool isExpanded;

  const _TreeNodeWidget({required this.node, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    // Визначаємо відступ залежно від рівня вкладеності
    final padding = EdgeInsets.only(left: 16.0 + (node.level * 32.0));

    // Якщо це "Лист" (контрагент без дочірніх елементів)
    if (node is LeafNode) {
      return InkWell(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ви обрали: ${node.name}')));
        },
        child: Padding(
          padding: padding,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person, color: Colors.grey, size: 20),
            title: Text(
              node.name,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ),
      );
    }

    // Якщо це "Папка" (контрагент з дочірніми елементами)
    return InkWell(
      onTap: () {
        // Кажемо Cubit'у розгорнути/згорнути цей вузол
        context.read<KontragentTreeCubit>().toggleNode(node.id);
      },
      child: Padding(
        padding: padding,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<KontragentTreeCubit, KontragentTreeState>(
                buildWhen: (prev, curr) =>
                    prev.selectedNodeIds != curr.selectedNodeIds,
                builder: (context, state) {
                  final isChecked = state.selectedNodeIds.contains(node.id);
                  return Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      context.read<KontragentTreeCubit>().setNodeSelected(
                        node.id,
                        value ?? false,
                      );
                    },
                  );
                },
              ),
              Icon(
                Icons.folder,
                color: node.level == 0
                    ? Colors.blue.shade700
                    : Colors.blue.shade400,
                size: 20,
              ),
            ],
          ),
          title: Text(
            node.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          // Анімована іконка-стрілка
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.25 : 0, // 0.25 = 90 градусів
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.chevron_right, size: 20),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminNavigation extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const AdminNavigation({
    super.key,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onSelect,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.schema_outlined),
          selectedIcon: Icon(Icons.schema),
          label: Text('Schemas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Users'),
        ),
      ],
    );
  }
}

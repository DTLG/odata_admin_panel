import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:intl/intl.dart';
import 'package:odata_admin_panel/domain/entities/login_pin.dart';
import 'package:odata_admin_panel/domain/entities/user.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/bloc/map_cubit.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/bloc/map_state.dart';

class LoginMapView extends StatelessWidget {
  final String? initialAgentGuid;
  final String? userName;
  final String? schemaName;
  const LoginMapView({
    super.key,
    this.initialAgentGuid,
    this.userName,
    this.schemaName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(context.read<IAdminRepository>())
        ..loadInitialData(
          initialAgentGuid: initialAgentGuid,
          schemaName: schemaName!,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            userName != null ? 'Карта Логінів: $userName' : 'Карта Логінів',
          ),
        ),
        body: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            if (state is MapLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MapError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Помилка: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MapCubit>().loadInitialData(
                          initialAgentGuid: initialAgentGuid,
                          schemaName: schemaName!,
                        );
                      },
                      child: const Text('Повторити'),
                    ),
                  ],
                ),
              );
            }
            if (state is MapLoaded) {
              final isWideLayout = MediaQuery.of(context).size.width >= 900;
              if (isWideLayout) {
                return Row(
                  children: [
                    Expanded(child: _buildMap(context, state.pins)),
                    SizedBox(
                      width: 360,
                      child: _FilterPanel(
                        schemaName: schemaName!,
                        cubit: context.read<MapCubit>(),
                        currentFilters: state.filters,
                        allUsers: state.allUsers,
                        isEmbedded: true,
                      ),
                    ),
                  ],
                );
              }
              return Stack(
                children: [
                  _buildMap(context, state.pins),
                  _buildFilterButton(context, state.filters, state.allUsers),
                ],
              );
            }
            return const Center(child: Text('Ініціалізація...'));
          },
        ),
      ),
    );
  }

  // --- ВІДЖЕТ КАРТИ ---
  Widget _buildMap(BuildContext context, List<LoginPin> pins) {
    // Конвертуємо наші піни у маркери
    final markers = pins.map((pin) {
      return Marker(
        width: 30,
        height: 30,
        point: pin.point,
        child: const Icon(Icons.pin_drop, color: Colors.red),
      );
    }).toList();

    // Обчислюємо центр карти на основі пінів
    latlng.LatLng initialCenter = const latlng.LatLng(
      49.83,
      24.02,
    ); // Львів за замовчуванням
    double initialZoom = 6;

    if (pins.isNotEmpty) {
      double sumLat = 0;
      double sumLng = 0;
      for (final pin in pins) {
        sumLat += pin.point.latitude;
        sumLng += pin.point.longitude;
      }
      initialCenter = latlng.LatLng(sumLat / pins.length, sumLng / pins.length);
      initialZoom = pins.length == 1 ? 13 : 8;
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        // --- ✨ КЛАСТЕРИЗАЦІЯ ---
        // Це автоматично згрупує піни, що стоять близько
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            markers: markers,
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- ВІДЖЕТ ФІЛЬТРІВ ---
  Widget _buildFilterButton(
    BuildContext context,
    MapFilters currentFilters,
    List<User> allUsers,
  ) {
    return Positioned(
      top: 10,
      right: 10,
      child: FloatingActionButton(
        child: const Icon(Icons.filter_list),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => _FilterPanel(
              schemaName: schemaName!,
              cubit: context.read<MapCubit>(),
              currentFilters: currentFilters,
              allUsers: allUsers,
              onRequestClose: () => Navigator.pop(context),
            ),
          );
        },
      ),
    );
  }
}

class _FilterPanel extends StatefulWidget {
  final MapCubit cubit;
  final MapFilters currentFilters;
  final List<User> allUsers;
  final String schemaName;
  final bool isEmbedded;
  final VoidCallback? onRequestClose;
  const _FilterPanel({
    required this.cubit,
    required this.currentFilters,
    required this.allUsers,
    required this.schemaName,
    this.isEmbedded = false,
    this.onRequestClose,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late DateTime _startDate;
  late DateTime _endDate;
  late User? _selectedUser;

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilters.dateRange.start;
    _endDate = widget.currentFilters.dateRange.end;
    _selectedUser = widget.currentFilters.selectedUser;
  }

  void _handleApply() {
    final filters = MapFilters(
      dateRange: DateTimeRange(start: _startDate, end: _endDate),
      selectedUser: _selectedUser,
    );
    widget.cubit.applyFilters(filters, widget.schemaName);
    widget.onRequestClose?.call();
  }

  void _handleReset() {
    setState(() {
      _startDate = widget.currentFilters.dateRange.start;
      _endDate = widget.currentFilters.dateRange.end;
      _selectedUser = widget.currentFilters.selectedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy');

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: widget.isEmbedded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Text('Фільтри', style: materialTheme.textTheme.titleLarge),
        const SizedBox(height: 16),
        fluent.FluentTheme(
          data: fluent.FluentThemeData(
            brightness: materialTheme.brightness,
            accentColor: fluent.Colors.blue,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fluent.DatePicker(
                header: 'Від',
                selected: _startDate,
                startDate: DateTime(2020),
                endDate: DateTime.now(),
                onChanged: (value) {
                  setState(() {
                    _startDate = value;
                    if (_endDate.isBefore(_startDate)) {
                      _endDate = _startDate;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              fluent.DatePicker(
                header: 'До',
                selected: _endDate,
                startDate: DateTime(2020),
                endDate: DateTime.now(),
                onChanged: (value) {
                  setState(() {
                    _endDate = value;
                    if (_endDate.isBefore(_startDate)) {
                      _startDate = _endDate;
                    }
                  });
                },
              ),
            ],
          ),
        ),
        // const SizedBox(height: 16),
        // DropdownButtonFormField<User?>(
        //   value: _selectedUser,
        //   decoration: const InputDecoration(
        //     labelText: 'Користувач',
        //     border: OutlineInputBorder(),
        //   ),
        //   items: [
        //     const DropdownMenuItem<User?>(
        //       value: null,
        //       child: Text('Всі користувачі'),
        //     ),
        //     ...widget.allUsers.map(
        //       (user) => DropdownMenuItem<User?>(
        //         value: user,
        //         child: Text(user.displayName),
        //       ),
        //     ),
        //   ],
        //   onChanged: (value) => setState(() => _selectedUser = value),
        // ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _handleReset,
                child: const Text('Скинути'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleApply,
                child: const Text('Застосувати'),
              ),
            ),
          ],
        ),
        if (!widget.isEmbedded) const SizedBox(height: 24),
        if (!widget.isEmbedded)
          Text(
            '${dateFormat.format(_startDate)} — ${dateFormat.format(_endDate)}',
            style: materialTheme.textTheme.bodySmall,
          ),
      ],
    );

    if (widget.isEmbedded) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(child: content),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(child: content),
    );
  }
}

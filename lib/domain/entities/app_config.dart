import 'package:equatable/equatable.dart';

/// Entity для персонального конфігу користувача
/// Всі поля можуть бути null - означає "використати значення зі схеми"
class AppConfig extends Equatable {
  final bool? showLabelPrint;
  final bool? showNomenclature;
  final bool? showCustomerOrders;
  final bool? showInventoryCheck;
  final bool? showKontragenty;
  final bool? showRepairRequests;
  final bool? showStorages;
  final bool? showMovement;

  const AppConfig({
    this.showLabelPrint,
    this.showNomenclature,
    this.showCustomerOrders,
    this.showInventoryCheck,
    this.showKontragenty,
    this.showRepairRequests,
    this.showStorages,
    this.showMovement,
  });

  static AppConfig empty() => const AppConfig();

  AppConfig copyWith({
    bool? showLabelPrint,
    bool? showNomenclature,
    bool? showCustomerOrders,
    bool? showInventoryCheck,
    bool? showKontragenty,
    bool? showRepairRequests,
    bool? showStorages,
    bool? showMovement,
  }) {
    return AppConfig(
      showLabelPrint: showLabelPrint ?? this.showLabelPrint,
      showNomenclature: showNomenclature ?? this.showNomenclature,
      showCustomerOrders: showCustomerOrders ?? this.showCustomerOrders,
      showInventoryCheck: showInventoryCheck ?? this.showInventoryCheck,
      showKontragenty: showKontragenty ?? this.showKontragenty,
      showRepairRequests: showRepairRequests ?? this.showRepairRequests,
      showStorages: showStorages ?? this.showStorages,
      showMovement: showMovement ?? this.showMovement,
    );
  }

  Map<String, dynamic> toJson() => {
    'show_label_print': showLabelPrint,
    'show_nomenclature': showNomenclature,
    'show_customer_orders': showCustomerOrders,
    'show_inventory_check': showInventoryCheck,
    'show_kontragenty': showKontragenty,
    'show_repair_requests': showRepairRequests,
    'show_storages': showStorages,
    'show_movement': showMovement,
  };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      showLabelPrint: json['show_label_print'] as bool?,
      showNomenclature: json['show_nomenclature'] as bool?,
      showCustomerOrders: json['show_customer_orders'] as bool?,
      showInventoryCheck: json['show_inventory_check'] as bool?,
      showKontragenty: json['show_kontragenty'] as bool?,
      showRepairRequests: json['show_repair_requests'] as bool?,
      showStorages: json['show_storages'] as bool?,
      showMovement: json['show_movement'] as bool?,
    );
  }

  @override
  List<Object?> get props => [
    showLabelPrint,
    showNomenclature,
    showCustomerOrders,
    showInventoryCheck,
    showKontragenty,
    showRepairRequests,
    showStorages,
    showMovement,
  ];
}

import 'package:odata_admin_panel/domain/entities/app_config.dart' as domain;

/// Model (DTO) для персонального конфігу користувача
/// Всі поля можуть бути null - означає "використати значення зі схеми"
class AppConfigModel {
  final bool? showLabelPrint;
  final bool? showNomenclature;
  final bool? showCustomerOrders;
  final bool? showInventoryCheck;
  final bool? showKontragenty;
  final bool? showRepairRequests;
  final bool? showStorages;
  final bool? showMovement;

  const AppConfigModel({
    this.showLabelPrint,
    this.showNomenclature,
    this.showCustomerOrders,
    this.showInventoryCheck,
    this.showKontragenty,
    this.showRepairRequests,
    this.showStorages,
    this.showMovement,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
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

  domain.AppConfig toDomain() => domain.AppConfig(
    showLabelPrint: showLabelPrint,
    showNomenclature: showNomenclature,
    showCustomerOrders: showCustomerOrders,
    showInventoryCheck: showInventoryCheck,
    showKontragenty: showKontragenty,
    showRepairRequests: showRepairRequests,
    showStorages: showStorages,
    showMovement: showMovement,
  );

  static AppConfigModel fromDomain(domain.AppConfig config) {
    return AppConfigModel(
      showLabelPrint: config.showLabelPrint,
      showNomenclature: config.showNomenclature,
      showCustomerOrders: config.showCustomerOrders,
      showInventoryCheck: config.showInventoryCheck,
      showKontragenty: config.showKontragenty,
      showRepairRequests: config.showRepairRequests,
      showStorages: config.showStorages,
      showMovement: config.showMovement,
    );
  }
}

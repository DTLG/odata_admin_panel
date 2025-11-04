// Вам потрібно буде імпортувати ваш domain entity
import 'package:odata_admin_panel/domain/entities/schema_config.dart' as domain;

/* * =============================================================================
 * = ШАР ДАНИХ (Data Layer)
 * = ФАЙЛ: schema_config_model.dart
 * = МЕТА: Модель (DTO), яка відповідає JSON з Supabase 
 * =       і вміє конвертувати 'snake_case' в 'camelCase'.
 * =============================================================================
 */

class SchemaConfigModel {
  final bool showLabelPrint;
  final bool showNomenclature;
  final bool showCustomerOrders;
  final bool showInventoryCheck;
  final bool showKontragenty;
  final bool showRepairRequests;
  final bool showStorages;
  final bool showMovement;

  const SchemaConfigModel({
    required this.showLabelPrint,
    required this.showNomenclature,
    required this.showCustomerOrders,
    required this.showInventoryCheck,
    required this.showKontragenty,
    required this.showRepairRequests,
    required this.showStorages,
    required this.showMovement,
  });

  // (!!!) ГОЛОВНИЙ ФІКС
  // Цей 'fromJson' тепер "null-safe" і очікує правильні ключі.
  factory SchemaConfigModel.fromJson(Map<String, dynamic> json) {
    // Надаємо дефолтне значення 'true', якщо з бази приходить 'null'
    // (це виправляє вашу помилку "type 'Null' is not a subtype of...")
    return SchemaConfigModel(
      showLabelPrint: json['show_label_print'] as bool? ?? true,
      showNomenclature: json['show_nomenclature'] as bool? ?? true,
      showCustomerOrders: json['show_customer_orders'] as bool? ?? true,
      showInventoryCheck: json['show_inventory_check'] as bool? ?? true,
      showKontragenty: json['show_kontragenty'] as bool? ?? true,
      showRepairRequests: json['show_repair_requests'] as bool? ?? true,
      showStorages: json['show_storages'] as bool? ?? true,
      showMovement: json['show_movement'] as bool? ?? true,
    );
  }

  // (!!!) ГОЛОВНИЙ ФІКС V3
  // Конвертує 'camelCase' (з Dart) назад в 'snake_case' (для SQL)
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

  // Конвертація з Моделі (Data) в Сутність (Domain)
  domain.SchemaConfig toDomain() => domain.SchemaConfig(
    showLabelPrint: showLabelPrint,
    showNomenclature: showNomenclature,
    showCustomerOrders: showCustomerOrders,
    showInventoryCheck: showInventoryCheck,
    showKontragenty: showKontragenty,
    showRepairRequests: showRepairRequests,
    showStorages: showStorages,
    showMovement: showMovement,
  );

  // Конвертація з Сутності (Domain) в Модель (Data)
  static SchemaConfigModel fromDomain(domain.SchemaConfig config) =>
      SchemaConfigModel(
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

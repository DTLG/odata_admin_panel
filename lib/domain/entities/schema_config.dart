import 'package:equatable/equatable.dart';

class SchemaConfig extends Equatable {
  // Налаштування видимості іконок (дефолтні значення 'true')
  final bool showLabelPrint;
  final bool showNomenclature;
  final bool showCustomerOrders;
  final bool showInventoryCheck;
  final bool showKontragenty;
  final bool showRepairRequests;
  final bool showStorages;
  final bool showMovement;

  const SchemaConfig({
    this.showLabelPrint = true,
    this.showNomenclature = true,
    this.showCustomerOrders = true,
    this.showInventoryCheck = true,
    this.showKontragenty = true,
    this.showRepairRequests = true,
    this.showStorages = true,
    this.showMovement = true,
  });

  // copyWith для BLoC
  SchemaConfig copyWith({
    bool? showLabelPrint,
    bool? showNomenclature,
    bool? showCustomerOrders,
    bool? showInventoryCheck,
    bool? showKontragenty,
    bool? showRepairRequests,
    bool? showStorages,
    bool? showMovement,
  }) {
    return SchemaConfig(
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

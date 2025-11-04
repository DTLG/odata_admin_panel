import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/1_schema_config/bloc/generate_accounts_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:odata_admin_panel/data/datasources/admin_remote_datasource.dart';
import 'package:odata_admin_panel/data/repositories/admin_repository_impl.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/generate_accounts_usecase.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/1_schema_config/bloc/schema_config_cubit.dart';

class SchemaConfigView extends StatelessWidget {
  const SchemaConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchemaConfigCubit, SchemaConfigState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilledButton(
                    onPressed: () => context.read<SchemaConfigCubit>().load(),
                    child: const Text('Load Schemas'),
                  ),
                  const SizedBox(width: 12),
                  if (state.schemas.isNotEmpty)
                    DropdownButton<String>(
                      value: state.selectedSchema,
                      hint: const Text('Select schema'),
                      items: state.schemas
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (s) {
                        if (s != null)
                          context.read<SchemaConfigCubit>().selectSchema(s);
                      },
                    ),
                  const SizedBox(width: 12),
                  if (state.selectedSchema != null &&
                      state.missingConfig == false)
                    Builder(
                      builder: (ctx) {
                        return BlocProvider(
                          create: (_) {
                            final client = Supabase.instance.client;
                            final ds = AdminRemoteDataSource(client);
                            final repo = AdminRepositoryImpl(ds);
                            final usecase = GenerateAccountsUseCase(repo);
                            return GenerateAccountsCubit(usecase);
                          },
                          child: BlocConsumer<GenerateAccountsCubit, GenerateAccountsState>(
                            listener: (context, genState) {
                              if (genState.status == GenerateStatus.success ||
                                  genState.status == GenerateStatus.failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(genState.message),
                                    backgroundColor:
                                        genState.status ==
                                            GenerateStatus.failure
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                );
                              }
                            },
                            builder: (context, genState) {
                              return OutlinedButton.icon(
                                icon: const Icon(Icons.password),
                                label: const Text(
                                  'Згенерувати акаунти агентів',
                                ),
                                onPressed:
                                    genState.status == GenerateStatus.loading
                                    ? null
                                    : () {
                                        final controller =
                                            TextEditingController();
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: const Text('Підтвердження'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Генерація логінів/паролів для схеми "${state.selectedSchema}".',
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: controller,
                                                  decoration: const InputDecoration(
                                                    labelText:
                                                        'Пароль за замовчуванням',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  obscureText: true,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  dialogContext,
                                                ).pop(),
                                                child: const Text('Скасувати'),
                                              ),
                                              FilledButton(
                                                onPressed: () {
                                                  if (controller.text.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Пароль не може бути порожнім',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop();
                                                  context
                                                      .read<
                                                        GenerateAccountsCubit
                                                      >()
                                                      .generateAccounts(
                                                        schemaName: state
                                                            .selectedSchema!,
                                                        defaultPassword:
                                                            controller.text,
                                                      );
                                                },
                                                child: const Text(
                                                  'Підтвердити',
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (state.missingConfig) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    border: Border.all(color: Colors.amber),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Конфіг для цієї схеми відсутній',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Потрібно створити конфіг або повернутись до вибору схем.',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: state.loading
                                ? null
                                : () => context
                                      .read<SchemaConfigCubit>()
                                      .createDefaultConfig(),
                            child: const Text('Створити конфіг'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: state.loading
                                ? null
                                : () => context
                                      .read<SchemaConfigCubit>()
                                      .cancelMissing(),
                            child: const Text('Скасувати'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (state.config != null && state.missingConfig == false) ...[
                _FlagSwitch(
                  label: 'Label print',
                  value: state.config!.showLabelPrint,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showLabelPrint', v),
                ),
                _FlagSwitch(
                  label: 'Nomenclature',
                  value: state.config!.showNomenclature,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showNomenclature', v),
                ),
                _FlagSwitch(
                  label: 'Customer orders',
                  value: state.config!.showCustomerOrders,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showCustomerOrders', v),
                ),
                _FlagSwitch(
                  label: 'Inventory check',
                  value: state.config!.showInventoryCheck,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showInventoryCheck', v),
                ),
                _FlagSwitch(
                  label: 'Kontragenty',
                  value: state.config!.showKontragenty,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showKontragenty', v),
                ),
                _FlagSwitch(
                  label: 'Repair requests',
                  value: state.config!.showRepairRequests,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showRepairRequests', v),
                ),
                _FlagSwitch(
                  label: 'Storages',
                  value: state.config!.showStorages,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showStorages', v),
                ),
                _FlagSwitch(
                  label: 'Movement',
                  value: state.config!.showMovement,
                  onChanged: (v) => context
                      .read<SchemaConfigCubit>()
                      .updateFlag('showMovement', v),
                ),
              ],
              if (state.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FlagSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _FlagSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

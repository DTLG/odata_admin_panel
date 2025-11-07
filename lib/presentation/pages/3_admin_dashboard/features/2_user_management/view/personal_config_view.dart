import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/domain/entities/user.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/bloc/personal_config_cubit.dart';

class PersonalConfigView extends StatelessWidget {
  final User user; // Юзер, якого ми редагуємо
  const PersonalConfigView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PersonalConfigCubit(context.read<IAdminRepository>(), user.id)
            ..loadConfig(),
      child: Scaffold(
        appBar: AppBar(title: Text("Особистий конфіг для ${user.displayName}")),
        body: BlocBuilder<PersonalConfigCubit, PersonalConfigState>(
          builder: (context, state) {
            if (state.isLoading && state.config.showLabelPrint == null) {
              // Показуємо завантаження тільки якщо конфіг ще не завантажено
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Налаштування видимості кнопок. "За замовчуванням" означає, що буде використано налаштування всієї схеми. "Увімк" або "Вимк" перевизначають налаштування схеми.',
                  style: TextStyle(fontSize: 14),
                ),
                const Divider(height: 32),

                // Конфігураційні Dropdown'и
                _ConfigDropdown(
                  label: 'Друк етикеток',
                  value: state.config.showLabelPrint,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showLabelPrint: newValue),
                    );
                  },
                ),
                _ConfigDropdown(
                  label: 'Перевірка номенклатури',
                  value: state.config.showNomenclature,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showNomenclature: newValue),
                    );
                  },
                ),
                _ConfigDropdown(
                  label: 'Замовлення клієнтів',
                  value: state.config.showCustomerOrders,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showCustomerOrders: newValue),
                    );
                  },
                ),
                _ConfigDropdown(
                  label: 'Інвентаризація',
                  value: state.config.showInventoryCheck,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showInventoryCheck: newValue),
                    );
                  },
                ),
                _ConfigDropdown(
                  label: 'Контрагенти',
                  value: state.config.showKontragenty,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showKontragenty: newValue),
                    );
                  },
                ),
                _ConfigDropdown(
                  label: 'Заявки на ремонт',
                  value: state.config.showRepairRequests,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showRepairRequests: newValue),
                    );
                  },
                ),
                _ConfigDropdown(
                  label: 'Склади',
                  value: state.config.showStorages,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showStorages: newValue),
                    );
                  },
                ),
                _ConfigDropdown(
                  label: 'Переміщення',
                  value: state.config.showMovement,
                  onChanged: (newValue) {
                    context.read<PersonalConfigCubit>().configChanged(
                      state.config.copyWith(showMovement: newValue),
                    );
                  },
                ),

                const SizedBox(height: 32),
                if (state.message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: state.message.contains('Збережено')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<PersonalConfigCubit>().saveConfig(),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Зберегти особистий конфіг'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Спеціальний віджет Dropdown для 'bool?' (true/false/null)
class _ConfigDropdown extends StatelessWidget {
  final String label;
  final bool? value; // Може бути true, false або null
  final ValueChanged<bool?> onChanged;

  const _ConfigDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            const SizedBox(width: 16),
            DropdownButton<bool?>(
              value: value,
              // 3 опції
              items: const [
                DropdownMenuItem(
                  value: null, // null = "За замовчуванням"
                  child: Text('За замовчуванням (зі схеми)'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Увімкнено (Примусово)'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Вимкнено (Примусово)'),
                ),
              ],
              onChanged: (val) => onChanged(val),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/domain/entities/user.dart' as domain;
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/bloc/user_management_bloc.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/view/kontragent_tree_view.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/view/personal_config_view.dart';

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserManagementBloc, UserManagementState>(
      listenWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
      listener: (context, state) {
        if (state.updateStatus == UserUpdateStatus.success ||
            state.updateStatus == UserUpdateStatus.failure) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: state.updateStatus == UserUpdateStatus.failure
                  ? Colors.red
                  : Colors.green,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Керування Користувачами',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Пошук',
                hintText: 'Введіть email або логін для пошуку...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (term) {
                context.read<UserManagementBloc>().add(SearchTermChanged(term));
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _UserListView()),
          ],
        ),
      ),
    );
  }
}

class _UserListView extends StatelessWidget {
  const _UserListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementBloc, UserManagementState>(
      builder: (context, state) {
        switch (state.status) {
          case SearchStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case SearchStatus.failure:
            return Center(
              child: Text(
                'Помилка пошуку: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          case SearchStatus.initial:
            return const Center(child: Text('Почніть вводити для пошуку.'));
          case SearchStatus.success:
            if (state.users.isEmpty) {
              return const Center(child: Text('Користувачів не знайдено.'));
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                String title = user.originalName ?? user.login ?? user.email;
                String subtitle =
                    'Логін: ${user.login ?? user.email} | Схема: ${user.schemaName ?? "N/A"}';
                if (user.originalName != null &&
                    user.originalName == user.login) {
                  title = user.displayName;
                  subtitle =
                      'Email: ${user.email} | Схема: ${user.schemaName ?? "N/A"}';
                }
                return Card(
                  child: ListTile(
                    title: SelectableText(title),
                    subtitle: SelectableText(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        if (user.schemaName != null)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.route, size: 16),
                            label: const Text('Маршрути'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => KontragentTreeView(
                                    schemaName: user.schemaName!,
                                    userName: user.displayName,
                                  ),
                                ),
                              );
                            },
                          ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text('Конфіг'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PersonalConfigView(user: user),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Логін'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _showChangeLoginDialog(context, user);
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.lock_reset, size: 16),
                          label: const Text('Пароль'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _showChangePasswordDialog(context, user);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, domain.User user) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Функція генерації пароля з 8 символів
    String _generatePassword() {
      const lowercase = 'abcdefghijklmnopqrstuvwxyz';
      const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      const numbers = '0123456789';
      const allChars = lowercase + uppercase + numbers;

      final random = Random();
      final password = StringBuffer();

      // Гарантуємо хоча б одну велику літеру, одну малу та одну цифру
      password.write(uppercase[random.nextInt(uppercase.length)]);
      password.write(lowercase[random.nextInt(lowercase.length)]);
      password.write(numbers[random.nextInt(numbers.length)]);

      // Додаємо решту 5 символів випадково
      for (int i = 0; i < 5; i++) {
        password.write(allChars[random.nextInt(allChars.length)]);
      }

      // Перемішуємо символи
      final passwordList = password.toString().split('')..shuffle(random);
      return passwordList.join();
    }

    // Функція генерації та вставки пароля
    Future<void> _generateAndCopyPassword() async {
      final password = _generatePassword();
      passwordController.text = password;
      await Clipboard.setData(ClipboardData(text: password));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пароль згенеровано та скопійовано в буфер обміну'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<UserManagementBloc>(context),
          child: AlertDialog(
            title: const Text('Змінити пароль для:'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: passwordController,
                    // obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Новий пароль',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Згенерувати пароль',
                        onPressed: _generateAndCopyPassword,
                      ),
                    ),
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Пароль не може бути порожнім';
                    //   }
                    //   if (value.length < 6) {
                    //     return 'Пароль має бути > 6 символів';
                    //   }
                    //   return null;
                    // },
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _generateAndCopyPassword,
                  icon: const Icon(Icons.vpn_key, size: 18),
                  label: const Text('Згенерувати пароль'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Скасувати'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              BlocBuilder<UserManagementBloc, UserManagementState>(
                buildWhen: (p, c) => p.updateStatus != c.updateStatus,
                builder: (context, state) {
                  if (state.updateStatus == UserUpdateStatus.loading) {
                    return const FilledButton(
                      onPressed: null,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return FilledButton(
                    child: const Text('Зберегти'),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        context.read<UserManagementBloc>().add(
                          PasswordChangeRequested(
                            userId: user.id,
                            newPassword: passwordController.text,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangeLoginDialog(BuildContext context, domain.User user) {
    final loginController = TextEditingController(text: user.login ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<UserManagementBloc>(context),
          child: AlertDialog(
            title: Text('Змінити логін для: ${user.email}'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: loginController,
                decoration: const InputDecoration(
                  labelText: 'Новий логін',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Логін не може бути порожнім';
                  }
                  if (RegExp(r'[^a-z0-9._-]').hasMatch(value)) {
                    return 'Лише латиниця, цифри, крапка, дефіс';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Скасувати'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              BlocBuilder<UserManagementBloc, UserManagementState>(
                buildWhen: (p, c) => p.updateStatus != c.updateStatus,
                builder: (context, state) {
                  if (state.updateStatus == UserUpdateStatus.loading) {
                    return const FilledButton(
                      onPressed: null,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return FilledButton(
                    child: const Text('Зберегти'),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        context.read<UserManagementBloc>().add(
                          LoginChangeRequested(
                            userId: user.id,
                            newLogin: loginController.text.trim(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

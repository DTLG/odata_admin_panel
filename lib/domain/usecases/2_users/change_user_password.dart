import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class ChangeUserPassword {
  final IAdminRepository repository;
  const ChangeUserPassword(this.repository);

  Future<void> call({required String userId, required String newPassword}) =>
      repository.changeUserPassword(userId: userId, newPassword: newPassword);
}

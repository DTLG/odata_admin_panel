import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class ChangeUserLogin {
  final IAdminRepository repository;
  const ChangeUserLogin(this.repository);

  Future<void> call({required String userId, required String newLogin}) {
    return repository.changeUserLogin(userId: userId, newLogin: newLogin);
  }
}

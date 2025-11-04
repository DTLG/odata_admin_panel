import 'package:odata_admin_panel/domain/entities/user.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class SearchUsers {
  final IAdminRepository repository;
  const SearchUsers(this.repository);

  Future<List<User>> call(String query) => repository.searchUsers(query);
}

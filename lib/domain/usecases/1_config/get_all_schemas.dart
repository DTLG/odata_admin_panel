import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class GetAllSchemas {
  final IAdminRepository repository;
  const GetAllSchemas(this.repository);

  Future<List<String>> call() => repository.getAllSchemas();
}

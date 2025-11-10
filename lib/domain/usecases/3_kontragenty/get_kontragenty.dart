import 'package:odata_admin_panel/domain/entities/kontragent.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class GetKontragenty {
  final IAdminRepository repository;
  const GetKontragenty(this.repository);

  Future<List<Kontragent>> call(String schemaName) =>
      repository.getKontragenty(schemaName);
}


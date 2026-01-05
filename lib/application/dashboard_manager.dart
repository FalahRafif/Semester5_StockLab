import '../data/repositories/dashboard_repository.dart';
import '../data/models/dashboard_response.dart';

class DashboardManager {
  final DashboardRepository _repo = DashboardRepository();

  Future<DashboardResponse> getDashboard() async {
    return await _repo.getDashboard();
  }
}

import 'package:flutter/foundation.dart';
import '../../features/auth/data/models/user_context_model.dart';
import '../../features/auth/data/services/user_context_service.dart';

/// Global provider for user context from backend
/// This provides access to user data, roles, and scope throughout the app
class UserContextProvider extends ChangeNotifier {
  final UserContextService _service = UserContextService();

  UserContextModel? _userContext;
  bool _loading = false;
  String? _error;

  UserContextModel? get context => _userContext;
  UserContextModel? get userContext => _userContext;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _userContext != null;
  bool get hasContext => _userContext != null;

  /// Get roles as a list of strings
  List<String> get roles => _userContext?.roles ?? const [];

  /// Get scope as a map
  Map<String, dynamic> get scope => _userContext?.scope ?? const {};

  /// Check if user has a specific role
  bool hasRole(String role) => _userContext?.hasRole(role) ?? false;

  /// Check if user has any of the given roles
  bool hasAnyRole(List<String> roleList) =>
      _userContext?.hasAnyRole(roleList) ?? false;

  /// Load user context after login
  Future<bool> loadContextAfterLogin() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _userContext = await _service.fetchMe();
      _loading = false;
      _error = null;
      notifyListeners();
      return true;
    } on WaitingApprovalException {
      _loading = false;
      _error = 'WAITING_APPROVAL';
      _userContext = null;
      notifyListeners();
      return false;
    } on UnauthorizedException {
      _loading = false;
      _error = 'UNAUTHORIZED';
      _userContext = null;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      _userContext = null;
      notifyListeners();
      return false;
    }
  }

  /// Clear user context on logout
  void clear() {
    _userContext = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  /// Refresh user context
  Future<void> refresh() async {
    await loadContextAfterLogin();
  }
}

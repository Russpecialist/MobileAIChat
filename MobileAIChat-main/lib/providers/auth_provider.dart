import 'package:flutter/foundation.dart';
import '../api/openrouter_client.dart';
import '../models/auth_session.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final OpenRouterClient _api = OpenRouterClient();

  bool _isInitialized = false;
  bool _hasCredentials = false;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _generatedPin;
  AuthSession? _session;

  bool get isInitialized => _isInitialized;
  bool get hasCredentials => _hasCredentials;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get generatedPin => _generatedPin;
  AuthSession? get session => _session;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _hasCredentials = await _db.hasCredentials();
      _session = await _db.getSession();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithApiKey(String apiKey) async {
    _setLoading(true);
    _error = null;
    _generatedPin = null;
    try {
      final trimmedKey = apiKey.trim();
      if (trimmedKey.isEmpty) {
        _error = 'Введите API ключ';
        return false;
      }
      final provider = OpenRouterClient.detectProviderFromKey(trimmedKey);
      final baseUrl = OpenRouterClient.getBaseUrlByProvider(provider);
      _api.configure(
        apiKey: trimmedKey,
        provider: provider,
        baseUrl: baseUrl,
      );

      final balance = await _api.getBalanceValue();
      if (balance == null) {
        _error = 'Ключ невалиден или недоступен API';
        return false;
      }
      if (balance <= 0) {
        _error = 'Баланс должен быть положительным';
        return false;
      }

      final pin = _api.generatePin();
      await _db.saveCredentials(
        apiKey: trimmedKey,
        pin: pin,
        provider: provider,
        baseUrl: baseUrl,
      );
      _generatedPin = pin;
      _hasCredentials = true;
      _session = await _db.getSession();
      return true;
    } catch (e) {
      _error = 'Ошибка проверки ключа: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithPin(String pin) async {
    _setLoading(true);
    _error = null;
    try {
      final savedPin = await _db.getPin();
      if (savedPin == null) {
        _error = 'Ключ не найден, выполните вход заново';
        _hasCredentials = false;
        return false;
      }
      if (savedPin != pin.trim()) {
        _error = 'Неверный PIN';
        return false;
      }
      _session = await _db.getSession();
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _error = 'Ошибка входа: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetKey() async {
    _setLoading(true);
    try {
      await _db.clearCredentials();
      _hasCredentials = false;
      _isAuthenticated = false;
      _session = null;
      _generatedPin = null;
      _error = null;
    } finally {
      _setLoading(false);
    }
  }

  void dismissPinHint() {
    _generatedPin = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

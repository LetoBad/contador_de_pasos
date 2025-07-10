import 'package:flutter/material.dart';
import 'package:passos/models/paso_data.dart';
import '../models/paso_data.dart';
import '../services/healt_service.dart';

class StepsViewModel extends ChangeNotifier {
  final HealthService _healthService = HealthService();

  PasoData? _stepData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermissions = false;
  List<PasoDiaData>? _stepsHistory;
  bool _isLoadingHistory = false;
  String? _errorHistory;

  // Getters
  PasoData? get stepData => _stepData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPermissions => _hasPermissions;
  List<PasoDiaData>? get stepsHistory => _stepsHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorHistory => _errorHistory;

  /// Inicializa o ViewModel
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      final isAvailable = await _healthService.isHealthConnectAvailable();
      if (!isAvailable) {
        _setError('Health Connect não está disponível neste dispositivo');
        return;
      }

      _hasPermissions = await _healthService.hasPermissions();
      if (_hasPermissions) {
        await _loadStepData();
        await loadStepsHistory();
      }
    } catch (e) {
      _setError('Erro ao inicializar: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Solicita permissões para acessar dados de saúde
  Future<bool> requestPermissions() async {
    _setLoading(true);
    _clearError();

    try {
      final granted = await _healthService.requestPermissions();
      _hasPermissions = granted;

      if (granted) {
        await _loadStepData();
      } else {
        _setError('Permissões não concedidas');
      }

      return granted;
    } catch (e) {
      _setError('Erro ao solicitar permissões: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega os dados de passos se houver permissões
  Future<void> loadStepData() async {
    if (!_hasPermissions) {
      _setError('Permissões não concedidas');
      return;
    }

    await _loadStepData();
  }

  /// Força o recarregamento dos dados
  Future<void> refreshStepData() async {
    await _loadStepData();
    await loadStepsHistory();
  }

  /// Método privado para carregar dados
  Future<void> _loadStepData() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _healthService.getStepsLast24Hours();
      if (data != null) {
        _stepData = data;
      } else {
        _setError('Não foi possível carregar os dados de passos');
      }
    } catch (e) {
      _setError('Erro ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga el histórico de pasos de los últimos 7 días
  Future<void> loadStepsHistory() async {
    _isLoadingHistory = true;
    _errorHistory = null;
    notifyListeners();
    try {
      final data = await _healthService.getStepsLast7Days();
      _stepsHistory = data;
    } catch (e) {
      _errorHistory = 'Erro ao carregar histórico: $e';
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

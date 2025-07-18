import 'package:health/health.dart';
import 'package:passos/models/paso_data.dart';
import '../models/paso_data.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  // Tipos de dados que queremos acessar
  static const List<HealthDataType> _dataTypes = [HealthDataType.STEPS];

  // Permissões necessárias
  static const List<HealthDataAccess> _permissions = [HealthDataAccess.READ];

  /// Verifica se o Health Connect está disponível
  Future<bool> isHealthConnectAvailable() async {
    // A biblioteca 'health' não tem um método direto para verificar o Health Connect.
    // Uma abordagem é verificar a disponibilidade de um tipo de dado.
    return _health.isDataTypeAvailable(HealthDataType.STEPS);
  }

  /// Solicita permissões para acessar dados de saúde
  Future<bool> requestPermissions() async {
    try {
      // Solicita permissões do Health Connect
      bool requested = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );

      if (requested) {
        // Verifica se as permissões foram concedidas
        bool? hasPermissions = await _health.hasPermissions(_dataTypes);
        return hasPermissions ?? false;
      }

      return false;
    } catch (e) {
      print('Erro ao solicitar permissões: $e');
      return false;
    }
  }

  /// Obtém os dados de passos das últimas 24 horas
  Future<PasoData?> getStepsLast24Hours() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Busca dados de passos
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      if (healthData.isEmpty) {
        return PasoData(
          totalSteps: 0,
          date: now,
          source: 'Nenhum dado encontrado',
        );
      }

      // Filtra dados apenas do smartwatch (exclui dados do telefone)
      List<HealthDataPoint> watchData =
          healthData.where((dataPoint) {
            // Verifica se a fonte é um smartwatch
            String sourceName = dataPoint.sourceName.toLowerCase();
            return sourceName.contains('watch') ||
                sourceName.contains('wear') ||
                sourceName.contains('galaxy watch') ||
                sourceName.contains('pixel watch') ||
                sourceName.contains('fitbit');
          }).toList();

      // Se não encontrar dados do smartwatch, usa todos os dados disponíveis
      List<HealthDataPoint> dataToProcess =
          watchData.isNotEmpty ? watchData : healthData;

      if (dataToProcess.isEmpty) {
        return PasoData(
          totalSteps: 0,
          date: now,
          source: 'Nenhum dado de passos',
        );
      }

      // Calcula o total de passos
      int totalSteps = 0;
      String source = 'Health Connect';

      for (var dataPoint in dataToProcess) {
        if (dataPoint.value is NumericHealthValue) {
          totalSteps +=
              (dataPoint.value as NumericHealthValue).numericValue.toInt();
          source = dataPoint.sourceName;
        }
      }

      return PasoData(totalSteps: totalSteps, date: now, source: source);
    } catch (e) {
      print('Erro ao obter dados de passos: $e');
      return null;
    }
  }

  /// Verifica se o usuário tem permissões concedidas
  Future<bool> hasPermissions() async {
    // O método hasPermissions pode retornar nulo, então tratamos isso
    return await _health.hasPermissions(_dataTypes) ?? false;
  }

  /// Obtém os dados de passos dos últimos 7 dias (um total por dia)
  Future<List<PasoDiaData>> getStepsLast7Days() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: now,
      types: [HealthDataType.STEPS],
    );

    // Filtra dados apenas do smartwatch (exclui dados do telefone)
    List<HealthDataPoint> watchData =
        healthData.where((dataPoint) {
          String sourceName = dataPoint.sourceName.toLowerCase();
          return sourceName.contains('watch') ||
              sourceName.contains('wear') ||
              sourceName.contains('galaxy watch') ||
              sourceName.contains('pixel watch') ||
              sourceName.contains('fitbit');
        }).toList();
    List<HealthDataPoint> dataToProcess =
        watchData.isNotEmpty ? watchData : healthData;

    // Agrupa por día
    Map<String, int> stepsPerDay = {};
    for (var dataPoint in dataToProcess) {
      if (dataPoint.value is NumericHealthValue) {
        final date = DateTime(
          dataPoint.dateFrom.year,
          dataPoint.dateFrom.month,
          dataPoint.dateFrom.day,
        );
        final key = date.toIso8601String();
        stepsPerDay[key] =
            (stepsPerDay[key] ?? 0) +
            (dataPoint.value as NumericHealthValue).numericValue.toInt();
      }
    }

    // Genera la lista de los últimos 7 días (incluyendo días sin datos)
    List<PasoDiaData> result = [];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final date = DateTime(day.year, day.month, day.day);
      final key = date.toIso8601String();
      result.add(PasoDiaData(totalSteps: stepsPerDay[key] ?? 0, date: date));
    }
    return result;
  }
}

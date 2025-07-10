import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/pasos_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../copyright.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StepsViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Contador de Passos'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeViewModel.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => themeViewModel.toggleTheme(),
            tooltip: 'Alternar tema',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StepsViewModel>().refreshStepData(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<StepsViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async => await viewModel.refreshStepData(),
            color: Colors.tealAccent,
            backgroundColor: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildStepCountCard(viewModel),
                    const SizedBox(height: 16),
                    _buildHistoryChart(viewModel),
                    const SizedBox(height: 16),
                    _buildInfoCard(viewModel),
                    const SizedBox(height: 16),
                    _buildActionButtons(viewModel),
                    const SizedBox(height: 32),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.watch, size: 48, color: Colors.tealAccent[400]),
            const SizedBox(height: 12),
            Text(
              'Passos do Smartwatch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Últimas 24 horas',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCountCard(StepsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              viewModel.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : viewModel.errorMessage != null
                  ? Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        viewModel.errorMessage!,
                        style: TextStyle(color: Colors.red[400], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                  : viewModel.stepData != null
                  ? Column(
                    children: [
                      Text(
                        NumberFormat(
                          '#,###',
                        ).format(viewModel.stepData!.totalSteps),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Passos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Atualizado: ${DateFormat('dd/MM/yyyy HH:mm').format(viewModel.stepData!.date)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum dado disponível',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildHistoryChart(StepsViewModel viewModel) {
    if (viewModel.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorHistory != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            viewModel.errorHistory!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    final history = viewModel.stepsHistory;
    if (history == null || history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Sem histórico disponível',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico dos últimos 7 dias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      (history
                                  .map((e) => e.totalSteps)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2)
                          .clamp(1000, 10000)
                          .toDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= history.length)
                            return const SizedBox();
                          final date = history[idx].date;
                          return Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (int i = 0; i < history.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: history[i].totalSteps.toDouble(),
                            color: Colors.tealAccent[400],
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(StepsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  viewModel.hasPermissions ? Icons.check_circle : Icons.cancel,
                  color:
                      viewModel.hasPermissions ? Colors.white : Colors.red[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.hasPermissions
                      ? 'Permissões concedidas'
                      : 'Permissões não concedidas',
                  style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                ),
              ],
            ),
            if (viewModel.stepData != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.source,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fonte: ${viewModel.stepData!.source}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(StepsViewModel viewModel) {
    return Column(
      children: [
        if (!viewModel.hasPermissions)
          _buildFullWidthButton(
            icon: Icons.security,
            label: 'Solicitar Permissões',
            onPressed:
                viewModel.isLoading ? null : viewModel.requestPermissions,
            backgroundColor: Colors.tealAccent[400]!,
          ),
        if (viewModel.hasPermissions) ...[
          _buildFullWidthButton(
            icon: Icons.refresh,
            label: 'Atualizar Dados',
            onPressed: viewModel.isLoading ? null : viewModel.loadStepData,
            backgroundColor: Colors.tealAccent[400]!,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showHelpDialog(context),
              icon: Icon(Icons.help_outline, color: Colors.tealAccent[400]),
              label: Text(
                'Ajuda',
                style: TextStyle(color: Colors.tealAccent[400]),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.tealAccent[400]!),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFullWidthButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[850],
            title: Text(
              'Ajuda',
              style: TextStyle(color: Colors.tealAccent[400]),
            ),
            content: Text(
              'Este aplicativo obtém dados de passos exclusivamente do seu smartwatch por meio da plataforma Health Connect.\n\n'
              'Para assegurar a correta coleta das informações, recomendamos seguir os seguintes passos:\n'
              '1. Verifique se o seu smartwatch está devidamente conectado ao dispositivo\n'
              '2. Confirme que o aplicativo Health Connect está instalado\n'
              '3. Assegure-se de que todas as permissões necessárias foram concedidas\n'
              '4. Aguarde a sincronização completa dos dados entre os dispositivos',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Fechar',
                  style: TextStyle(color: Colors.tealAccent[400]),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        DireitosAutorais.aviso,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

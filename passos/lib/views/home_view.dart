import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/pasos_viewmodel.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Contador de Passos'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<StepsViewModel>().refreshStepData(),
          ),
        ],
      ),
      body: Consumer<StepsViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async => await viewModel.refreshStepData(),
            color: Colors.tealAccent,
            backgroundColor: Colors.grey[850],
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
                    _buildInfoCard(viewModel),
                    const SizedBox(height: 16),
                    _buildActionButtons(viewModel),
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
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : viewModel.errorMessage != null
                  ? Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
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
                              NumberFormat('#,###').format(viewModel.stepData!.totalSteps),
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
                            Icon(Icons.info_outline, size: 48, color: Colors.grey[500]),
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
                  color: viewModel.hasPermissions ? Colors.white : Colors.red[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.hasPermissions ? 'Permissões concedidas' : 'Permissões não concedidas',
                  style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                ),
              ],
            ),
            if (viewModel.stepData != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.source, color: const Color.fromARGB(255, 255, 255, 255), size: 20),
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
            onPressed: viewModel.isLoading ? null : viewModel.requestPermissions,
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
              label: Text('Ajuda', style: TextStyle(color: Colors.tealAccent[400])),
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
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Ajuda', style: TextStyle(color: Colors.tealAccent[400])),
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
            child: Text('Fechar', style: TextStyle(color: Colors.tealAccent[400])),
          ),
        ],
      ),
    );
  }
}


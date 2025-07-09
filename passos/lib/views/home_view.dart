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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Contador de Passos'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StepsViewModel>().refreshStepData();
            },
          ),
        ],
      ),
      body: Consumer<StepsViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async => await viewModel.refreshStepData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 20),
                    _buildStepCountCard(viewModel),
                    const SizedBox(height: 20),
                    _buildInfoCard(viewModel),
                    const SizedBox(height: 20),
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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.watch, size: 48, color: Colors.blueAccent),
            const SizedBox(height: 12),
            const Text(
              'Passos do Smartwatch',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Últimas 24 horas',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCountCard(StepsViewModel viewModel) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.errorMessage != null
                  ? Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
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
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Passos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Atualizado: ${DateFormat('dd/MM/yyyy HH:mm').format(viewModel.stepData!.date)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  )
                  : const Column(
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Nenhum dado disponível',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(StepsViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  viewModel.hasPermissions ? Icons.check_circle : Icons.cancel,
                  color: viewModel.hasPermissions ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.hasPermissions
                      ? 'Permissões concedidas'
                      : 'Permissões não concedidas',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (viewModel.stepData != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.source, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fonte: ${viewModel.stepData!.source}',
                      style: const TextStyle(fontSize: 14),
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
            backgroundColor: Colors.blueAccent,
          ),
        if (viewModel.hasPermissions) ...[
          _buildFullWidthButton(
            icon: Icons.refresh,
            label: 'Atualizar Dados',
            onPressed: viewModel.isLoading ? null : viewModel.loadStepData,
            backgroundColor: Colors.green,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showHelpDialog(context),
              icon: const Icon(Icons.help_outline),
              label: const Text('Ajuda'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.grey),
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
          foregroundColor: Colors.white,
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
            title: const Text('Ajuda'),
            content: const Text(
              'Este aplicativo obtém dados de passos exclusivamente do seu smartwatch por meio da plataforma Health Connect.\n\n'
              'Para assegurar a correta coleta das informações, recomendamos seguir os seguintes passos:\n'
              '1. Verifique se o seu smartwatch está devidamente conectado ao dispositivo\n'
              '2. Confirme que o aplicativo Health Connect está instalado\n'
              '3. Assegure-se de que todas as permissões necessárias foram concedidas\n'
              '4. Aguarde a sincronização completa dos dados entre os dispositivos',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }
}

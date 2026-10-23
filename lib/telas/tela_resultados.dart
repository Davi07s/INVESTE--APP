import 'package:flutter/material.dart';

import '../modelos/modelo_investimento.dart';

class TelaResultados extends StatelessWidget {
  const TelaResultados({
    super.key,
    required this.investimentoA,
    this.investimentoB,
  });
  final Investimento investimentoA;
  final Investimento? investimentoB;

  String _formatarMoeda(double valor) {
    if (valor.abs() >= 1e15) {
      return 'R\$ ${valor.toStringAsExponential(2).replaceAll('.', ',')}';
    }
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (resultado) => '${resultado[1]}.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

  Widget _construirResumo(
    BuildContext context,
    Investimento investimento,
    MaterialColor cor,
  ) {
    return Card(
      color: cor.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              investimento.nome,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: cor.shade800, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Montante Final'),
            Text(
              _formatarMoeda(investimento.montanteFinal),
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Rendimento Total'),
            Text(
              _formatarMoeda(investimento.rendimentoTotal),
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: cor.shade900, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total aplicado: ${_formatarMoeda(investimento.capitalInicial + investimento.aporteMensal * investimento.periodoMeses)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirValorMensal(
    String nome,
    EvolucaoMensal evolucao,
    MaterialColor cor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nome,
            style: TextStyle(color: cor.shade800, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _formatarMoeda(evolucao.montanteAcumulado),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text('Juros: ${_formatarMoeda(evolucao.rendimentoDoMes)}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final evolucaoA = investimentoA.calcularEvolucaoMensal();
    final evolucaoB = investimentoB?.calcularEvolucaoMensal();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          investimentoB == null
              ? 'Resultado do investimento'
              : 'Comparação de rendimentos',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: evolucaoA.length + 1,
              itemBuilder: (context, indice) {
                if (indice == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Seu dinheiro ao longo do tempo',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Projeção para ${investimentoA.periodoMeses} meses • aportes no fim do mês',
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, restricoes) {
                          final primeiro = _construirResumo(
                            context,
                            investimentoA,
                            Colors.blue,
                          );
                          if (investimentoB == null) return primeiro;
                          final segundo = _construirResumo(
                            context,
                            investimentoB!,
                            Colors.green,
                          );
                          return restricoes.maxWidth >= 680
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: primeiro),
                                    const SizedBox(width: 16),
                                    Expanded(child: segundo),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    primeiro,
                                    const SizedBox(height: 16),
                                    segundo,
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: 16),
                      // pop volta ao formulário preservando os dados para ajustes.
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Nova Simulação'),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Evolução mensal',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }
                final mesA = evolucaoA[indice - 1];
                final mesB = evolucaoB?[indice - 1];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mês ${mesA.mes}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _construirValorMensal(
                              'Investimento A',
                              mesA,
                              Colors.blue,
                            ),
                            if (mesB != null) ...[
                              const SizedBox(width: 16),
                              _construirValorMensal(
                                'Investimento B',
                                mesB,
                                Colors.green,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

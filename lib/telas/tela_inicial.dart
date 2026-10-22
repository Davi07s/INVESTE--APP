import 'package:flutter/material.dart';

import '../modelos/modelo_investimento.dart';
import 'tela_resultados.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});
  @override
  State<TelaInicial> createState() => _EstadoTelaInicial();
}

class _EstadoTelaInicial extends State<TelaInicial> {
  final chaveFormulario = GlobalKey<FormState>();
  final _controladores = List.generate(7, (_) => TextEditingController());
  bool _mostrarErros = false;
  String? _erroCalculo;

  @override
  void dispose() {
    for (final controlador in _controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  double? _converter(String valor) =>
      double.tryParse(valor.trim().replaceAll(',', '.'));

  Widget _construirCampoTexto(
    int indice,
    String rotulo, {
    bool prazo = false,
    String? sufixo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: _controladores[indice],
        keyboardType: prazo
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: rotulo, suffixText: sufixo),
        validator: (valor) {
          // Rejeitamos campos vazios, texto, infinitos e valores negativos.
          if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
          final numero = _converter(valor);
          if (numero == null || !numero.isFinite) {
            return 'Insira um número válido';
          }
          if (numero < 0) return 'O valor não pode ser negativo';
          if (prazo && int.tryParse(valor.trim()) == null) {
            return 'Informe meses inteiros';
          }
          if (prazo && (numero < 1 || numero > 1200)) {
            return 'Informe de 1 a 1200 meses';
          }
          return null;
        },
      ),
    );
  }

  Widget _construirInvestimento(String nome, int inicio, MaterialColor cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              nome,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: cor.shade800, fontWeight: FontWeight.bold),
            ),
            _construirCampoTexto(inicio, 'Capital inicial', sufixo: 'R\$'),
            _construirCampoTexto(inicio + 1, 'Aplicação mensal', sufixo: 'R\$'),
            _construirCampoTexto(
              inicio + 2,
              'Taxa de juros mensal',
              sufixo: '%',
            ),
          ],
        ),
      ),
    );
  }

  void _simular() {
    // setState atualiza a interface e ativa a validação após a primeira tentativa.
    setState(() {
      _mostrarErros = true;
      _erroCalculo = null;
    });
    if (!chaveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Investimento criar(String nome, int inicio) => Investimento(
      nome: nome,
      capitalInicial: _converter(_controladores[inicio].text)!,
      aporteMensal: _converter(_controladores[inicio + 1].text)!,
      taxaJurosMensal: _converter(_controladores[inicio + 2].text)!,
      periodoMeses: int.parse(_controladores[6].text.trim()),
    );
    try {
      final investimentoA = criar('Investimento A', 0);
      final investimentoB = criar('Investimento B', 3);
      // Calculamos antes de navegar para capturar erros numéricos no formulário.
      investimentoA.calcularEvolucaoMensal();
      investimentoB.calcularEvolucaoMensal();
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => TelaResultados(
            investimentoA: investimentoA,
            investimentoB: investimentoB,
          ),
        ),
      );
    } on ArgumentError catch (erro) {
      setState(() => _erroCalculo = erro.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Investimentos')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Form(
                key: chaveFormulario,
                autovalidateMode: _mostrarErros
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Compare hoje. Planeje o amanhã.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Informe dois investimentos. Use vírgula ou ponto para decimais, sem separadores de milhares.',
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, restricoes) {
                        final primeiro = _construirInvestimento(
                          'Investimento A',
                          0,
                          Colors.blue,
                        );
                        final segundo = _construirInvestimento(
                          'Investimento B',
                          3,
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  primeiro,
                                  const SizedBox(height: 16),
                                  segundo,
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 16),
                    _construirCampoTexto(
                      6,
                      'Prazo compartilhado em meses',
                      prazo: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aportes no fim de cada mês. Projeção com taxa fixa, sem impostos, tarifas ou inflação.',
                    ),
                    if (_erroCalculo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _erroCalculo!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _simular,
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Simular e Comparar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

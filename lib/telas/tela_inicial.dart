import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _comparar = false;
  UnidadePeriodo _unidadePeriodo = UnidadePeriodo.meses;
  final _unidadesTaxa = [UnidadeTaxa.mensal, UnidadeTaxa.mensal];
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

  double? _converterMoeda(String valor) =>
      double.tryParse(valor.replaceAll('.', '').replaceAll(',', '.'));

  Widget _construirCampoTexto(
    int indice,
    String rotulo, {
    bool prazo = false,
    String? sufixo,
  }) {
    final moeda = !prazo && indice % 3 != 2;
    final limite = _unidadePeriodo == UnidadePeriodo.anos ? 100 : 1200;
    final unidade = _unidadePeriodo == UnidadePeriodo.anos ? 'anos' : 'meses';
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        key: ValueKey('campo_$indice'),
        controller: _controladores[indice],
        inputFormatters: moeda ? [FormatadorMoeda()] : null,
        keyboardType: prazo
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: rotulo, suffixText: sufixo),
        validator: (valor) {
          // Rejeitamos campos vazios, texto, infinitos e valores negativos.
          if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
          final numero = moeda ? _converterMoeda(valor) : _converter(valor);
          if (numero == null || !numero.isFinite) {
            return 'Insira um número válido';
          }
          if (numero < 0) return 'O valor não pode ser negativo';
          if (prazo && int.tryParse(valor.trim()) == null) {
            return 'Informe $unidade inteiros';
          }
          if (prazo && (numero < 1 || numero > limite)) {
            return 'Informe de 1 a $limite $unidade';
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
            _construirCampoTexto(inicio + 2, 'Taxa de juros', sufixo: '%'),
            const SizedBox(height: 12),
            SegmentedButton<UnidadeTaxa>(
              segments: const [
                ButtonSegment(
                  value: UnidadeTaxa.mensal,
                  label: Text('Ao Mês (a.m.)'),
                ),
                ButtonSegment(
                  value: UnidadeTaxa.anual,
                  label: Text('Ao Ano (a.a.)'),
                ),
              ],
              selected: {_unidadesTaxa[inicio ~/ 3]},
              showSelectedIcon: false,
              onSelectionChanged: (selecao) =>
                  setState(() => _unidadesTaxa[inicio ~/ 3] = selecao.single),
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
    Investimento criar(String nome, int inicio) => Investimento.porUnidades(
      nome: nome,
      capitalInicial: _converterMoeda(_controladores[inicio].text)!,
      aporteMensal: _converterMoeda(_controladores[inicio + 1].text)!,
      taxaJuros: _converter(_controladores[inicio + 2].text)!,
      periodo: int.parse(_controladores[6].text.trim()),
      unidadePeriodo: _unidadePeriodo,
      unidadeTaxa: _unidadesTaxa[inicio ~/ 3],
    );
    try {
      final investimentoA = criar('Investimento A', 0);
      final investimentoB = _comparar ? criar('Investimento B', 3) : null;
      // Calculamos antes de navegar para capturar erros numéricos no formulário.
      investimentoA.calcularEvolucaoMensal();
      investimentoB?.calcularEvolucaoMensal();
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
      appBar: AppBar(title: const Text('Investe +')),
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
                      'Simule o seu investimento e compare',
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile.adaptive(
                      title: const Text('Adicionar Comparação'),
                      value: _comparar,
                      onChanged: (valor) => setState(() {
                        _comparar = valor;
                        _erroCalculo = null;
                      }),
                    ),
                    LayoutBuilder(
                      builder: (context, restricoes) {
                        final primeiro = _construirInvestimento(
                          'Investimento A',
                          0,
                          Colors.blue,
                        );
                        if (!_comparar) return primeiro;
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
                      'Prazo de investimento',
                      prazo: true,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<UnidadePeriodo>(
                      segments: const [
                        ButtonSegment(
                          value: UnidadePeriodo.meses,
                          label: Text('Meses'),
                        ),
                        ButtonSegment(
                          value: UnidadePeriodo.anos,
                          label: Text('Anos'),
                        ),
                      ],
                      selected: {_unidadePeriodo},
                      onSelectionChanged: (selecao) =>
                          setState(() => _unidadePeriodo = selecao.single),
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
                      label: Text(
                        _comparar
                            ? 'Simular e Comparar'
                            : 'Simular Investimento',
                      ),
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

/// Máscara em centavos, sem conversão para double, para preservar os dígitos.
class FormatadorMoeda extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue valorAntigo,
    TextEditingValue valorNovo,
  ) {
    if (valorNovo.text.isEmpty) return valorNovo;
    if (!RegExp(r'^[0-9.,]+$').hasMatch(valorNovo.text)) return valorAntigo;
    var digitos = valorNovo.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) return const TextEditingValue();
    digitos = digitos.replaceFirst(RegExp(r'^0+'), '').padLeft(3, '0');
    final inteiro = digitos
        .substring(0, digitos.length - 2)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (resultado) => '${resultado[1]}.',
        );
    final texto = '$inteiro,${digitos.substring(digitos.length - 2)}';
    if (texto == valorNovo.text) return valorNovo;
    // Mantém a posição lógica do cursor ao inserir separadores antes dele.
    final cursorOriginal = valorNovo.selection.extentOffset.clamp(
      0,
      valorNovo.text.length,
    );
    final digitosDireita = valorNovo.text
        .substring(cursorOriginal)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;
    var cursor = texto.length;
    var restantes = digitosDireita;
    while (cursor > 0 && restantes > 0) {
      cursor--;
      if (RegExp(r'[0-9]').hasMatch(texto[cursor])) restantes--;
    }
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investe_app/main.dart';
import 'package:investe_app/telas/tela_inicial.dart';

Future<void> preencher(WidgetTester avaliador, int indice, String valor) async {
  await avaliador.enterText(find.byKey(ValueKey('campo_$indice')), valor);
}

Future<void> tocar(WidgetTester avaliador, String texto) async {
  final alvo = find.text(texto).last;
  await avaliador.ensureVisible(alvo);
  await avaliador.tap(alvo);
  await avaliador.pumpAndSettle();
}

void main() {
  testWidgets('Formulário e resultados se adaptam a uma tela estreita', (
    avaliador,
  ) async {
    avaliador.view.physicalSize = const Size(360, 800);
    avaliador.view.devicePixelRatio = 1;
    addTearDown(avaliador.view.resetPhysicalSize);
    addTearDown(avaliador.view.resetDevicePixelRatio);
    await avaliador.pumpWidget(const AplicativoInvestimentos());
    expect(avaliador.takeException(), isNull);
    await preencher(avaliador, 0, '100050');
    await preencher(avaliador, 1, '0');
    await preencher(avaliador, 2, '0');
    await preencher(avaliador, 6, '1');
    await tocar(avaliador, 'Simular Investimento');
    expect(find.text('Montante Final'), findsOneWidget);
    expect(avaliador.takeException(), isNull);
  });

  test('Mascara centavos, colagem, exclusao e edicao no meio do valor', () {
    final formatador = FormatadorMoeda();
    TextEditingValue aplicar(String texto, {int? cursor}) =>
        formatador.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: texto,
            selection: TextSelection.collapsed(offset: cursor ?? texto.length),
          ),
        );
    expect(aplicar('100050').text, '1.000,50');
    expect(aplicar('1.000,50').text, '1.000,50');
    expect(aplicar('1').text, '0,01');
    expect(aplicar('').text, '');
    expect(aplicar('-1').text, '');
    final edicao = aplicar('12.000,50', cursor: 2);
    expect(edicao.text, '12.000,50');
    expect(edicao.selection.extentOffset, 2);
    expect(aplicar('000').text, '0,00');
  });

  testWidgets('Simula somente A com taxa anual e prazo em anos', (
    avaliador,
  ) async {
    await avaliador.pumpWidget(const AplicativoInvestimentos());
    await tocar(avaliador, 'Simular Investimento');
    expect(find.text('Campo obrigatório'), findsNWidgets(4));
    expect(find.text('Investimento B'), findsNothing);
    await preencher(avaliador, 0, '100000');
    await preencher(avaliador, 1, '0');
    await preencher(avaliador, 2, '12');
    await preencher(avaliador, 6, '1');
    await tocar(avaliador, 'Ao Ano (a.a.)');
    await tocar(avaliador, 'Anos');
    await tocar(avaliador, 'Simular Investimento');
    expect(find.text('Resultado do investimento'), findsOneWidget);
    expect(find.text('Montante Final'), findsOneWidget);
    expect(find.text('R\$ 1.120,00'), findsOneWidget);
    expect(find.text('Investimento B'), findsNothing);
    expect(find.textContaining('12 meses'), findsOneWidget);
    await tocar(avaliador, 'Nova Simulação');
    expect(
      avaliador
          .widget<TextFormField>(find.byKey(const ValueKey('campo_0')))
          .controller!
          .text,
      '1.000,00',
    );
  });

  testWidgets('Compara investimentos e ignora B ao desativar a comparacao', (
    avaliador,
  ) async {
    await avaliador.pumpWidget(const AplicativoInvestimentos());
    await avaliador.tap(find.byType(SwitchListTile));
    await avaliador.pumpAndSettle();
    await tocar(avaliador, 'Simular e Comparar');
    expect(find.text('Campo obrigatório'), findsNWidgets(7));
    final valores = ['100000', '10000', '1', '100000', '10000', '2', '2'];
    for (var indice = 0; indice < valores.length; indice++) {
      await preencher(avaliador, indice, valores[indice]);
    }
    await tocar(avaliador, 'Simular e Comparar');
    expect(find.text('Montante Final'), findsNWidgets(2));
    expect(find.text('R\$ 1.221,10'), findsWidgets);
    await tocar(avaliador, 'Nova Simulação');
    await preencher(avaliador, 5, 'texto');
    final alternador = find.byType(SwitchListTile);
    await avaliador.ensureVisible(alternador);
    await avaliador.tap(alternador);
    await avaliador.pumpAndSettle();
    await tocar(avaliador, 'Simular Investimento');
    expect(find.text('Resultado do investimento'), findsOneWidget);
    expect(find.text('Investimento B'), findsNothing);
  });

  testWidgets('Valida taxa negativa, prazo fracionario e limite em anos', (
    avaliador,
  ) async {
    await avaliador.pumpWidget(const AplicativoInvestimentos());
    await preencher(avaliador, 0, '0');
    await preencher(avaliador, 1, '0');
    await preencher(avaliador, 2, '-1');
    await preencher(avaliador, 6, '1,5');
    await tocar(avaliador, 'Simular Investimento');
    expect(find.text('O valor não pode ser negativo'), findsOneWidget);
    expect(find.text('Informe meses inteiros'), findsOneWidget);
    await preencher(avaliador, 2, 'NaN');
    await preencher(avaliador, 6, '101');
    await tocar(avaliador, 'Anos');
    await tocar(avaliador, 'Simular Investimento');
    expect(find.text('Insira um número válido'), findsOneWidget);
    expect(find.text('Informe de 1 a 100 anos'), findsOneWidget);
  });
}

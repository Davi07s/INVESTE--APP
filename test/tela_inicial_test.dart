import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investe_app/main.dart';

void main() {
  testWidgets(
    'Valida campos, compara investimentos e preserva os dados ao voltar',
    (avaliador) async {
      await avaliador.pumpWidget(const AplicativoInvestimentos());
      final botao = find.text('Simular e Comparar');
      await avaliador.ensureVisible(botao);
      await avaliador.tap(botao);
      await avaliador.pumpAndSettle();
      expect(find.text('Campo obrigatório'), findsNWidgets(7));
      final campos = find.byType(TextFormField);
      final valores = ['1000', '100', '1', '1000', '100', '2', '2'];
      for (var indice = 0; indice < valores.length; indice++) {
        await avaliador.enterText(campos.at(indice), valores[indice]);
      }
      await avaliador.ensureVisible(botao);
      await avaliador.tap(botao);
      await avaliador.pumpAndSettle();
      expect(find.text('Montante Final'), findsNWidgets(2));
      expect(find.text('R\$ 1.221,10'), findsWidgets);
      final voltar = find.text('Nova Simulação');
      await avaliador.ensureVisible(voltar);
      await avaliador.tap(voltar);
      await avaliador.pumpAndSettle();
      expect(find.text('Simular e Comparar'), findsOneWidget);
      expect(
        avaliador.widget<TextFormField>(campos.first).controller!.text,
        '1000',
      );
    },
  );

  testWidgets('Rejeita negativos, valores não finitos e prazo fracionário', (
    avaliador,
  ) async {
    await avaliador.pumpWidget(const AplicativoInvestimentos());
    final campos = find.byType(TextFormField);
    final valores = ['-1', 'NaN', 'texto', '0', '0', '0', '1,5'];
    for (var indice = 0; indice < valores.length; indice++) {
      await avaliador.enterText(campos.at(indice), valores[indice]);
    }
    final botao = find.text('Simular e Comparar');
    await avaliador.ensureVisible(botao);
    await avaliador.tap(botao);
    await avaliador.pumpAndSettle();
    expect(find.text('O valor não pode ser negativo'), findsOneWidget);
    expect(find.text('Insira um número válido'), findsNWidgets(2));
    expect(find.text('Informe meses inteiros'), findsOneWidget);
    expect(find.text('Montante Final'), findsNothing);
  });
}

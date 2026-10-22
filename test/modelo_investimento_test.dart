import 'package:flutter_test/flutter_test.dart';
import 'package:investe_app/modelos/modelo_investimento.dart';

void main() {
  test('Calcula juros compostos com aportes no fim do mês', () {
    final investimento = Investimento(
      nome: 'A',
      capitalInicial: 1000,
      aporteMensal: 100,
      taxaJurosMensal: 1,
      periodoMeses: 2,
    );
    final evolucao = investimento.calcularEvolucaoMensal();
    expect(evolucao.first.montanteAcumulado, 1110);
    expect(evolucao.last.rendimentoDoMes, closeTo(11.1, 0.00001));
    expect(investimento.montanteFinal, closeTo(1221.1, 0.00001));
    expect(investimento.rendimentoTotal, closeTo(21.1, 0.00001));
  });
  test('Taxa zero preserva o total aplicado', () {
    final investimento = Investimento(
      nome: 'B',
      capitalInicial: 200,
      aporteMensal: 50,
      taxaJurosMensal: 0,
      periodoMeses: 12,
    );
    expect(investimento.montanteFinal, 800);
    expect(investimento.rendimentoTotal, 0);
  });
  test('Rejeita dados inválidos e estouro numérico', () {
    expect(
      () => Investimento(
        nome: 'A',
        capitalInicial: -1,
        aporteMensal: 0,
        taxaJurosMensal: 0,
        periodoMeses: 1,
      ),
      throwsArgumentError,
    );
    expect(
      () => Investimento(
        nome: 'A',
        capitalInicial: 0,
        aporteMensal: 0,
        taxaJurosMensal: double.nan,
        periodoMeses: 1,
      ),
      throwsArgumentError,
    );
    expect(
      () => Investimento(
        nome: 'A',
        capitalInicial: 0,
        aporteMensal: 0,
        taxaJurosMensal: 0,
        periodoMeses: 0,
      ),
      throwsArgumentError,
    );
    final investimento = Investimento(
      nome: 'A',
      capitalInicial: 1e308,
      aporteMensal: 0,
      taxaJurosMensal: 100,
      periodoMeses: 2,
    );
    expect(investimento.calcularEvolucaoMensal, throwsArgumentError);
  });
}

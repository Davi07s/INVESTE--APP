import 'package:flutter_test/flutter_test.dart';
import 'package:investe_app/modelos/modelo_investimento.dart';

void main() {
  test('Converte taxa anual equivalente e prazo em anos', () {
    final investimento = Investimento.porUnidades(
      nome: 'A',
      capitalInicial: 1000,
      aporteMensal: 0,
      taxaJuros: 12,
      periodo: 1,
      unidadePeriodo: UnidadePeriodo.anos,
      unidadeTaxa: UnidadeTaxa.anual,
    );
    expect(investimento.periodoMeses, 12);
    expect(investimento.taxaJurosMensal, closeTo(0.9488792934583, 1e-10));
    expect(investimento.montanteFinal, closeTo(1120, 1e-8));
    final mensal = Investimento.porUnidades(
      nome: 'B',
      capitalInicial: 1000,
      aporteMensal: 100,
      taxaJuros: investimento.taxaJurosMensal,
      periodo: 12,
    );
    final anual = Investimento.porUnidades(
      nome: 'B',
      capitalInicial: 1000,
      aporteMensal: 100,
      taxaJuros: 12,
      periodo: 1,
      unidadePeriodo: UnidadePeriodo.anos,
      unidadeTaxa: UnidadeTaxa.anual,
    );
    expect(mensal.montanteFinal, closeTo(anual.montanteFinal, 1e-8));
  });
  test('Valida limites nas unidades de entrada', () {
    expect(
      () => Investimento.porUnidades(
        nome: 'A',
        capitalInicial: 0,
        aporteMensal: 0,
        taxaJuros: -1,
        periodo: 1,
        unidadeTaxa: UnidadeTaxa.anual,
      ),
      throwsArgumentError,
    );
    expect(
      () => Investimento.porUnidades(
        nome: 'A',
        capitalInicial: 0,
        aporteMensal: 0,
        taxaJuros: 0,
        periodo: 101,
        unidadePeriodo: UnidadePeriodo.anos,
      ),
      throwsArgumentError,
    );
    final investimento = Investimento.porUnidades(
      nome: 'A',
      capitalInicial: 100,
      aporteMensal: 0,
      taxaJuros: 0,
      periodo: 100,
      unidadePeriodo: UnidadePeriodo.anos,
      unidadeTaxa: UnidadeTaxa.anual,
    );
    expect(investimento.calcularEvolucaoMensal().length, 1200);
    expect(investimento.montanteFinal, 100);
  });

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

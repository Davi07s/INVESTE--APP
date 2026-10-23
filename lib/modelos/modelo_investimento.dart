import 'dart:math' as matematica;

enum UnidadePeriodo { meses, anos }

enum UnidadeTaxa { mensal, anual }

class EvolucaoMensal {
  const EvolucaoMensal({
    required this.mes,
    required this.montanteAcumulado,
    required this.rendimentoDoMes,
  });
  final int mes;
  final double montanteAcumulado;
  final double rendimentoDoMes;
}

class Investimento {
  /// Normaliza as entradas para meses e taxa percentual mensal equivalente.
  factory Investimento.porUnidades({
    required String nome,
    required double capitalInicial,
    required double aporteMensal,
    required double taxaJuros,
    required int periodo,
    UnidadePeriodo unidadePeriodo = UnidadePeriodo.meses,
    UnidadeTaxa unidadeTaxa = UnidadeTaxa.mensal,
  }) {
    if (!taxaJuros.isFinite || taxaJuros < 0) {
      throw ArgumentError('Informe uma taxa finita e não negativa.');
    }
    return Investimento(
      nome: nome,
      capitalInicial: capitalInicial,
      aporteMensal: aporteMensal,
      taxaJurosMensal: unidadeTaxa == UnidadeTaxa.anual
          ? (matematica.pow(1 + taxaJuros / 100, 1 / 12) - 1) * 100
          : taxaJuros,
      periodoMeses: unidadePeriodo == UnidadePeriodo.anos
          ? periodo * 12
          : periodo,
    );
  }

  Investimento({
    required this.nome,
    required this.capitalInicial,
    required this.aporteMensal,
    required this.taxaJurosMensal,
    required this.periodoMeses,
  }) {
    if (!capitalInicial.isFinite ||
        !aporteMensal.isFinite ||
        !taxaJurosMensal.isFinite ||
        capitalInicial < 0 ||
        aporteMensal < 0 ||
        taxaJurosMensal < 0 ||
        periodoMeses < 1 ||
        periodoMeses > 1200) {
      throw ArgumentError(
        'Informe valores finitos, não negativos e prazo de 1 a 1200 meses.',
      );
    }
  }
  final String nome;
  final double capitalInicial;
  final double aporteMensal;

  /// Taxa percentual: 1 representa 1% ao mês.
  final double taxaJurosMensal;
  final int periodoMeses;
  late final List<EvolucaoMensal> _evolucao = _calcular();

  List<EvolucaoMensal> _calcular() {
    var saldo = capitalInicial;
    final evolucao = <EvolucaoMensal>[];
    for (var mes = 1; mes <= periodoMeses; mes++) {
      // O saldo anterior rende juros; o aporte entra no fim do mês.
      final juros = saldo * (taxaJurosMensal / 100);
      saldo = saldo + juros + aporteMensal;
      if (!saldo.isFinite) {
        throw ArgumentError(
          'Limite de cálculo excedido. Reduza os valores, a taxa ou o prazo.',
        );
      }
      evolucao.add(
        EvolucaoMensal(
          mes: mes,
          montanteAcumulado: saldo,
          rendimentoDoMes: juros,
        ),
      );
    }
    if (!(capitalInicial + aporteMensal * periodoMeses).isFinite) {
      throw ArgumentError('O total aplicado excede o limite numérico.');
    }
    return List.unmodifiable(evolucao);
  }

  List<EvolucaoMensal> calcularEvolucaoMensal() => _evolucao;
  double get montanteFinal => _evolucao.last.montanteAcumulado;
  double get rendimentoTotal =>
      montanteFinal - capitalInicial - aporteMensal * periodoMeses;
}

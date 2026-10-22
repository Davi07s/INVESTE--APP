# Simulador de Investimentos

Aplicativo acadêmico Flutter para comparar dois investimentos com juros compostos. Utiliza Material 3, estado nativo (`StatefulWidget` e `setState`) e navegação com `Navigator.push` e `Navigator.pop`.

## Funcionalidades

- Capital inicial, aplicação mensal e taxa mensal independentes para dois investimentos, com prazo compartilhado.
- Interface adaptável: cartões lado a lado em telas largas e empilhados nas menores.
- Azul identifica o Investimento A; verde identifica o Investimento B.
- Montante final, rendimento total e total aplicado em cada investimento.
- Lista comparativa dos saldos e juros mês a mês, construída com `ListView.builder`.
- Botão “Nova Simulação” retorna ao formulário preservando os valores.

## Cálculo

A taxa é percentual: `1` significa 1% ao mês. O aporte ocorre no fim de cada mês e rende a partir do mês seguinte:

```text
juros = saldo anterior × (taxa mensal / 100)
saldo atual = saldo anterior + juros + aporte mensal
rendimento total = saldo final − capital inicial − (aporte mensal × meses)
```

Exemplo: R$ 1.000 iniciais, R$ 100 mensais e 1% ao mês durante 2 meses resultam em R$ 1.221,10, com R$ 21,10 de rendimento. A projeção considera taxa fixa, sem impostos, tarifas ou inflação. O cálculo mantém a precisão de `double`; os valores são exibidos com duas casas decimais. A partir de R$ 1 quadrilhão, a exibição usa notação científica.

## Validações

Todos os campos são obrigatórios e devem conter números finitos e não negativos. Os decimais aceitam vírgula ou ponto, sem separadores de milhares. Capital, aporte e taxa podem ser zero. O prazo deve ser inteiro, de 1 a 1200 meses; esse limite evita projeções excessivas. O modelo também valida suas entradas e rejeita resultados que excedam a capacidade numérica. Nesse caso, uma mensagem aparece no formulário, sem abrir os resultados.

## Estrutura

```text
lib/
├── main.dart
├── modelos/
│   └── modelo_investimento.dart
└── telas/
    ├── tela_inicial.dart
    └── tela_resultados.dart
```

O modelo concentra a lógica e guarda a evolução calculada para evitar cálculos repetidos. O formulário possui um método reutilizável de criação e validação dos campos. Os controladores são liberados em `dispose`.

## Executar

Instale o Flutter compatível com Dart ^3.13.4 e configure Android ou Windows. Na pasta do projeto:

```sh
flutter pub get
flutter devices
flutter run
```

Para Windows, com as ferramentas de desenvolvimento desktop instaladas, use `flutter run -d windows`. Para Android, conecte um dispositivo com depuração USB ou abra um emulador e selecione seu identificador com `flutter run -d IDENTIFICADOR`.

## Verificar

```sh
dart format lib test
flutter analyze
flutter test
```

Os testes cobrem juros compostos, momento dos aportes, taxa zero, entradas inválidas, estouro numérico, validação do formulário, navegação e preservação dos dados.

# Simulador de Investimentos: Comparação de Rendimentos | Invest +

Um aplicativo desenvolvido em **Flutter** para simular e comparar o rendimento de investimentos baseados em juros compostos. O projeto foi construído com foco em uma interface limpa, minimalista e utilizando as diretrizes do **Material Design 3**.

## 🚀 Funcionalidades

- **Simulação Individual ou Comparativa:** Calcule a evolução de um único investimento ou adicione um segundo (Investimento B) para comparar lado a lado.
- **Flexibilidade de Entradas:**
  - Insira o período de investimento em **Meses** ou **Anos**.
  - Informe a taxa de juros **Ao Mês (a.m.)** ou **Ao Ano (a.a.)** (o sistema converte automaticamente utilizando a fórmula de taxas equivalentes).
- **Formatação de Moeda:** Os campos de entrada de valores monetários (Capital Inicial e Aportes) são formatados automaticamente para o padrão brasileiro (R$ 1.000,00) enquanto o usuário digita.
- **Validação Rigorosa:** Tratamento de erros nos formulários para garantir que nenhum campo obrigatório fique vazio ou receba valores inválidos/negativos.
- **Resultados Detalhados:**
  - Cards de resumo contendo o **Montante Final** e o **Rendimento Total**.
  - Lista detalhada com a **Evolução Mês a Mês** (aportes + rendimentos).

## 📱 Interface e UX

- Construído inteiramente com **Material 3**.
- Design minimalista com bordas arredondadas e cores neutras.
- Cores de destaque para facilitar a visualização (ex: Azul para Investimento A, Verde para Investimento B).
- Layout dinâmico: a tela de resultados se adapta perfeitamente caso o usuário opte por simular apenas um investimento.

## 🛠 Tecnologias Utilizadas

- **Flutter / Dart**
- Gerenciamento de Estado nativo (`StatefulWidget`, `setState`)
- Componentes nativos (sem dependências externas pesadas) para garantir um código leve e performático.

## 📂 Estrutura do Projeto

A arquitetura do projeto segue um padrão minimalista e de fácil compreensão, ideal para fins acadêmicos:

```text
lib/
├── main.dart                      # Configuração do tema e ponto de entrada do app.
├── modelos/
│   └── modelo_investimento.dart   # Classe de modelo, conversão de taxas e cálculo de juros compostos.
└── telas/
    ├── tela_inicial.dart          # Tela com o formulário de entrada, máscaras e validações.
    └── tela_resultados.dart       # Tela adaptativa com cards de resumo e lista de evolução mensal.
```

## ⚙️ Como Executar o Projeto

1. Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado na sua máquina.
2. Clone este repositório:

   ```bash
   git clone https://github.com/Davi07s/INVESTE--APP.git
   ```

3. Acesse a pasta do projeto:

   ```bash
   cd INVESTE--APP
   ```

4. Baixe as dependências:

   ```bash
   flutter pub get
   ```

5. Execute o aplicativo em um emulador Android, dispositivo Android físico ou Windows:

   ```bash
   flutter run
   ```

## 📝 Licença

Este projeto foi desenvolvido para fins educacionais. Sinta-se à vontade para clonar, modificar e utilizar como base para seus estudos!

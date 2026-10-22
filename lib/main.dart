import 'package:flutter/material.dart';

import 'telas/tela_inicial.dart';

void main() => runApp(const AplicativoInvestimentos());

class AplicativoInvestimentos extends StatelessWidget {
  const AplicativoInvestimentos({super.key});
  @override
  Widget build(BuildContext context) {
    final borda = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return MaterialApp(
      title: 'Simulador de Investimentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardTheme: CardThemeData(elevation: 0, shape: borda),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: borda,
            padding: const EdgeInsets.all(20),
          ),
        ),
      ),
      home: const TelaInicial(),
    );
  }
}

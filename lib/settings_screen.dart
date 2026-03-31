import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalização'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cores',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ColorBox(
                  color: const Color(0xFF2D1060),
                  isSelected: themeProvider.primaryColor == const Color(0xFF2D1060),
                  onTap: () => themeProvider.changeColor(const Color(0xFF2D1060)),
                ),
                _ColorBox(
                  color: Colors.red,
                  isSelected: themeProvider.primaryColor == Colors.red,
                  onTap: () => themeProvider.changeColor(Colors.red),
                ),
                _ColorBox(
                  color: Colors.green,
                  isSelected: themeProvider.primaryColor == Colors.green,
                  onTap: () => themeProvider.changeColor(Colors.green),
                ),
                _ColorBox(
                  color: Colors.orange,
                  isSelected: themeProvider.primaryColor == Colors.orange,
                  onTap: () => themeProvider.changeColor(Colors.orange),
                ),
                _ColorBox(
                  color: Colors.purple,
                  isSelected: themeProvider.primaryColor == Colors.purple,
                  onTap: () => themeProvider.changeColor(Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Modo Escuro',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Ativar modo escuro'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorBox({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                )
              : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../signals/theme_signal.dart';

/// Seletor de tema em formato de botão com menu popup (ideal para AppBars)
class ThemeSelectorButton extends StatelessWidget {
  final bool showTooltip;

  const ThemeSelectorButton({
    super.key,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final currentMode = themeSignal.themeMode.value;

        IconData icon;
        String tooltip;
        switch (currentMode) {
          case ThemeMode.light:
            icon = Icons.light_mode_rounded;
            tooltip = 'Tema: Claro';
            break;
          case ThemeMode.dark:
            icon = Icons.dark_mode_rounded;
            tooltip = 'Tema: Escuro';
            break;
          case ThemeMode.system:
            icon = Icons.brightness_auto_rounded;
            tooltip = 'Tema: Sistema';
            break;
        }

        return PopupMenuButton<ThemeMode>(
          tooltip: showTooltip ? tooltip : null,
          icon: Icon(icon),
          initialValue: currentMode,
          onSelected: (mode) => themeSignal.setThemeMode(mode),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ThemeMode.system,
              child: Row(
                children: [
                  const Icon(Icons.brightness_auto_rounded, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Padrão do Sistema')),
                  if (currentMode == ThemeMode.system)
                    Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: Row(
                children: [
                  const Icon(Icons.light_mode_rounded, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Modo Claro')),
                  if (currentMode == ThemeMode.light)
                    Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  const Icon(Icons.dark_mode_rounded, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Modo Escuro')),
                  if (currentMode == ThemeMode.dark)
                    Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Seletor de tema em formato de SegmentedButton (ideal para cabeçalhos ou configurações)
class ThemeSegmentedSwitch extends StatelessWidget {
  const ThemeSegmentedSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final currentMode = themeSignal.themeMode.value;

        return SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto_rounded, size: 18),
              label: Text('Sistema'),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_rounded, size: 18),
              label: Text('Claro'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_rounded, size: 18),
              label: Text('Escuro'),
            ),
          ],
          selected: {currentMode},
          onSelectionChanged: (selected) {
            if (selected.isNotEmpty) {
              themeSignal.setThemeMode(selected.first);
            }
          },
        );
      },
    );
  }
}

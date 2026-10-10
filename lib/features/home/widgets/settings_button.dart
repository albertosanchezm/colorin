import 'package:flutter/material.dart';

import 'outlined_text.dart';

const _settingsBlue = Color(0xFF1C5FB8);

/// White gear shown in the top-right corner of the kid-facing screens.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, required this.size});

  final double size;

  void _open(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajustes', style: roundedTextStyle(fontSize: 26, color: _settingsBlue)),
        content: Text(
          'Muy pronto podrás cambiar los ajustes aquí.',
          style: roundedTextStyle(fontSize: 18, color: const Color(0xFF374151), weight: 500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Vale', style: roundedTextStyle(fontSize: 18, color: _settingsBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ajustes',
      child: GestureDetector(
        onTap: () => _open(context),
        child: Icon(
          Icons.settings_rounded,
          size: size,
          color: Colors.white,
          shadows: const [
            Shadow(color: Color(0x881C5FB8), blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
      ),
    );
  }
}

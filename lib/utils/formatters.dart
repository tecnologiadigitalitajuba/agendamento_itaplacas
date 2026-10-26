import 'package:flutter/services.dart';

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final apenasNumeros = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (apenasNumeros.length > 11) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < apenasNumeros.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (apenasNumeros.length == 11 && i == 7) {
        buffer.write('-');
      } else if (apenasNumeros.length < 11 && i == 6) {
        buffer.write('-');
      }
      buffer.write(apenasNumeros[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String texto = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (texto.length > 7) {
      texto = texto.substring(0, 7);
    }

    String formattedText = texto;
    if (texto.length > 3) {
      formattedText = '${texto.substring(0, 3)}-${texto.substring(3)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

bool isTelefoneValido(String telefone) {
  final apenasNumeros = telefone.replaceAll(RegExp(r'\D'), '');
  return apenasNumeros.length == 10 || apenasNumeros.length == 11;
}

bool isPlacaValida(String placa) {
  final apenasAlfanumericos = placa.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return apenasAlfanumericos.length == 7;
}

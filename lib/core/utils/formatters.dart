import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AppFormatters {
  static MaskTextInputFormatter phoneFormatter() {
    return MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  static MaskTextInputFormatter cpfFormatter() {
    return MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  static MaskTextInputFormatter cepFormatter() {
    return MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  static MaskTextInputFormatter dateFormatter() {
    return MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  static bool isValidDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return false;
    final parts = dateStr.trim().split('/');
    if (parts.length != 3) return false;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    if (year < 1900 || year > DateTime.now().year) return false;

    try {
      final parsed = DateTime(year, month, day);
      if (parsed.isAfter(DateTime.now())) return false;
      return parsed.day == day && parsed.month == month && parsed.year == year;
    } catch (_) {
      return false;
    }
  }

  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final regex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return regex.hasMatch(email.trim());
  }

  static bool isValidPhone(String? phone) {
    if (phone == null) return false;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 11;
  }

  /// Remove acentos e converte para minúsculas para comparação textual
  static String normalizeString(String text) {
    var withAccents = 'áàãâäéèêëíìîïóòõôöúùûüçñÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑ';
    var withoutAccents = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
    var result = text.trim().toLowerCase();
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i].toLowerCase(), withoutAccents[i].toLowerCase());
    }
    return result;
  }
}

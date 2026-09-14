import 'app_roles.dart';

class CadastroConstants {
  static const List<String> estadosBrasil = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  static const List<String> escolaridades = [
    'Ensino Fundamental',
    'Ensino Médio',
    'Ensino Superior Incompleto',
    'Ensino Superior Completo',
    'Pós-Graduação / Especialização',
    'Mestrado',
    'Doutorado',
  ];

  // Etapas da Fraternidade para Vida Externa
  static const List<String> etapasVidaExterna = [
    'Vocacional 1º',
    'Vocacional 2º',
    'Servo 1º',
    'Servo 2º',
    'Servo 3º',
    'Discípulo 1º',
    'Discípulo 2º',
    'Discípulo 3º',
    'Discípulo 4º',
    'Discípulo 5º',
  ];

  // Alias para manter compatibilidade com usos existentes
  static const List<String> etapasFraternidade = etapasVidaExterna;

  // Etapas da Fraternidade para Vida Interna
  static const List<String> etapasVidaInterna = [
    'Aspirantado',
    'Postulantado I',
    'Postulantado II',
    'Noviciado I',
    'Noviciado II',
    'Consagrado',
    'Formador',
  ];

  /// Retorna as etapas correspondentes de acordo com o Tipo de Vida
  static List<String> etapasPorTipoVida(TipoVida? tipoVida) {
    if (tipoVida == TipoVida.interna) {
      return etapasVidaInterna;
    }
    return etapasVidaExterna;
  }
}


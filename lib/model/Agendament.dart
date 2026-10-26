class Agendament {
  late String id;
  late String nome;
  late String placa;
  late String telefone;
  late DateTime data;
  String horario = '08:30'; // ex: '08:30', '09:00', '14:30'
  String status = 'Confirmado'; // Padrão: 'Confirmado'
  String servico = 'Troca de Placa'; // 'Troca de Placa', 'Instalação de Placa'
  String observacao = '';

  void salvar() {
    print('Nome: $nome');
  }

  @override
  String toString() {
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    return '$nome ($placa) - $dataFormatada às $horario';
  }
}

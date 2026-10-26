class Agendament {
  late String id;
  late String nome;
  late String placa;
  late String telefone;
  late DateTime data;
  String status = 'Pendente'; // 'Pendente', 'Confirmado', 'Concluído', 'Cancelado'
  String servico = 'Troca de Placa'; // 'Troca de Placa', 'Instalação de Placa'
  String observacao = '';

  void salvar() {
    print('Nome: $nome');
  }

  @override
  String toString() {
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    return '$nome ($placa) - $dataFormatada';
  }
}

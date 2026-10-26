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
  String userId = ''; // ID único do usuário/dispositivo

  Agendament();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'placa': placa,
      'telefone': telefone,
      'data': data.toIso8601String(),
      'horario': horario,
      'status': status,
      'servico': servico,
      'observacao': observacao,
      'userId': userId,
    };
  }

  factory Agendament.fromMap(Map<String, dynamic> map, String docId) {
    final item = Agendament();
    item.id = docId.isNotEmpty ? docId : (map['id'] ?? '');
    item.nome = map['nome'] ?? '';
    item.placa = map['placa'] ?? '';
    item.telefone = map['telefone'] ?? '';
    item.data = map['data'] != null ? DateTime.tryParse(map['data']) ?? DateTime.now() : DateTime.now();
    item.horario = map['horario'] ?? '08:30';
    item.status = map['status'] ?? 'Confirmado';
    item.servico = map['servico'] ?? 'Troca de Placa';
    item.observacao = map['observacao'] ?? '';
    item.userId = map['userId'] ?? '';
    return item;
  }

  void salvar() {}

  @override
  String toString() {
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    return '$nome ($placa) - $dataFormatada às $horario';
  }
}

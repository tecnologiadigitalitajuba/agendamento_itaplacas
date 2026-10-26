import 'package:flutter/foundation.dart';
import '../model/Agendament.dart';

class AgendamentoStore extends ValueNotifier<List<Agendament>> {
  static final AgendamentoStore _instance = AgendamentoStore._internal();
  factory AgendamentoStore() => _instance;

  AgendamentoStore._internal() : super([]) {
    // Adiciona dados de demonstração iniciais
    _carregarExemplosInicial();
  }

  void _carregarExemplosInicial() {
    final hoje = DateTime.now();
    final exemplo1 = Agendament()
      ..id = 'ABC1D23-35999998888'
      ..nome = 'Carlos Silva'
      ..placa = 'ABC1D23'
      ..telefone = '35999998888'
      ..data = hoje
      ..servico = 'Troca de Placa'
      ..status = 'Pendente';

    final exemplo2 = Agendament()
      ..id = 'ZERO KM-35988887777'
      ..nome = 'Mariana Oliveira'
      ..placa = 'ZERO KM'
      ..telefone = '35988887777'
      ..data = hoje.add(const Duration(days: 1))
      ..servico = 'Instalação de Placa'
      ..status = 'Confirmado';

    value = [exemplo1, exemplo2];
  }

  void salvarOuAtualizar(Agendament agendamento) {
    final lista = List<Agendament>.from(value);

    // Procura se já existe por placa ou telefone
    final indexExistente = lista.indexWhere((item) {
      final mesmaPlaca = item.placa != 'ZERO KM' &&
          agendamento.placa != 'ZERO KM' &&
          item.placa.toUpperCase() == agendamento.placa.toUpperCase();
      final mesmoTelefone = item.telefone == agendamento.telefone;
      return (mesmaPlaca || mesmoTelefone) || item.id == agendamento.id;
    });

    if (indexExistente != -1) {
      lista[indexExistente] = agendamento;
    } else {
      lista.insert(0, agendamento);
    }

    value = lista;
  }

  void alterarStatus(String id, String novoStatus) {
    final lista = List<Agendament>.from(value);
    final idx = lista.indexWhere((i) => i.id == id);
    if (idx != -1) {
      lista[idx].status = novoStatus;
      value = lista;
    }
  }

  void remover(String id) {
    final lista = List<Agendament>.from(value);
    lista.removeWhere((i) => i.id == id);
    value = lista;
  }
}

import 'package:flutter/foundation.dart';
import '../model/Agendament.dart';

class AgendamentoStore extends ValueNotifier<List<Agendament>> {
  static final AgendamentoStore _instance = AgendamentoStore._internal();
  factory AgendamentoStore() => _instance;

  // Dias completamente bloqueados pelo Admin (Formato: 'YYYY-MM-DD')
  final ValueNotifier<Set<String>> diasBloqueados = ValueNotifier({});

  // Horários específicos bloqueados pelo Admin (Formato: 'YYYY-MM-DD_HH:mm')
  final ValueNotifier<Set<String>> horariosBloqueados = ValueNotifier({});

  AgendamentoStore._internal() : super([]) {
    _carregarExemplosInicial();
  }

  // Horários de funcionamento: Segunda a Sexta, 8:30 às 17:30 de 30 em 30 min (intervalo de almoço das 12:00 às 13:00)
  static const List<String> todosHorarios = [
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
  ];

  static String formatarChaveData(DateTime data) {
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }

  static String formatarChaveHorario(DateTime data, String horario) {
    return '${formatarChaveData(data)}_$horario';
  }

  bool isDiaUtil(DateTime data) {
    return data.weekday >= DateTime.monday && data.weekday <= DateTime.friday;
  }

  bool isDiaBloqueado(DateTime data) {
    if (!isDiaUtil(data)) return true; // Fim de semana desativado
    return diasBloqueados.value.contains(formatarChaveData(data));
  }

  bool isHorarioBloqueadoAdmin(DateTime data, String horario) {
    return horariosBloqueados.value.contains(formatarChaveHorario(data, horario));
  }

  bool isHorarioOcupadoCliente(DateTime data, String horario) {
    final chaveData = formatarChaveData(data);
    return value.any((item) =>
        formatarChaveData(item.data) == chaveData &&
        item.horario == horario &&
        item.status != 'Cancelado');
  }

  bool isHorarioDisponivel(DateTime data, String horario) {
    if (isDiaBloqueado(data)) return false;
    if (isHorarioBloqueadoAdmin(data, horario)) return false;
    if (isHorarioOcupadoCliente(data, horario)) return false;
    return true;
  }

  List<String> getHorariosDisponiveis(DateTime data) {
    if (isDiaBloqueado(data)) return [];
    return todosHorarios.where((h) => isHorarioDisponivel(data, h)).toList();
  }

  void toggleBloqueioDia(DateTime data) {
    final setDias = Set<String>.from(diasBloqueados.value);
    final chave = formatarChaveData(data);
    if (setDias.contains(chave)) {
      setDias.remove(chave);
    } else {
      setDias.add(chave);
    }
    diasBloqueados.value = setDias;
  }

  void toggleBloqueioHorario(DateTime data, String horario) {
    final setHorarios = Set<String>.from(horariosBloqueados.value);
    final chave = formatarChaveHorario(data, horario);
    if (setHorarios.contains(chave)) {
      setHorarios.remove(chave);
    } else {
      setHorarios.add(chave);
    }
    horariosBloqueados.value = setHorarios;
  }

  void _carregarExemplosInicial() {
    final hoje = DateTime.now();
    DateTime dataUtil = hoje;
    while (!isDiaUtil(dataUtil)) {
      dataUtil = dataUtil.add(const Duration(days: 1));
    }

    final exemplo1 = Agendament()
      ..id = 'ABC-1D23-(35) 99999-8888'
      ..nome = 'Carlos Silva'
      ..placa = 'ABC-1D23'
      ..telefone = '(35) 99999-8888'
      ..data = dataUtil
      ..horario = '09:00'
      ..servico = 'Troca de Placa'
      ..status = 'Confirmado';

    final exemplo2 = Agendament()
      ..id = 'ZERO KM-(35) 98888-7777'
      ..nome = 'Mariana Oliveira'
      ..placa = 'ZERO KM'
      ..telefone = '(35) 98888-7777'
      ..data = dataUtil
      ..horario = '14:30'
      ..servico = 'Instalação de Placa'
      ..status = 'Confirmado';

    value = [exemplo1, exemplo2];
  }

  void salvarOuAtualizar(Agendament agendamento) {
    final lista = List<Agendament>.from(value);

    final indexExistente = lista.indexWhere((item) {
      return item.id == agendamento.id;
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

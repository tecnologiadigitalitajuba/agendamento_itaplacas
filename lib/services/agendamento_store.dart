import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../model/Agendament.dart';

class AgendamentoStore extends ValueNotifier<List<Agendament>> {
  static final AgendamentoStore _instance = AgendamentoStore._internal();
  factory AgendamentoStore() => _instance;

  // Dias completamente bloqueados pelo Admin (Formato: 'YYYY-MM-DD')
  final ValueNotifier<Set<String>> diasBloqueados = ValueNotifier({});

  // Horários específicos bloqueados pelo Admin (Formato: 'YYYY-MM-DD_HH:mm')
  final ValueNotifier<Set<String>> horariosBloqueados = ValueNotifier({});

  bool _isFirebaseInicializado = false;

  AgendamentoStore._internal() : super([]) {
    _conectarFirestore();
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

  Future<void> _conectarFirestore() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseInicializado = true;
      } else {
        await Firebase.initializeApp();
        _isFirebaseInicializado = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore executando em modo local/fallback: $e');
      }
    }

    if (_isFirebaseInicializado) {
      // Escuta coleção de agendamentos em tempo real
      FirebaseFirestore.instance.collection('agendamentos').snapshots().listen((snapshot) {
        final lista = snapshot.docs.map((doc) => Agendament.fromMap(doc.data(), doc.id)).toList();
        value = lista;
      });

      // Escuta dias bloqueados em tempo real
      FirebaseFirestore.instance.collection('dias_bloqueados').snapshots().listen((snapshot) {
        final setDias = snapshot.docs.map((doc) => doc.id).toSet();
        diasBloqueados.value = setDias;
      });

      // Escuta horários bloqueados em tempo real
      FirebaseFirestore.instance.collection('horarios_bloqueados').snapshots().listen((snapshot) {
        final setHorarios = snapshot.docs.map((doc) => doc.id).toSet();
        horariosBloqueados.value = setHorarios;
      });
    } else {
      _carregarExemplosInicial();
    }
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

  Future<void> toggleBloqueioDia(DateTime data) async {
    final chave = formatarChaveData(data);
    final setDias = Set<String>.from(diasBloqueados.value);

    if (setDias.contains(chave)) {
      setDias.remove(chave);
      if (_isFirebaseInicializado) {
        await FirebaseFirestore.instance.collection('dias_bloqueados').doc(chave).delete();
      }
    } else {
      setDias.add(chave);
      if (_isFirebaseInicializado) {
        await FirebaseFirestore.instance.collection('dias_bloqueados').doc(chave).set({'bloqueado': true});
      }
    }
    diasBloqueados.value = setDias;
  }

  Future<void> toggleBloqueioHorario(DateTime data, String horario) async {
    final chave = formatarChaveHorario(data, horario);
    final setHorarios = Set<String>.from(horariosBloqueados.value);

    if (setHorarios.contains(chave)) {
      setHorarios.remove(chave);
      if (_isFirebaseInicializado) {
        await FirebaseFirestore.instance.collection('horarios_bloqueados').doc(chave).delete();
      }
    } else {
      setHorarios.add(chave);
      if (_isFirebaseInicializado) {
        await FirebaseFirestore.instance.collection('horarios_bloqueados').doc(chave).set({'bloqueado': true});
      }
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

  Future<void> salvarOuAtualizar(Agendament agendamento) async {
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

    if (_isFirebaseInicializado) {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(agendamento.id)
          .set(agendamento.toMap());
    }
  }

  Future<void> alterarStatus(String id, String novoStatus) async {
    final lista = List<Agendament>.from(value);
    final idx = lista.indexWhere((i) => i.id == id);
    if (idx != -1) {
      lista[idx].status = novoStatus;
      value = lista;
    }

    if (_isFirebaseInicializado) {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(id)
          .update({'status': novoStatus});
    }
  }

  Future<void> remover(String id) async {
    final lista = List<Agendament>.from(value);
    lista.removeWhere((i) => i.id == id);
    value = lista;

    if (_isFirebaseInicializado) {
      await FirebaseFirestore.instance.collection('agendamentos').doc(id).delete();
    }
  }
}

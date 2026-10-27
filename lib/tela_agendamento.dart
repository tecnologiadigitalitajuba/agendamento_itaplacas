import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Agendament.dart';
import 'services/agendamento_store.dart';
import 'utils/formatters.dart';

class TelaAgendamento extends StatefulWidget {
  const TelaAgendamento({super.key});

  @override
  State<TelaAgendamento> createState() => _TelaAgendamentoState();
}

class _TelaAgendamentoState extends State<TelaAgendamento> {
  bool veiculoZeroKm = false;
  DateTime dataSelecionada = DateTime.now();
  String? horarioSelecionado;
  String servicoSelecionado = 'Troca de Placa';

  final store = AgendamentoStore();
  final nomeController = TextEditingController();
  final placaController = TextEditingController();
  final telefoneController = TextEditingController();
  String _userId = '';
  Agendament? _agendamentoEmEdicao;

  @override
  void initState() {
    super.initState();
    while (!store.isDiaUtil(dataSelecionada)) {
      dataSelecionada = dataSelecionada.add(const Duration(days: 1));
    }
    _inicializarUsuarioId();
    telefoneController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _inicializarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('user_unique_id');
    if (id == null || id.isEmpty) {
      id = 'user_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
      await prefs.setString('user_unique_id', id);
    }

    final savedPhone = prefs.getString('user_phone') ?? '';
    final savedName = prefs.getString('user_name') ?? '';

    setState(() {
      _userId = id!;
      if (savedPhone.isNotEmpty && telefoneController.text.isEmpty) {
        telefoneController.text = savedPhone;
      }
      if (savedName.isNotEmpty && nomeController.text.isEmpty) {
        nomeController.text = savedName;
      }
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    placaController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  Widget _buildCalendarioCliente({bool isCompact = false}) {
    final hoje = DateTime.now();
    final hojeApenas = DateTime(hoje.year, hoje.month, hoje.day);
    final primeiroDiaDoMes = DateTime(dataSelecionada.year, dataSelecionada.month, 1);
    final ultimoDiaDoMes = DateTime(dataSelecionada.year, dataSelecionada.month + 1, 0);
    int espacosVazios = primeiroDiaDoMes.weekday % 7; // Domingo = 0, Segunda = 1, ...

    List<Widget> diaWidgets = [];

    // Cabeçalhos dos dias da semana (começando pelo Domingo)
    const diasSemana = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];
    for (var ds in diasSemana) {
      final isFimDeSemanaHeader = ds == 'DOM' || ds == 'SÁB';
      diaWidgets.add(
        Center(
          child: Text(
            ds,
            style: TextStyle(
              fontSize: isCompact ? 8.5 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: isCompact ? 0 : 0.5,
              color: isFimDeSemanaHeader ? Colors.grey.shade400 : Colors.blueGrey.shade600,
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < espacosVazios; i++) {
      diaWidgets.add(const SizedBox.shrink());
    }

    for (int dia = 1; dia <= ultimoDiaDoMes.day; dia++) {
      final dataAtual = DateTime(dataSelecionada.year, dataSelecionada.month, dia);
      final isHoje = dataAtual.year == hoje.year && dataAtual.month == hoje.month && dataAtual.day == hoje.day;
      final isSelecionado = dataAtual.year == dataSelecionada.year && dataAtual.month == dataSelecionada.month && dataAtual.day == dataSelecionada.day;
      final isFimDeSemana = dataAtual.weekday == DateTime.saturday || dataAtual.weekday == DateTime.sunday;
      final isBloqueado = store.isDiaBloqueado(dataAtual);
      final isPassado = dataAtual.isBefore(hojeApenas);

      final bool desabilitado = isFimDeSemana || isBloqueado || isPassado;

      Color bgColor;
      Color textColor;
      Border? border;
      List<BoxShadow>? boxShadow;

      if (isSelecionado) {
        bgColor = const Color(0xFF1565C0);
        textColor = Colors.white;
        border = Border.all(color: const Color(0xFF1565C0), width: isCompact ? 1 : 1.5);
        boxShadow = [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: isCompact ? 2 : 4,
            offset: const Offset(0, 2),
          ),
        ];
      } else if (desabilitado) {
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade400;
        border = Border.all(color: Colors.transparent);
      } else if (isHoje) {
        bgColor = const Color(0xFFEBF3FE);
        textColor = const Color(0xFF1565C0);
        border = Border.all(color: const Color(0xFF1565C0), width: isCompact ? 1 : 1.5);
      } else {
        bgColor = Colors.white;
        textColor = const Color(0xFF1E293B);
        border = Border.all(color: Colors.grey.shade200);
      }

      diaWidgets.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: desabilitado
                ? null
                : () {
                    setState(() {
                      dataSelecionada = dataAtual;
                      horarioSelecionado = null;
                    });
                  },
            borderRadius: BorderRadius.circular(isCompact ? 6 : 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(isCompact ? 6 : 10),
                border: border,
                boxShadow: boxShadow,
              ),
              padding: EdgeInsets.symmetric(
                vertical: isCompact ? 1 : 2,
                horizontal: isCompact ? 1 : 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dia',
                    style: TextStyle(
                      fontSize: isCompact ? 10 : 12,
                      fontWeight: isSelecionado || isHoje ? FontWeight.bold : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (!isCompact) const SizedBox(height: 1),
                  if (isBloqueado && !isFimDeSemana)
                    Text('Bloq', style: TextStyle(fontSize: isCompact ? 7 : 8, color: Colors.red.shade400, fontWeight: FontWeight.bold))
                  else if (!desabilitado)
                    Container(
                      width: isCompact ? 3 : 4,
                      height: isCompact ? 3 : 4,
                      decoration: BoxDecoration(
                        color: isSelecionado ? Colors.white : Colors.green.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    final nomeMes = '${meses[dataSelecionada.month - 1]} de ${dataSelecionada.year}';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 6 : 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, color: const Color(0xFF1565C0), size: isCompact ? 18 : 22),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: isCompact ? 22 : 32, minHeight: isCompact ? 22 : 32),
                    onPressed: () {
                      setState(() {
                        dataSelecionada = DateTime(dataSelecionada.year, dataSelecionada.month - 1, 1);
                        while (!store.isDiaUtil(dataSelecionada) && dataSelecionada.day < 28) {
                          dataSelecionada = dataSelecionada.add(const Duration(days: 1));
                        }
                        horarioSelecionado = null;
                      });
                    },
                  ),
                  Flexible(
                    child: Text(
                      nomeMes,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isCompact ? 11.5 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1565C0),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, color: const Color(0xFF1565C0), size: isCompact ? 18 : 22),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: isCompact ? 22 : 32, minHeight: isCompact ? 22 : 32),
                    onPressed: () {
                      setState(() {
                        dataSelecionada = DateTime(dataSelecionada.year, dataSelecionada.month + 1, 1);
                        while (!store.isDiaUtil(dataSelecionada) && dataSelecionada.day < 28) {
                          dataSelecionada = dataSelecionada.add(const Duration(days: 1));
                        }
                        horarioSelecionado = null;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 4 : 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: isCompact ? 2 : 4,
                mainAxisSpacing: isCompact ? 2 : 4,
                childAspectRatio: isCompact ? 0.98 : 1.15,
                children: diaWidgets,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formulário de Atendimento
    Widget buildFormulario() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dados do Atendimento',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D47A1),
                ),
          ),
          const SizedBox(height: 16),

          // Tipo de Serviço
          const Text(
            'Selecione o Serviço:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: ['Troca de Placa', 'Instalação de Placa'].map((serv) {
              final selected = servicoSelecionado == serv;
              return ChoiceChip(
                label: Text(serv),
                selected: selected,
                selectedColor: const Color(0xFF1565C0),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      servicoSelecionado = serv;
                    });
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Nome Completo
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome Completo *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Telefone com Máscara
          TextField(
            keyboardType: TextInputType.phone,
            controller: telefoneController,
            inputFormatters: [TelefoneInputFormatter()],
            decoration: const InputDecoration(
              labelText: 'Telefone / WhatsApp *',
              hintText: '(35) 99812-0722',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Placa do Veículo com Máscara e Formatação
          TextField(
            enabled: !veiculoZeroKm,
            controller: placaController,
            inputFormatters: [PlacaInputFormatter()],
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: veiculoZeroKm ? 'Veículo ZERO KM - sem placa' : 'Placa do Veículo *',
              hintText: 'ABC-1D23 ou ABC-1234',
              prefixIcon: const Icon(Icons.directions_car),
              border: const OutlineInputBorder(),
            ),
          ),

          CheckboxListTile(
            title: const Text('Veículo ZERO KM', style: TextStyle(fontSize: 14)),
            value: veiculoZeroKm,
            activeColor: Colors.green,
            onChanged: (bool? value) {
              setState(() {
                veiculoZeroKm = value ?? false;
                if (veiculoZeroKm) {
                  placaController.clear();
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),

          const SizedBox(height: 16),

          // Botão Confirmar Agendamento
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: () => salvarAgendamento(),
            icon: const Icon(Icons.check_circle),
            label: const Text(
              'CONFIRMAR AGENDAMENTO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }

    // Lista de Meus Agendamentos
    Widget buildMeusAgendamentos() {
      return ValueListenableBuilder<List<Agendament>>(
        valueListenable: store,
        builder: (context, lista, child) {
          final telInformado = telefoneController.text.trim().replaceAll(RegExp(r'\D'), '');

          final meusAgendamentos = lista.where((item) {
            bool matchUser = _userId.isNotEmpty && item.userId == _userId;
            bool matchEditingUser = _agendamentoEmEdicao != null && item.userId == _agendamentoEmEdicao!.userId;
            bool matchTel = telInformado.isNotEmpty && item.telefone.replaceAll(RegExp(r'\D'), '') == telInformado;
            return matchUser || matchEditingUser || matchTel;
          }).toList();

          if (meusAgendamentos.isEmpty) return const SizedBox.shrink();

          // Ordenar: Futuros primeiro, Passados abaixo. Dentro do grupo, por data e hora crescentes.
          meusAgendamentos.sort((a, b) {
            final aPassado = store.isHorarioNoPassado(a.data, a.horario);
            final bPassado = store.isHorarioNoPassado(b.data, b.horario);

            if (aPassado != bPassado) {
              return aPassado ? 1 : -1; // Futuro (-1) vem antes do passado (1)
            }

            final aDataTime = DateTime(a.data.year, a.data.month, a.data.day);
            final bDataTime = DateTime(b.data.year, b.data.month, b.data.day);
            int cmpDate = aDataTime.compareTo(bDataTime);
            if (cmpDate != 0) return cmpDate;

            return a.horario.compareTo(b.horario);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Meus Agendamentos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF172B4D),
                    ),
              ),
              const SizedBox(height: 12),
              for (var item in meusAgendamentos) _cardAgendamentoCliente(item),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Text('Agendamento de Placas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isPC = width >= 950;
            final isCompact = width < 480;
            final isMedium = width >= 480 && width < 720;

            final colsHorarios = isPC ? 3 : (isCompact ? 2 : (isMedium ? 3 : 4));
            final spacingHorarios = isCompact ? 4.0 : 8.0;

            final calendarioWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isCompact ? 'Data *' : 'Data do Agendamento * (Seg-Sex)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 12 : 14,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateUtils.dateOnly(DateTime.now()),
                          lastDate: DateUtils.dateOnly(
                            DateTime.now().add(const Duration(days: 90)),
                          ),
                          selectableDayPredicate: (DateTime day) {
                            return store.isDiaUtil(day) && !store.isDiaBloqueado(day);
                          },
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF1565C0),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                dialogTheme: const DialogThemeData(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (selectedDate != null) {
                          setState(() {
                            dataSelecionada = selectedDate;
                            horarioSelecionado = null;
                          });
                        }
                      },
                      icon: Icon(Icons.edit_calendar, size: isCompact ? 14 : 16),
                      label: Text(
                        '${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}',
                        style: TextStyle(fontSize: isCompact ? 11 : 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 4 : 8),

                // Calendário do Cliente
                _buildCalendarioCliente(isCompact: isCompact || isPC),
              ],
            );

            final horariosWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isCompact ? 'Horários *' : 'Horários Disponíveis (08:30 às 17:30) *',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 12 : 14,
                  ),
                ),
                SizedBox(height: isCompact ? 4 : 8),

                ValueListenableBuilder<List<Agendament>>(
                  valueListenable: store,
                  builder: (context, lista, child) {
                    final ehDiaBloqueado = store.isDiaBloqueado(dataSelecionada);

                    if (ehDiaBloqueado) {
                      return Container(
                        padding: EdgeInsets.all(isCompact ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red, size: isCompact ? 16 : 20),
                            SizedBox(width: isCompact ? 4 : 8),
                            Expanded(
                              child: Text(
                                'Atendimento indisponível nesta data.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCompact ? 11 : 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.count(
                      crossAxisCount: colsHorarios,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: isCompact ? 3 : spacingHorarios,
                      mainAxisSpacing: isCompact ? 3 : spacingHorarios,
                      childAspectRatio: isCompact ? 3.2 : (isMedium ? 2.3 : 2.5),
                      children: AgendamentoStore.todosHorarios.map((horario) {
                        final disponivel = store.isHorarioDisponivel(dataSelecionada, horario);
                        final selecionado = horarioSelecionado == horario;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: disponivel
                                ? () {
                                    setState(() {
                                      horarioSelecionado = selecionado ? null : horario;
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: !disponivel
                                    ? Colors.grey.shade200
                                    : selecionado
                                        ? Colors.green[700]
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: !disponivel
                                      ? Colors.grey.shade300
                                      : selecionado
                                          ? Colors.green[700]!
                                          : Colors.grey.shade300,
                                  width: selecionado ? 1.5 : 1,
                                ),
                                boxShadow: selecionado
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!disponivel) ...[
                                    Icon(
                                      Icons.lock_clock,
                                      size: isCompact ? 11 : 13,
                                      color: Colors.grey.shade500,
                                    ),
                                    SizedBox(width: isCompact ? 2 : 4),
                                  ],
                                  Text(
                                    horario,
                                    style: TextStyle(
                                      fontSize: isCompact ? 10.5 : 12,
                                      fontWeight: selecionado || disponivel ? FontWeight.bold : FontWeight.normal,
                                      color: !disponivel
                                          ? Colors.grey.shade500
                                          : selecionado
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );

            if (isPC) {
              // Tela de PC: 3 Colunas Lado a Lado
              // 1. Calendário (Esquerda)
              // 2. Horários (Centro)
              // 3. Dados e Agendamentos (Direita)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: calendarioWidget,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: horariosWidget,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: buildFormulario(),
                          ),
                        ),
                        buildMeusAgendamentos(),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Celular / Tablet: Form no topo, Calendário e Horários Lado a Lado no meio, Meus Agendamentos no rodapé
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildFormulario(),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: calendarioWidget,
                            ),
                            SizedBox(width: isCompact ? 8 : (isMedium ? 14 : 20)),
                            Expanded(
                              flex: isCompact ? 5 : 6,
                              child: horariosWidget,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                buildMeusAgendamentos(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cardAgendamentoCliente(Agendament item) {
    final isPassado = store.isHorarioNoPassado(item.data, item.horario);

    Color corStatus;
    switch (item.status) {
      case 'Confirmado':
        corStatus = Colors.green;
        break;
      case 'Concluído':
        corStatus = Colors.blue;
        break;
      case 'Cancelado':
        corStatus = Colors.red;
        break;
      default:
        corStatus = Colors.orange;
    }

    final dataFormatada =
        '${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}';

    Widget card = Card(
      elevation: isPassado ? 1 : 2,
      color: isPassado ? Colors.grey.shade100 : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPassado ? Colors.grey.shade300 : const Color(0x1A1565C0),
          child: Icon(Icons.calendar_today, color: isPassado ? Colors.grey.shade600 : const Color(0xFF1565C0)),
        ),
        title: Text(
          item.nome,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isPassado ? Colors.grey.shade700 : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Serviço: ${item.servico} | Placa: ${item.placa}',
              style: TextStyle(color: isPassado ? Colors.grey.shade600 : Colors.black87),
            ),
            Text(
              'Data: $dataFormatada às ${item.horario}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPassado ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isPassado ? Colors.grey : corStatus).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isPassado ? Colors.grey : corStatus),
          ),
          child: Text(
            item.status,
            style: TextStyle(
              color: isPassado ? Colors.grey.shade700 : corStatus,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => editarAgendamento(item),
      ),
    );

    if (isPassado) {
      return Opacity(
        opacity: 0.65,
        child: card,
      );
    }
    return card;
  }

  Future<void> salvarAgendamento() async {
    final nome = nomeController.text.trim();
    final telefone = telefoneController.text.trim();
    final placa = veiculoZeroKm ? 'ZERO KM' : placaController.text.trim().toUpperCase();

    if (nome.isEmpty || telefone.isEmpty || (!veiculoZeroKm && placa.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Por favor, preencha todos os campos obrigatórios!'),
        ),
      );
      return;
    }

    if (!isTelefoneValido(telefone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Telefone inválido! Digite o DDD + número (10 ou 11 dígitos).'),
        ),
      );
      return;
    }

    if (!veiculoZeroKm && !isPlacaValida(placa)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Placa inválida! A placa deve conter exatamente 7 caracteres.'),
        ),
      );
      return;
    }

    if (horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Por favor, selecione um horário disponível!'),
        ),
      );
      return;
    }

    if (store.isHorarioNoPassado(dataSelecionada, horarioSelecionado!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
              'Não é permitido agendar em dias ou horários do passado!'),
        ),
      );
      return;
    }

    final userIdParaSalvar = _agendamentoEmEdicao?.userId.isNotEmpty == true
        ? _agendamentoEmEdicao!.userId
        : (_userId.isNotEmpty ? _userId : 'user_${DateTime.now().millisecondsSinceEpoch}');

    final agendamento = Agendament()
      ..id = '$placa-$telefone-${AgendamentoStore.formatarChaveHorario(dataSelecionada, horarioSelecionado!)}'
      ..nome = nome
      ..placa = placa
      ..telefone = telefone
      ..servico = servicoSelecionado
      ..data = dataSelecionada
      ..horario = horarioSelecionado!
      ..status = 'Confirmado'
      ..userId = userIdParaSalvar;

    store.salvarOuAtualizar(agendamento);
    _agendamentoEmEdicao = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', telefone);
    await prefs.setString('user_name', nome);

    nomeController.clear();
    placaController.clear();
    telefoneController.text = telefone;
    setState(() {
      horarioSelecionado = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Agendamento confirmado com sucesso!'),
      ),
    );
  }

  void editarAgendamento(Agendament item) {
    setState(() {
      _agendamentoEmEdicao = item;
      nomeController.text = item.nome;
      telefoneController.text = item.telefone;
      servicoSelecionado = item.servico;
      if (item.placa == 'ZERO KM') {
        veiculoZeroKm = true;
        placaController.clear();
      } else {
        veiculoZeroKm = false;
        placaController.text = item.placa;
      }
      dataSelecionada = item.data;
      horarioSelecionado = item.horario;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados carregados no formulário para edição.'),
      ),
    );
  }
}

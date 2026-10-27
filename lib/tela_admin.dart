import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/Agendament.dart';
import 'services/agendamento_store.dart';
import 'utils/formatters.dart';

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});

  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  final store = AgendamentoStore();
  DateTime dataSelecionadaAdmin = DateTime.now();
  String filtroStatus = 'Todos';
  String busca = '';
  final buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    while (!store.isDiaUtil(dataSelecionadaAdmin)) {
      dataSelecionadaAdmin = dataSelecionadaAdmin.add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  int _getQtdAgendamentosNoDia(List<Agendament> lista, DateTime data) {
    final chave = AgendamentoStore.formatarChaveData(data);
    return lista.where((i) =>
        AgendamentoStore.formatarChaveData(i.data) == chave &&
        i.status != 'Cancelado').length;
  }

  String _formatarMesAno(DateTime data) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${meses[data.month - 1]} de ${data.year}';
  }

  Widget _buildCalendarioMensal(List<Agendament> lista) {
    final primeiroDiaDoMes = DateTime(dataSelecionadaAdmin.year, dataSelecionadaAdmin.month, 1);
    final ultimoDiaDoMes = DateTime(dataSelecionadaAdmin.year, dataSelecionadaAdmin.month + 1, 0);
    int primeiroDiaSemana = primeiroDiaDoMes.weekday; // 1 (Segunda) a 7 (Domingo)

    List<Widget> diaWidgets = [];

    // Cabeçalhos dos dias da semana
    const diasSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    for (var ds in diasSemana) {
      diaWidgets.add(
        Center(
          child: Text(
            ds,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    // Espaços vazios antes do primeiro dia do mês
    for (int i = 1; i < primeiroDiaSemana; i++) {
      diaWidgets.add(const SizedBox.shrink());
    }

    // Dias do mês
    for (int dia = 1; dia <= ultimoDiaDoMes.day; dia++) {
      final dataAtual = DateTime(dataSelecionadaAdmin.year, dataSelecionadaAdmin.month, dia);
      final isSelecionado = dataAtual.year == dataSelecionadaAdmin.year &&
          dataAtual.month == dataSelecionadaAdmin.month &&
          dataAtual.day == dataSelecionadaAdmin.day;
      final isFimDeSemana = dataAtual.weekday == DateTime.saturday || dataAtual.weekday == DateTime.sunday;
      final isBloqueado = store.isDiaBloqueado(dataAtual);
      final qtd = _getQtdAgendamentosNoDia(lista, dataAtual);

      diaWidgets.add(
        GestureDetector(
          onTap: isFimDeSemana
              ? null
              : () {
                  setState(() {
                    dataSelecionadaAdmin = dataAtual;
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              color: isSelecionado
                  ? const Color(0xFF0D47A1)
                  : (isFimDeSemana ? Colors.grey.shade100 : (isBloqueado ? Colors.red.shade50 : Colors.white)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelecionado ? const Color(0xFF0D47A1) : Colors.grey.shade300,
                width: isSelecionado ? 2 : 1,
              ),
              boxShadow: isSelecionado
                  ? [BoxShadow(color: const Color(0xFF0D47A1).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))]
                  : [],
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelecionado
                        ? Colors.white
                        : (isFimDeSemana ? Colors.grey.shade400 : (isBloqueado ? Colors.red.shade700 : Colors.black87)),
                  ),
                ),
                const SizedBox(height: 2),
                if (!isFimDeSemana) ...[
                  if (qtd > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelecionado ? Colors.white : const Color(0xFF0D47A1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$qtd',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelecionado ? const Color(0xFF0D47A1) : Colors.white,
                        ),
                      ),
                    )
                  else
                    Text(
                      isBloqueado ? 'Bloq.' : '-',
                      style: TextStyle(
                        fontSize: 9,
                        color: isBloqueado ? Colors.red.shade400 : Colors.grey.shade400,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Navegação do Mês
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF0D47A1)),
              onPressed: () {
                setState(() {
                  dataSelecionadaAdmin = DateTime(dataSelecionadaAdmin.year, dataSelecionadaAdmin.month - 1, 1);
                  while (!store.isDiaUtil(dataSelecionadaAdmin) && dataSelecionadaAdmin.day < 28) {
                    dataSelecionadaAdmin = dataSelecionadaAdmin.add(const Duration(days: 1));
                  }
                });
              },
            ),
            Text(
              _formatarMesAno(dataSelecionadaAdmin),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF0D47A1)),
              onPressed: () {
                setState(() {
                  dataSelecionadaAdmin = DateTime(dataSelecionadaAdmin.year, dataSelecionadaAdmin.month + 1, 1);
                  while (!store.isDiaUtil(dataSelecionadaAdmin) && dataSelecionadaAdmin.day < 28) {
                    dataSelecionadaAdmin = dataSelecionadaAdmin.add(const Duration(days: 1));
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Grid do Calendário
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1.15,
          children: diaWidgets,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, size: 24),
            SizedBox(width: 10),
            Text('Painel Administrativo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<Agendament>>(
        valueListenable: store,
        builder: (context, lista, child) {
          final hoje = DateTime.now();
          final totalAgendamentos = lista.length;
          final agendamentosHoje = lista.where((item) =>
              item.data.year == hoje.year &&
              item.data.month == hoje.month &&
              item.data.day == hoje.day &&
              item.status != 'Cancelado').length;
          final pendentes = lista.where((item) => item.status == 'Pendente').length;
          final confirmados = lista.where((item) => item.status == 'Confirmado').length;

          final chaveDataSelecionada = AgendamentoStore.formatarChaveData(dataSelecionadaAdmin);
          final listaFiltrada = lista.where((item) {
            final atendeData = AgendamentoStore.formatarChaveData(item.data) == chaveDataSelecionada;
            final atendeFiltroStatus = filtroStatus == 'Todos' || item.status == filtroStatus;
            final buscaLower = busca.toLowerCase();
            final atendeBusca = busca.isEmpty ||
                item.nome.toLowerCase().contains(buscaLower) ||
                item.placa.toLowerCase().contains(buscaLower) ||
                item.telefone.toLowerCase().contains(buscaLower);
            
            if (busca.isNotEmpty) {
              return atendeFiltroStatus && atendeBusca;
            }
            return atendeData && atendeFiltroStatus;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cards KPI Modernos
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 650;
                    return GridView.count(
                      crossAxisCount: isMobile ? 2 : 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isMobile ? 1.7 : 2.2,
                      children: [
                        _cardKPI('Total', '$totalAgendamentos', Icons.format_list_bulleted, Colors.blue.shade700),
                        _cardKPI('Hoje', '$agendamentosHoje', Icons.today, Colors.purple.shade700),
                        _cardKPI('Pendentes', '$pendentes', Icons.hourglass_top, Colors.orange.shade800),
                        _cardKPI('Confirmados', '$confirmados', Icons.check_circle, Colors.green.shade700),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // SEÇÃO 1: CALENDÁRIO MENSAL NORMAL COM QUANTIDADES DE AGENDAMENTOS
                Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_month, color: Color(0xFF0D47A1), size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Calendário & Contagem de Vagas',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                ),
                              ],
                            ),
                            Text(
                              'Data selecionada: ${dataSelecionadaAdmin.day.toString().padLeft(2, '0')}/${dataSelecionadaAdmin.month.toString().padLeft(2, '0')}/${dataSelecionadaAdmin.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Exibir Calendário Mensal Normal
                        _buildCalendarioMensal(lista),

                        const SizedBox(height: 20),

                        // Status do Dia Selecionado com Controle de Bloqueio
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: store.diasBloqueados,
                          builder: (context, dias, child) {
                            final ehDiaBloqueado = store.isDiaBloqueado(dataSelecionadaAdmin);
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ehDiaBloqueado ? Colors.red.shade50 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ehDiaBloqueado ? Colors.red.shade200 : Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    ehDiaBloqueado ? Icons.block : Icons.check_circle_outline,
                                    color: ehDiaBloqueado ? Colors.red : Colors.blue[800],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ehDiaBloqueado
                                          ? 'Dia Bloqueado (Nenhum agendamento permitido)'
                                          : 'Dia Aberto para Atendimentos (Segunda a Sexta)',
                                      style: TextStyle(
                                        color: ehDiaBloqueado ? Colors.red.shade900 : Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ehDiaBloqueado ? Colors.green.shade700 : Colors.red.shade700,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        store.toggleBloqueioDia(dataSelecionadaAdmin);
                                      });
                                    },
                                    child: Text(ehDiaBloqueado ? 'Desbloquear' : 'Bloquear Dia'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Grade de Horários do Dia (Itens no passado ficam opacos):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),

                        const SizedBox(height: 10),

                        // Grid de Horários do Dia Selecionado (Com opacidade se no passado)
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: store.horariosBloqueados,
                          builder: (context, horarios, child) {
                            final chaveData = AgendamentoStore.formatarChaveData(dataSelecionadaAdmin);
                            final ehDiaBloqueado = store.isDiaBloqueado(dataSelecionadaAdmin);

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AgendamentoStore.todosHorarios.map((horario) {
                                final ehBloqueadoAdmin = store.isHorarioBloqueadoAdmin(dataSelecionadaAdmin, horario);
                                final isPassadoHorario = store.isHorarioNoPassado(dataSelecionadaAdmin, horario);
                                
                                final agendamentoOcupado = lista.cast<Agendament?>().firstWhere(
                                      (i) =>
                                          i != null &&
                                          AgendamentoStore.formatarChaveData(i.data) == chaveData &&
                                          i.horario == horario &&
                                          i.status != 'Cancelado',
                                      orElse: () => null,
                                    );

                                Color corCard;
                                String textoLabel;
                                IconData icone;

                                if (ehDiaBloqueado || ehBloqueadoAdmin) {
                                  corCard = Colors.red.shade700;
                                  textoLabel = '$horario (Bloq.)';
                                  icone = Icons.lock;
                                } else if (agendamentoOcupado != null) {
                                  corCard = Colors.blue.shade800;
                                  textoLabel = '$horario (${agendamentoOcupado.nome.split(" ").first})';
                                  icone = Icons.person;
                                } else {
                                  corCard = Colors.green.shade700;
                                  textoLabel = '$horario (Livre)';
                                  icone = Icons.add_circle_outline;
                                }

                                Widget chip = ActionChip(
                                  avatar: Icon(icone, size: 15, color: Colors.white),
                                  label: Text(
                                    textoLabel,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  backgroundColor: corCard,
                                  onPressed: () {
                                    _gerenciarOpcoesHorarioAdmin(
                                      dataSelecionadaAdmin,
                                      horario,
                                      agendamentoOcupado,
                                      ehBloqueadoAdmin,
                                    );
                                  },
                                );

                                if (isPassadoHorario) {
                                  return Opacity(
                                    opacity: 0.45,
                                    child: chip,
                                  );
                                }
                                return chip;
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SEÇÃO 2: LISTA DE AGENDAMENTOS DO DIA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      busca.isNotEmpty ? 'Resultados da Busca' : 'Agendamentos do Dia',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                    ),
                    if (busca.isEmpty)
                      Text(
                        '${listaFiltrada.length} encontrado(s)',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Campo de Busca Global
                TextField(
                  controller: buscaController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar por nome, placa ou telefone...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                    suffixIcon: busca.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                buscaController.clear();
                                busca = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onChanged: (val) {
                    setState(() {
                      busca = val;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // Chips de Filtro por Status
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Confirmado', 'Pendente', 'Concluído', 'Cancelado'].map((status) {
                      final selected = filtroStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: selected,
                          selectedColor: const Color(0xFF0D47A1),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (bool val) {
                            setState(() {
                              filtroStatus = status;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de Agendamentos
                if (listaFiltrada.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          busca.isNotEmpty ? 'Nenhum agendamento encontrado para a busca.' : 'Nenhum agendamento para este dia.',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) {
                      final item = listaFiltrada[index];
                      final isPassado = store.isHorarioNoPassado(item.data, item.horario);

                      Widget card = _cardAgendamentoAdmin(item, isPassado: isPassado);

                      if (isPassado) {
                        return Opacity(
                          opacity: 0.5,
                          child: card,
                        );
                      }
                      return card;
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cardKPI(String titulo, String valor, IconData icone, Color cor) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, color: cor, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: cor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardAgendamentoAdmin(Agendament item, {bool isPassado = false}) {
    Color corBadge;
    switch (item.status) {
      case 'Confirmado':
        corBadge = Colors.green.shade700;
        break;
      case 'Concluído':
        corBadge = Colors.blue.shade700;
        break;
      case 'Cancelado':
        corBadge = Colors.red.shade700;
        break;
      default:
        corBadge = Colors.orange.shade800;
    }

    final dataFormatada =
        '${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}';

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isPassado ? BorderSide(color: Colors.grey.shade300, width: 1) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        item.nome,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      if (isPassado) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PASSADO',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: corBadge.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: corBadge),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(color: corBadge, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.build_circle_outlined, size: 16, color: Color(0xFF0D47A1)),
                const SizedBox(width: 6),
                Text(item.servico, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(item.placa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Tel: ${item.telefone}', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('$dataFormatada às ${item.horario}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),

            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => _abrirWhatsAppCliente(item),
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                ),

                Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.edit_note, color: Color(0xFF0D47A1)),
                      tooltip: 'Alterar Status',
                      onSelected: (String novoStatus) {
                        store.alterarStatus(item.id, novoStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status alterado para "$novoStatus"!'),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Confirmado', child: Text('✅ Marcar Confirmado')),
                        const PopupMenuItem(value: 'Pendente', child: Text('⏳ Marcar Pendente')),
                        const PopupMenuItem(value: 'Concluído', child: Text('🎉 Marcar Concluído')),
                        const PopupMenuItem(value: 'Cancelado', child: Text('❌ Marcar Cancelado')),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0D47A1), size: 20),
                      tooltip: 'Editar Agendamento',
                      onPressed: () => _abrirDialogEditarAgendamento(item),
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      tooltip: 'Excluir Agendamento',
                      onPressed: () => _confirmarExclusao(item),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _gerenciarOpcoesHorarioAdmin(
      DateTime data, String horario, Agendament? agendamento, bool ehBloqueado) {
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Horário: $horario em $dataFormatada',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              if (agendamento != null) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.person, color: Color(0xFF0D47A1)),
                  ),
                  title: Text(agendamento.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Placa: ${agendamento.placa} | Tel: ${agendamento.telefone}\nStatus: ${agendamento.status}'),
                  isThreeLine: true,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirWhatsAppCliente(agendamento);
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Enviar Mensagem WhatsApp'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () {
                    store.remover(agendamento.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Agendamento removido!')),
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Cancelar / Remover Agendamento'),
                ),
              ] else ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _modalAgendarParaCliente(data, horario);
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('Agendar para um Cliente'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ehBloqueado ? Colors.green.shade700 : Colors.orange.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    store.toggleBloqueioHorario(data, horario);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ehBloqueado
                            ? 'Horário $horario desbloqueado!'
                            : 'Horário $horario bloqueado para clientes!'),
                      ),
                    );
                  },
                  icon: Icon(ehBloqueado ? Icons.lock_open : Icons.lock),
                  label: Text(ehBloqueado ? 'Desbloquear este Horário' : 'Bloquear este Horário'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _modalAgendarParaCliente(DateTime data, String horario) {
    final nomeCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final placaCtrl = TextEditingController();
    bool isZeroKm = false;
    String servico = 'Troca de Placa';

    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Agendar para Cliente\n($dataFormatada às $horario)', style: const TextStyle(fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: servico,
                      decoration: const InputDecoration(labelText: 'Serviço', border: OutlineInputBorder()),
                      items: ['Troca de Placa', 'Instalação de Placa']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => servico = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(labelText: 'Nome do Cliente *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: telCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [TelefoneInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Telefone / WhatsApp *',
                        hintText: '(35) 99812-0722',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: placaCtrl,
                      enabled: !isZeroKm,
                      inputFormatters: [PlacaInputFormatter()],
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: isZeroKm ? 'Veículo ZERO KM' : 'Placa do Veículo *',
                        hintText: 'ABC-1D23 ou ABC-1234',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Veículo ZERO KM', style: TextStyle(fontSize: 14)),
                      value: isZeroKm,
                      onChanged: (val) => setModalState(() {
                        isZeroKm = val ?? false;
                        if (isZeroKm) placaCtrl.clear();
                      }),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                  onPressed: () {
                    final nome = nomeCtrl.text.trim();
                    final tel = telCtrl.text.trim();
                    final placa = isZeroKm ? 'ZERO KM' : placaCtrl.text.trim().toUpperCase();

                    if (nome.isEmpty || tel.isEmpty || (!isZeroKm && placa.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preencha os campos obrigatórios!'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    if (!isTelefoneValido(tel)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Telefone inválido! Digite DDD + número (10 ou 11 dígitos).'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    if (!isZeroKm && !isPlacaValida(placa)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Placa inválida! A placa deve possuir exatamente 7 caracteres.'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    if (store.isHorarioNoPassado(data, horario)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Não é permitido agendar em dias ou horários do passado!'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final agendamento = Agendament()
                      ..id = '$placa-$tel-${AgendamentoStore.formatarChaveHorario(data, horario)}'
                      ..nome = nome
                      ..placa = placa
                      ..telefone = tel
                      ..servico = servico
                      ..data = data
                      ..horario = horario
                      ..status = 'Confirmado';

                    store.salvarOuAtualizar(agendamento);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Agendamento confirmado com sucesso!'), backgroundColor: Colors.green),
                    );
                  },
                  child: const Text('Confirmar Agendamento', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _abrirWhatsAppCliente(Agendament item) async {
    final telApenasNumeros = item.telefone.replaceAll(RegExp(r'\D'), '');
    final dataFormatada =
        '${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}';
    final mensagem = Uri.encodeComponent(
      'Olá ${item.nome}! Aqui é da ITAPLACAS. '
      'Referente ao seu agendamento de ${item.servico} para o dia $dataFormatada às ${item.horario} (Placa: ${item.placa}).',
    );
    final Uri uri = Uri.parse('https://wa.me/55$telApenasNumeros?text=$mensagem');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  void _confirmarExclusao(Agendament item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o agendamento de "${item.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              store.remover(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agendamento removido!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirDialogEditarAgendamento(Agendament item) {
    final nomeController = TextEditingController(text: item.nome);
    final telefoneController = TextEditingController(text: item.telefone);
    final placaController = TextEditingController(text: item.placa == 'ZERO KM' ? '' : item.placa);
    bool zeroKm = item.placa == 'ZERO KM';
    String servicoAtual = item.servico;
    String statusAtual = item.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFF0D47A1)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Editar: ${item.nome}', style: const TextStyle(fontSize: 18))),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Cliente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: placaController,
                            enabled: !zeroKm,
                            decoration: InputDecoration(
                              labelText: 'Placa',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.directions_car),
                              filled: zeroKm,
                              fillColor: zeroKm ? Colors.grey.shade200 : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            const Text('Zero KM', style: TextStyle(fontSize: 12)),
                            Checkbox(
                              value: zeroKm,
                              onChanged: (val) {
                                setStateDialog(() {
                                  zeroKm = val ?? false;
                                  if (zeroKm) placaController.text = 'ZERO KM';
                                  else placaController.text = '';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: ['Troca de Placa', 'Instalação de Placa'].contains(servicoAtual) ? servicoAtual : 'Troca de Placa',
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.build_circle),
                      ),
                      items: ['Troca de Placa', 'Instalação de Placa']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setStateDialog(() => servicoAtual = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: ['Confirmado', 'Pendente', 'Concluído', 'Cancelado'].contains(statusAtual) ? statusAtual : 'Confirmado',
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: ['Confirmado', 'Pendente', 'Concluído', 'Cancelado']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setStateDialog(() => statusAtual = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                  onPressed: () {
                    final nome = nomeController.text.trim();
                    final tel = telefoneController.text.trim();
                    final placa = zeroKm ? 'ZERO KM' : placaController.text.trim().toUpperCase();

                    if (nome.isEmpty || tel.isEmpty || placa.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Preencha todos os campos obrigatórios!'),
                        ),
                      );
                      return;
                    }

                    item.nome = nome;
                    item.telefone = tel;
                    item.placa = placa;
                    item.servico = servicoAtual;
                    item.status = statusAtual;

                    store.salvarOuAtualizar(item);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Agendamento atualizado com sucesso!'),
                      ),
                    );
                  },
                  child: const Text('Salvar Alterações', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

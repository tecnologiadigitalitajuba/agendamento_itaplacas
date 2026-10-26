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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings),
            SizedBox(width: 8),
            Text('Painel Administrativo', style: TextStyle(fontWeight: FontWeight.bold)),
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

          final listaFiltrada = lista.where((item) {
            final atendeFiltroStatus = filtroStatus == 'Todos' || item.status == filtroStatus;
            final buscaLower = busca.toLowerCase();
            final atendeBusca = busca.isEmpty ||
                item.nome.toLowerCase().contains(buscaLower) ||
                item.placa.toLowerCase().contains(buscaLower) ||
                item.telefone.toLowerCase().contains(buscaLower);
            return atendeFiltroStatus && atendeBusca;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cards KPI
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return GridView.count(
                      crossAxisCount: isMobile ? 2 : 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isMobile ? 1.6 : 2.0,
                      children: [
                        _cardKPI('Total', '$totalAgendamentos', Icons.format_list_bulleted, Colors.blue),
                        _cardKPI('Hoje', '$agendamentosHoje', Icons.today, Colors.purple),
                        _cardKPI('Pendentes', '$pendentes', Icons.hourglass_top, Colors.orange),
                        _cardKPI('Confirmados', '$confirmados', Icons.check_circle, Colors.green),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // SEÇÃO 1: GERENCIAMENTO DE CALENDÁRIO E HORÁRIOS
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_month, color: Color(0xFF0D47A1)),
                                SizedBox(width: 8),
                                Text(
                                  'Agenda & Bloqueios',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final DateTime? selected = await showDatePicker(
                                  context: context,
                                  initialDate: dataSelecionadaAdmin,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 180)),
                                  selectableDayPredicate: (day) => store.isDiaUtil(day),
                                );
                                if (selected != null) {
                                  setState(() {
                                    dataSelecionadaAdmin = selected;
                                  });
                                }
                              },
                              icon: const Icon(Icons.event, size: 18),
                              label: Text(
                                '${dataSelecionadaAdmin.day.toString().padLeft(2, '0')}/'
                                '${dataSelecionadaAdmin.month.toString().padLeft(2, '0')}/'
                                '${dataSelecionadaAdmin.year}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Painel do Dia Selecionado com Controle de Bloqueio do Dia
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: store.diasBloqueados,
                          builder: (context, dias, child) {
                            final ehDiaBloqueado = store.isDiaBloqueado(dataSelecionadaAdmin);
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ehDiaBloqueado ? Colors.red.shade50 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ehDiaBloqueado ? Colors.red : Colors.blue),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    ehDiaBloqueado ? Icons.block : Icons.check_circle_outline,
                                    color: ehDiaBloqueado ? Colors.red : Colors.blue[800],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      ehDiaBloqueado
                                          ? 'Status do Dia: DIA BLOQUEADO (Nenhum cliente pode agendar)'
                                          : 'Status do Dia: Aberto para Agendamentos (Segunda a Sexta)',
                                      style: TextStyle(
                                        color: ehDiaBloqueado ? Colors.red : Colors.blue[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ehDiaBloqueado ? Colors.green : Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        store.toggleBloqueioDia(dataSelecionadaAdmin);
                                      });
                                    },
                                    child: Text(ehDiaBloqueado ? 'Desbloquear Dia' : 'Bloquear Dia'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Horários do Dia (Clique para Agendar para Cliente ou Bloquear/Desbloquear):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),

                        const SizedBox(height: 10),

                        // Grid de Horários do Dia Selecionado
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
                                  corCard = Colors.red;
                                  textoLabel = '$horario (Bloqueado)';
                                  icone = Icons.lock;
                                } else if (agendamentoOcupado != null) {
                                  corCard = Colors.blue[800]!;
                                  textoLabel = '$horario (${agendamentoOcupado.nome.split(" ").first})';
                                  icone = Icons.person;
                                } else {
                                  corCard = Colors.green[700]!;
                                  textoLabel = '$horario (Livre)';
                                  icone = Icons.add_circle_outline;
                                }

                                return ActionChip(
                                  avatar: Icon(icone, size: 16, color: Colors.white),
                                  label: Text(
                                    textoLabel,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SEÇÃO 2: LISTA GERAL DE AGENDAMENTOS E BUSCA
                Text(
                  'Todos os Agendamentos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D47A1),
                      ),
                ),
                const SizedBox(height: 12),

                // Campo de Busca
                TextField(
                  controller: buscaController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nome, placa ou telefone',
                    prefixIcon: const Icon(Icons.search),
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
                    children: [
                      'Todos',
                      'Confirmado',
                      'Pendente',
                      'Concluído',
                      'Cancelado'
                    ].map((status) {
                      final selected = filtroStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: selected,
                          selectedColor: const Color(0xFF1565C0),
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
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum agendamento encontrado.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                      return _cardAgendamentoAdmin(item);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, color: cor, size: 20),
                const SizedBox(width: 6),
                Text(
                  titulo,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardAgendamentoAdmin(Agendament item) {
    Color corBadge;
    switch (item.status) {
      case 'Confirmado':
        corBadge = Colors.green;
        break;
      case 'Concluído':
        corBadge = Colors.blue;
        break;
      case 'Cancelado':
        corBadge = Colors.red;
        break;
      default:
        corBadge = Colors.orange;
    }

    final dataFormatada =
        '${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.nome,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: corBadge.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: corBadge),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(color: corBadge, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.build_circle_outlined, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text(item.servico, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(item.placa, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Tel: ${item.telefone}'),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('$dataFormatada às ${item.horario}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _abrirWhatsAppCliente(item),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('WhatsApp'),
                ),

                Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.edit_note, color: Color(0xFF1565C0)),
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
                      icon: const Icon(Icons.edit, color: Color(0xFF1565C0)),
                      tooltip: 'Editar Agendamento',
                      onPressed: () => _abrirDialogEditarAgendamento(item),
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Horário: $horario em $dataFormatada',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              if (agendamento != null) ...[
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(agendamento.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Placa: ${agendamento.placa} | Tel: ${agendamento.telefone} | Status: ${agendamento.status}'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirWhatsAppCliente(agendamento);
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Enviar Mensagem WhatsApp'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
                    backgroundColor: ehBloqueado ? Colors.green : Colors.orange[800],
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
              title: Text('Agendar para Cliente ($dataFormatada às $horario)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: servico,
                      decoration: const InputDecoration(labelText: 'Serviço'),
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
                  child: const Text('Cancelar'),
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
                        const SnackBar(content: Text(
                            'Não é permitido agendar em dias ou horários do passado!'),
                            backgroundColor: Colors.red),
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
                      ..status = 'Confirmado'; // Status sempre 'Confirmado' ao agendar

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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/Agendament.dart';
import 'services/agendamento_store.dart';

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});

  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  final store = AgendamentoStore();
  String filtroStatus = 'Todos';
  String busca = '';
  final buscaController = TextEditingController();

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
              item.data.day == hoje.day).length;
          final pendentes = lista.where((item) => item.status == 'Pendente').length;
          final confirmados = lista.where((item) => item.status == 'Confirmado').length;

          // Filtragem
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
                // Cards de Resumo KPI
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
                      'Pendente',
                      'Confirmado',
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
                    child: Column(
                      children: const [
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
            // Cabeçalho do Card
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

            // Informações do Veículo e Contato
            Row(
              children: [
                const Icon(Icons.build_circle_outlined, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text(
                  item.servico,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  item.placa,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Tel: ${item.telefone}'),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Data: $dataFormatada'),
              ],
            ),

            const Divider(height: 24),

            // Botões de Ação do Admin
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de Contato WhatsApp
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
                    // Menu para Alterar Status
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
                        const PopupMenuItem(value: 'Pendente', child: Text('⏳ Marcar Pendente')),
                        const PopupMenuItem(value: 'Confirmado', child: Text('✅ Marcar Confirmado')),
                        const PopupMenuItem(value: 'Concluído', child: Text('🎉 Marcar Concluído')),
                        const PopupMenuItem(value: 'Cancelado', child: Text('❌ Marcar Cancelado')),
                      ],
                    ),

                    // Botão Excluir
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

  void _abrirWhatsAppCliente(Agendament item) async {
    final telApenasNumeros = item.telefone.replaceAll(RegExp(r'\D'), '');
    final dataFormatada =
        '${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}';
    final mensagem = Uri.encodeComponent(
      'Olá ${item.nome}! Aqui é da ITAPLACAS. '
      'Referente ao seu agendamento de ${item.servico} para o dia $dataFormatada (Placa: ${item.placa}).',
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
}

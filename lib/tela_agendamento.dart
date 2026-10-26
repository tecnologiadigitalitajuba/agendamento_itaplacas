import 'package:flutter/material.dart';
import 'model/Agendament.dart';
import 'services/agendamento_store.dart';

class TelaAgendamento extends StatefulWidget {
  const TelaAgendamento({super.key});

  @override
  State<TelaAgendamento> createState() => _TelaAgendamentoState();
}

class _TelaAgendamentoState extends State<TelaAgendamento> {
  bool veiculoZeroKm = false;
  DateTime dataSelecionada = DateTime.now();
  String servicoSelecionado = 'Troca de Placa';

  final store = AgendamentoStore();
  final nomeController = TextEditingController();
  final placaController = TextEditingController();
  final telefoneController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    placaController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Text('Agendamento de Placas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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

                    // Telefone
                    TextField(
                      keyboardType: TextInputType.phone,
                      controller: telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone / WhatsApp *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Placa do Veículo
                    TextField(
                      enabled: !veiculoZeroKm,
                      controller: placaController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: veiculoZeroKm ? 'Veículo ZERO KM - sem placa' : 'Placa do Veículo *',
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
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),

                    const SizedBox(height: 12),

                    // Seleção de Data
                    const Text('Data do Agendamento *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
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
                          firstDate: DateUtils.dateOnly(DateTime.now()),
                          lastDate: DateUtils.dateOnly(
                            DateTime.now().add(const Duration(days: 90)),
                          ),
                        );

                        if (selectedDate != null) {
                          setState(() {
                            dataSelecionada = selectedDate;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month, color: Colors.white),
                      label: Text(
                        '${dataSelecionada.day.toString().padLeft(2, '0')}/'
                        '${dataSelecionada.month.toString().padLeft(2, '0')}/'
                        '${dataSelecionada.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botão Salvar
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
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de Meus Agendamentos
            ValueListenableBuilder<List<Agendament>>(
              valueListenable: store,
              builder: (context, lista, child) {
                if (lista.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Meus Agendamentos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF172B4D),
                          ),
                    ),
                    const SizedBox(height: 12),
                    for (var item in lista) _cardAgendamentoCliente(item),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardAgendamentoCliente(Agendament item) {
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0x1A1565C0),
          child: const Icon(Icons.calendar_today, color: Color(0xFF1565C0)),
        ),
        title: Text(
          item.nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Serviço: ${item.servico} | Placa: ${item.placa}'),
            Text('Data: $dataFormatada'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: corStatus.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: corStatus),
          ),
          child: Text(
            item.status,
            style: TextStyle(color: corStatus, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        onTap: () => editarAgendamento(item),
      ),
    );
  }

  void salvarAgendamento() {
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

    final agendamento = Agendament()
      ..id = '$placa-$telefone'
      ..nome = nome
      ..placa = placa
      ..telefone = telefone
      ..servico = servicoSelecionado
      ..data = dataSelecionada
      ..status = 'Pendente';

    store.salvarOuAtualizar(agendamento);

    nomeController.clear();
    placaController.clear();
    telefoneController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Agendamento realizado/atualizado com sucesso!'),
      ),
    );
  }

  void editarAgendamento(Agendament item) {
    setState(() {
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados carregados no formulário para edição.'),
      ),
    );
  }
}

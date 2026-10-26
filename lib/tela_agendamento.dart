import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    while (!store.isDiaUtil(dataSelecionada)) {
      dataSelecionada = dataSelecionada.add(const Duration(days: 1));
    }
    telefoneController.addListener(() {
      setState(() {});
    });
  }

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

                    const SizedBox(height: 12),

                    // Seleção de Data
                    const Text('Data do Agendamento * (Segunda a Sexta)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      icon: const Icon(Icons.calendar_month, color: Colors.white),
                      label: Text(
                        '${dataSelecionada.day.toString().padLeft(2, '0')}/'
                        '${dataSelecionada.month.toString().padLeft(2, '0')}/'
                        '${dataSelecionada.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Seleção de Horário
                    const Text(
                      'Horários Disponíveis (08:30 às 17:30 - Fechado de 12h às 13h) *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    ValueListenableBuilder<List<Agendament>>(
                      valueListenable: store,
                      builder: (context, lista, child) {
                        final ehDiaBloqueado = store.isDiaBloqueado(dataSelecionada);

                        if (ehDiaBloqueado) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.block, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Atendimento indisponível nesta data.',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AgendamentoStore.todosHorarios.map((horario) {
                            final disponivel = store.isHorarioDisponivel(dataSelecionada, horario);
                            final selecionado = horarioSelecionado == horario;

                            return ChoiceChip(
                              label: Text(horario),
                              selected: selecionado,
                              disabledColor: Colors.grey.shade200,
                              selectedColor: Colors.green[700],
                              labelStyle: TextStyle(
                                color: !disponivel
                                    ? Colors.grey.shade500
                                    : selecionado
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: selecionado || disponivel ? FontWeight.bold : FontWeight.normal,
                              ),
                              avatar: !disponivel ? const Icon(Icons.lock_clock, size: 16, color: Colors.grey) : null,
                              onSelected: disponivel
                                  ? (bool val) {
                                      setState(() {
                                        horarioSelecionado = val ? horario : null;
                                      });
                                    }
                                  : null,
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

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
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de Meus Agendamentos (somente do telefone informado)
            ValueListenableBuilder<List<Agendament>>(
              valueListenable: store,
              builder: (context, lista, child) {
                final telInformado = telefoneController.text.trim();
                if (telInformado.isEmpty) return const SizedBox.shrink();

                final meusAgendamentos = lista.where((item) => item.telefone.trim() == telInformado).toList();
                if (meusAgendamentos.isEmpty) return const SizedBox.shrink();

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
                    for (var item in meusAgendamentos) _cardAgendamentoCliente(item),
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
            Text('Data: $dataFormatada às ${item.horario}', style: const TextStyle(fontWeight: FontWeight.bold)),
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

    final agendamento = Agendament()
      ..id = '$placa-$telefone-${AgendamentoStore.formatarChaveHorario(dataSelecionada, horarioSelecionado!)}'
      ..nome = nome
      ..placa = placa
      ..telefone = telefone
      ..servico = servicoSelecionado
      ..data = dataSelecionada
      ..horario = horarioSelecionado!
      ..status = 'Confirmado'; // Status sempre 'Confirmado' ao agendar

    store.salvarOuAtualizar(agendamento);

    nomeController.clear();
    placaController.clear();
    telefoneController.clear();
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

import 'package:flutter/material.dart';

import 'model/Agendament.dart';

class TelaAgendamento extends StatefulWidget {
  const TelaAgendamento({super.key});

  @override
  State<TelaAgendamento> createState() => _TelaAgendamentoState();
}

class _TelaAgendamentoState extends State<TelaAgendamento> {
  bool veiculoZeroKm = false;

  DateTime dataSelecionada = DateTime.now();

  final listaAgendamentos = <Agendament>[];
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
      appBar: AppBar(title: const Text('Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tela de Agendamento',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              keyboardType: TextInputType.phone,
              controller: telefoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone / WhatsApp',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              enabled: !veiculoZeroKm,
              controller: placaController,
              decoration: InputDecoration(
                labelText: veiculoZeroKm
                    ? 'Veículo ZERO KM - sem placa'
                    : 'Placa do Veículo',
                border: const OutlineInputBorder(),
              ),
            ),

            CheckboxListTile(
              title: const Text(
                'Veículo ZERO KM',
                style: TextStyle(fontSize: 14),
              ),
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

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Data do Agendamento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: dataSelecionada,
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.blueAccent,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Data escolhida: '
              '${dataSelecionada.day.toString().padLeft(2, '0')}/'
              '${dataSelecionada.month.toString().padLeft(2, '0')}/'
              '${dataSelecionada.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => salvarAgendamento(),
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 16),

            if (listaAgendamentos.isNotEmpty) ...[
              const Text(
                'Meus agendamentos:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (var item in listaAgendamentos)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(item.nome),
                    subtitle: Text(
                      'Placa: ${item.placa} | Tel: ${item.telefone}',
                    ),
                    trailing: Text(
                      '${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}',
                      textAlign: TextAlign.start,
                    ),
                    onTap: () => editarAgendamento(item),
                  ),
                ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void salvarAgendamento() {
    final nome = nomeController.text.trim();
    final telefone = telefoneController.text.trim();
    final placa = veiculoZeroKm ? 'ZERO KM' : placaController.text.trim();

    if (nome.isEmpty || telefone.isEmpty || (!veiculoZeroKm && placa.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Por favor, preencha todos os campos!'),
        ),
      );
      return;
    }

    // Procura se já existe um agendamento com a mesma placa ou mesmo telefone
    final indexExistente = listaAgendamentos.indexWhere((item) {
      final mesmaPlaca = !veiculoZeroKm &&
          item.placa.toUpperCase() == placa.toUpperCase() &&
          item.placa != 'ZERO KM';
      final mesmoTelefone = item.telefone == telefone;
      return mesmaPlaca || mesmoTelefone;
    });

    final agendamento = Agendament();
    agendamento.id = '$placa-$telefone';
    agendamento.nome = nome;
    agendamento.placa = placa;
    agendamento.telefone = telefone;
    agendamento.data = dataSelecionada;

    bool foiAtualizado = false;

    setState(() {
      if (indexExistente != -1) {
        // Substitui o agendamento existente
        listaAgendamentos[indexExistente] = agendamento;
        foiAtualizado = true;
      } else {
        // Adiciona um novo agendamento
        listaAgendamentos.add(agendamento);
      }
    });

    nomeController.clear();
    placaController.clear();
    telefoneController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          foiAtualizado
              ? 'Agendamento atualizado com sucesso!'
              : 'Agendamento realizado com sucesso!',
        ),
      ),
    );
  }

  void editarAgendamento(Agendament item) {
    setState(() {
      nomeController.text = item.nome;
      telefoneController.text = item.telefone;
      if (item.placa == 'ZERO KM') {
        veiculoZeroKm = true;
        placaController.clear();
      } else {
        veiculoZeroKm = false;
        placaController.text = item.placa;
      }
      dataSelecionada = item.data;
    });
  }
}

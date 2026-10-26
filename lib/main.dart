import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'tela_admin.dart';
import 'tela_agendamento.dart';

void main() {
  runApp(const ItaplacasApp());
}

class ItaplacasApp extends StatelessWidget {
  const ItaplacasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      title: 'ITAPLACAS - Agendamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          primary: const Color(0xFF0D47A1),
          secondary: const Color(0xFF1565C0),
        ),
        fontFamily: 'Roboto',
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.directions_car, size: 28),
            SizedBox(width: 10),
            Text(
              'ITAPLACAS',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Área do Administrador',
            onPressed: () => _acessarAreaAdmin(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Banner Inicial
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: const Color(0xFF0D47A1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_month, size: 70, color: Colors.white),
                          const SizedBox(height: 16),
                          const Text(
                            'Agendamento Online',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Garanta o horário para troca ou instalação da sua placa automotiva.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 24),

                          // Botão Principal Agendar
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0D47A1),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TelaAgendamento(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.event_available, color: Color(0xFF0D47A1)),
                            label: const Text('FAZER AGENDAMENTO'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Nossos Serviços
                  const Text(
                    'Nossos Serviços',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const CartaoServico(
                    icone: Icons.car_repair,
                    titulo: 'Troca de Placa',
                    descricao: 'Substituição rápida e segura da placa do seu veículo conforme padrão Mercosul.',
                  ),

                  const SizedBox(height: 12),

                  const CartaoServico(
                    icone: Icons.directions_car_filled,
                    titulo: 'Instalação de Placa',
                    descricao: 'Emplacamento completo para veículos 0km ou transferências.',
                  ),

                  const SizedBox(height: 32),

                  // Área do Administrador Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, size: 40, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Área do Administrador',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Gestão completa de agendamentos, status e contatos.',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _acessarAreaAdmin(context),
                            child: const Text('ENTRAR'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Rodapé
                  const Text(
                    'ITAPLACAS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    '📍 Endereço: Rua Sebastião Leite, nº 122, Varginha, Itajubá - MG',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),

                  const SizedBox(height: 16),

                  // Botão WhatsApp
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final Uri uri = Uri.parse('https://wa.me/5535998120722');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text(
                      'FALAR NO WHATSAPP (35) 99812-0722',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _acessarAreaAdmin(BuildContext context) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Color(0xFF0D47A1)),
            SizedBox(width: 8),
            Text('Acesso Restrito'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite a senha de administrador para acessar o painel:'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Senha (Padrão: 1234)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
            onPressed: () {
              if (pinController.text.trim() == '1234') {
                Navigator.pop(context); // fecha dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaAdmin()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Senha incorreta! (Tente 1234)'),
                  ),
                );
              }
            },
            child: const Text('Entrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CartaoServico extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;

  const CartaoServico({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0x1A0D47A1),
              child: Icon(icone, size: 30, color: const Color(0xFF0D47A1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(color: Colors.black54, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

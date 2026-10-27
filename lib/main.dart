import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';
import 'tela_admin.dart';
import 'tela_agendamento.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Aviso: Inicializando Firebase em modo de compatibilidade/local: $e');
  }

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF007F),
          surface: Color(0xFF161616),
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
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
              ),
              child: const Icon(Icons.directions_car, size: 20, color: Color(0xFF00E5FF)),
            ),
            const SizedBox(width: 10),
            const Text(
              'ITAPLACAS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFF00E5FF),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFFF007F)),
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
                  const SizedBox(height: 10),

                  // Logo Estilizado IDÊNTICO à imagem enviada
                  const LogoItaplacas(),

                  const SizedBox(height: 24),

                  // Banner / Botão Agendar
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF161616), Color(0xFF1F1F1F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      
                        borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF007F).withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF007F).withValues(alpha: 0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_month, size: 60,
                              color: Color(0xFF00E5FF)),
                          const SizedBox(height: 16),
                          const Text(
                            'Agendamento Online',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Garanta o seu horário para troca ou instalação de placa Mercosul.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, color: Colors.white70),
                          ),
                          const SizedBox(height: 24),

                          // Botão Principal Agendar com cor Neon Pink/Cyan
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: Colors.black,
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
                            icon: const Icon(Icons.event_available, color: Colors.black),
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
      builder: (context) {
        bool obscureText = true;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Color(0xFF0D47A1)),
                  SizedBox(width: 8),
                  Text('Painel Administrativo'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Digite a senha de administrador para acessar o painel:',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: obscureText,
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Senha de Administrador',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) {
                      if (pinController.text.trim() == 'Itaplacas@2025') {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TelaAdmin()),
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Senha incorreta. Acesso negado.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (pinController.text.trim() == 'Itaplacas@2025') {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaAdmin()),
                      );
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Senha incorreta. Acesso negado.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Entrar'),
                ),
              ],
            );
          },
        );
      },
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
      color: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0x1A00E5FF),
              child: Icon(icone, size: 30, color: const Color(0xFF00E5FF)),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(color: Colors.white70, height: 1.3),
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

class LogoItaplacas extends StatelessWidget {
  const LogoItaplacas({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E5FF),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFFF007F).withValues(alpha: 0.25),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ITAPLACAS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00E5FF),
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0xFF00E5FF),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'PLACAS   MERCOSUL',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF007F),
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: Color(0xFFFF007F),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF007F), size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Av. Henriqueto Cardinale, 390 - Varginha, Itajubá - MG, 37501-153',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.greenAccent, size: 22),
              const SizedBox(width: 10),
              const Text(
                '(35) 9 9812-0722',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

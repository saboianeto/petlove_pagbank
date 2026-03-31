import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const PetlovePOSApp());
}

// ─────────────────────────────────────────
// MODELO DE VENDA
// ─────────────────────────────────────────
class Venda {
  final String codigo;
  final String valor;
  final String tipo;
  final DateTime dataHora;

  Venda({
    required this.codigo,
    required this.valor,
    required this.tipo,
    required this.dataHora,
  });

  String get dataHoraFormatada =>
      '${dataHora.day.toString().padLeft(2, '0')}/${dataHora.month.toString().padLeft(2, '0')}/${dataHora.year}  '
      '${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────
// STORE GLOBAL
// ─────────────────────────────────────────
class VendasStore {
  static final VendasStore _i = VendasStore._();
  factory VendasStore() => _i;
  VendasStore._();
  final List<Venda> _list = [];
  List<Venda> get vendas => List.unmodifiable(_list.reversed.toList());
  void add(Venda v) => _list.add(v);
}

// ─────────────────────────────────────────
// SERVIÇO DE IMPRESSÃO
// ─────────────────────────────────────────
class PrintService {
  /// Impressão SIMULADA (log / popup)
  static Future<void> imprimirSimulado(
      BuildContext context, Venda venda) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final linhas = [
      '================================',
      '         petlove♥               '
      '   COMPROVANTE DE PAGAMENTO     '
      '================================',
      'Código  : #${venda.codigo}',
      'Data    : ${venda.dataHoraFormatada}',
      'Tipo    : ${venda.tipo}',
      'Status  : APROVADO ✓',
      '--------------------------------',
      'TOTAL   : R\$ ${venda.valor}',
      '================================',
    ];

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: Color(0xFF2D1060)),
              SizedBox(width: 8),
              Text('Prévia da Impressão',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              linhas.join('\n'),
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                color: Color(0xFF222222),
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar',
                  style: TextStyle(color: Color(0xFF2D1060))),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A4A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Impressão REAL via Gertec GPOS720
  /// Requer package: gertec: ^0.0.9 no pubspec.yaml
  /// Só funciona no dispositivo físico GPOS720
  static Future<void> imprimirGertec(
      BuildContext context, Venda venda) async {
    try {
      // ── GERTEC REAL ──────────────────────────────
      // Descomente abaixo quando rodar no GPOS720:
      //
      // import 'package:gertec/gertec.dart';
      //
      // final printer = GertecPrinter();
      // await printer.startTransaction();
      // await printer.printText('================================');
      // await printer.printText('         petlove               ');
      // await printer.printText('   COMPROVANTE DE PAGAMENTO    ');
      // await printer.printText('================================');
      // await printer.printText('Codigo  : #${venda.codigo}');
      // await printer.printText('Data    : ${venda.dataHoraFormatada}');
      // await printer.printText('Tipo    : ${venda.tipo}');
      // await printer.printText('Status  : APROVADO');
      // await printer.printText('--------------------------------');
      // await printer.printText('TOTAL   : R\$ ${venda.valor}');
      // await printer.printText('================================');
      // await printer.wrapLine(3);
      // await printer.cutPaper();
      // await printer.finishTransaction();
      // ─────────────────────────────────────────────

      // Simulação para desenvolvimento no Chrome/Windows:
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️ Gertec GPOS720: disponível apenas no terminal físico'),
            backgroundColor: Color(0xFFE8901A),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro impressora Gertec: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────
// APP
// ─────────────────────────────────────────
class PetlovePOSApp extends StatelessWidget {
  const PetlovePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petlove POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D1A6E)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────
// SPLASH
// ─────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1060),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PetloveLogo(dark: false, size: 38),
                SizedBox(height: 48),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                      color: Color(0xFFE8445A), strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HOME — TECLADO POS
// ─────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _raw = '';

  String get _valor => _formatValue(_raw);

  void _digit(String d) => setState(() {
        final n = _raw + d;
        _raw = n.length > 8 ? n.substring(n.length - 8) : n;
      });

  void _back() => setState(
      () => _raw = _raw.isEmpty ? '' : _raw.substring(0, _raw.length - 1));

  void _clear() => setState(() => _raw = '');

  String _formatValue(String raw) {
    if (raw.isEmpty) return '0,00';
    final p = raw.padLeft(3, '0');
    final cents = p.substring(p.length - 2);
    final reais = int.parse(p.substring(0, p.length - 2)).toString();
    return '${_dots(reais)},$cents';
  }

  String _dots(String s) {
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }

  void _cobrar() {
    if (_raw.isEmpty) return;
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => PaymentScreen(valor: _valor)))
        .then((_) => _clear());
  }

  String _timeNow() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')} • ${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF5),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: const Color(0xFF2D1060),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: _clear,
                      child: const PetloveLogo(dark: false)),
                  Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_timeNow(),
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11)),
                        const Text('Terminal POS',
                            style: TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HistoricoScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(children: [
                          Icon(Icons.history_rounded,
                              color: Colors.white, size: 15),
                          SizedBox(width: 4),
                          Text('Histórico',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ]),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            // DISPLAY VALOR
            Container(
              color: const Color(0xFF3D1A6E),
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('VALOR A COBRAR',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 2)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text('R\$ ', style: TextStyle(
                              color: Colors.white60,
                              fontSize: 16,
                              fontWeight: FontWeight.w300)),
                      Text(_valor,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1)),
                    ],
                  ),
                ],
              ),
            ),

            // TECLADO — ocupa todo espaço restante
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  children: [
                    // Grid de teclas — Expanded para preencher até o COBRAR
                    Expanded(
                      child: Column(
                        children: [
                          // Linhas 1-3-6-9
                          for (final row in [
                            ['1', '2', '3'],
                            ['4', '5', '6'],
                            ['7', '8', '9'],
                          ])
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: row
                                      .map((d) => Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: d != row.last
                                                      ? 8
                                                      : 0),
                                              child: _Key(d,
                                                  () => _digit(d)),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          // Última linha: C / 0 / ⌫
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: _Key('C', _clear,
                                        bg: const Color(0xFFE8445A),
                                        fg: Colors.white)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _Key('0', () => _digit('0'))),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _Key('⌫', _back,
                                        bg: const Color(0xFF999999),
                                        fg: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // COBRAR
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _cobrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D1060),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        child: const Text('COBRAR',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// PAYMENT SCREEN
// ─────────────────────────────────────────
class PaymentScreen extends StatelessWidget {
  final String valor;
  const PaymentScreen({super.key, required this.valor});

  void _finalizar(BuildContext context, String tipo) {
    final v = Venda(
      codigo: DateTime.now().millisecondsSinceEpoch.toString().substring(5),
      valor: valor,
      tipo: tipo,
      dataHora: DateTime.now(),
    );
    VendasStore().add(v);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ReceiptScreen(venda: v)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1060),
        foregroundColor: Colors.white,
        title: GestureDetector(
          onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: const PetloveLogo(dark: false),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text('FORMA DE PAGAMENTO',
                  style: TextStyle(
                      color: Color(0xFF2D1060),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text('R\$ ', style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 18,
                          fontWeight: FontWeight.w300)),
                  Text(valor,
                      style: const TextStyle(
                          color: Color(0xFF2D1060),
                          fontSize: 38,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 36),
              _PayOption(
                icon: Icons.credit_card_rounded,
                label: 'CRÉDITO',
                sub: 'À vista ou parcelado',
                color: const Color(0xFF2D1060),
                onTap: () => _finalizar(context, 'CRÉDITO'),
              ),
              const SizedBox(height: 14),
              _PayOption(
                icon: Icons.contactless_rounded,
                label: 'DÉBITO',
                sub: 'Débito em conta',
                color: const Color(0xFF1A7A4A),
                onTap: () => _finalizar(context, 'DÉBITO'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: Color(0xFFE8445A))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// RECEIPT SCREEN
// ─────────────────────────────────────────
class ReceiptScreen extends StatefulWidget {
  final Venda venda;
  const ReceiptScreen({super.key, required this.venda});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _printingLog = false;
  bool _printingGertec = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _imprimirLog() async {
    setState(() => _printingLog = true);
    await PrintService.imprimirSimulado(context, widget.venda);
    if (mounted) setState(() => _printingLog = false);
  }

  Future<void> _imprimirGertec() async {
    setState(() => _printingGertec = true);
    await PrintService.imprimirGertec(context, widget.venda);
    if (mounted) setState(() => _printingGertec = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1060),
      body: SafeArea(
        child: Column(
          children: [
            // SUCESSO
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                          color: Color(0xFF1A7A4A),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('TRANSAÇÃO APROVADA',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2)),
                  const SizedBox(height: 2),
                  const Text('Pagamento realizado com sucesso',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),

            // CUPOM
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F4FF),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: const Column(
                        children: [
                          PetloveLogo(),
                          SizedBox(height: 2),
                          Text('COMPROVANTE DE PAGAMENTO',
                              style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF999999))),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _Row('Data/Hora',
                                widget.venda.dataHoraFormatada),
                            _Row('Código', '#${widget.venda.codigo}'),
                            _Row('Tipo', widget.venda.tipo),
                            _Row('Status', '✓ APROVADO',
                                vc: const Color(0xFF1A7A4A)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TOTAL',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2D1060))),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const Text('R\$ ', style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF666666))),
                                    Text(widget.venda.valor,
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2D1060))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const _ZigZag(),
                  ],
                ),
              ),
            ),

            // BOTÕES DE IMPRESSÃO + NOVA COBRANÇA
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Botão 1 — Prévia / Log
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _printingLog ? null : _imprimirLog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2D1060),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: _printingLog
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2D1060)))
                          : const Icon(Icons.preview_rounded, size: 18),
                      label: Text(
                          _printingLog ? 'Gerando...' : 'Prévia (Log)',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Botão 2 — Impressora Gertec GPOS720
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          _printingGertec ? null : _imprimirGertec,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: Colors.white30)),
                        elevation: 0,
                      ),
                      icon: _printingGertec
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Icon(Icons.print_rounded, size: 18),
                      label: Text(
                          _printingGertec
                              ? 'Imprimindo...'
                              : 'Imprimir — GPOS720',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nova cobrança
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8445A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('NOVA COBRANÇA',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    ),
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

// ─────────────────────────────────────────
// HISTÓRICO
// ─────────────────────────────────────────
class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendas = VendasStore().vendas;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1060),
        foregroundColor: Colors.white,
        title: const Text('Histórico de Vendas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: vendas.isEmpty
          ? const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_rounded,
                    size: 64, color: Color(0xFFCCCCCC)),
                SizedBox(height: 12),
                Text('Nenhuma venda realizada ainda',
                    style: TextStyle(color: Color(0xFF999999))),
              ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vendas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final v = vendas[i];
                final isC = v.tipo == 'CRÉDITO';
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ReceiptScreen(venda: v))),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isC
                            ? const Color(0xFFEEE8FF)
                            : const Color(0xFFE8F5EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isC
                            ? Icons.credit_card_rounded
                            : Icons.contactless_rounded,
                        color: isC
                            ? const Color(0xFF2D1060)
                            : const Color(0xFF1A7A4A),
                        size: 22,
                      ),
                    ),
                    title: Row(children: [
                      Text('R\$ ${v.valor}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF2D1060))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isC
                              ? const Color(0xFF2D1060)
                              : const Color(0xFF1A7A4A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(v.tipo,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                      ),
                    ]),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#${v.codigo}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF999999))),
                          Text(v.dataHoraFormatada,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF999999))),
                        ],
                      ),
                    ),
                    trailing: _PrintButton(venda: v),
                  ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────
// BOTÃO IMPRIMIR NO HISTÓRICO
// ─────────────────────────────────────────
class _PrintButton extends StatefulWidget {
  final Venda venda;
  const _PrintButton({required this.venda});

  @override
  State<_PrintButton> createState() => _PrintButtonState();
}

class _PrintButtonState extends State<_PrintButton> {
  bool _loading = false;

  Future<void> _print() async {
    setState(() => _loading = true);
    await PrintService.imprimirGertec(context, widget.venda);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _print,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1060),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.print_rounded,
                color: Colors.white, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────
// WIDGETS REUTILIZÁVEIS
// ─────────────────────────────────────────
class PetloveLogo extends StatelessWidget {
  final bool dark;
  final double size;
  const PetloveLogo({super.key, this.dark = true, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
            text: 'petlove',
            style: TextStyle(
                color: dark ? const Color(0xFF2D1060) : Colors.white,
                fontSize: size,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5)),
        TextSpan(
            text: '♥',
            style: TextStyle(
                color: const Color(0xFFE8445A), fontSize: size * 0.8)),
      ]),
    );
  }
}

class _Key extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? bg;
  final Color? fg;
  const _Key(this.label, this.onTap, {this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg ?? Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: fg ?? const Color(0xFF2D1060))),
        ),
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _PayOption(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 18),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
              Text(sub,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ]),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white54, size: 26),
          ]),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String l;
  final String v;
  final Color? vc;
  const _Row(this.l, this.v, {this.vc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF888888))),
          Text(v,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: vc ?? const Color(0xFF333333))),
        ],
      ),
    );
  }
}

class _ZigZag extends StatelessWidget {
  const _ZigZag();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      width: double.infinity,
      child: CustomPaint(painter: _ZigZagPainter()),
    );
  }
}

class _ZigZagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF2D1060);
    final path = Path()..moveTo(0, 0);
    double x = 0;
    bool up = true;
    while (x < size.width) {
      x += 9;
      path.lineTo(x, up ? size.height : 0);
      up = !up;
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

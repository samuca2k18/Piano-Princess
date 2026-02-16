import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:piano_princess/data/services/firestore_service.dart';

class TeacherCodePage extends StatefulWidget {
  const TeacherCodePage({super.key});

  @override
  State<TeacherCodePage> createState() => _TeacherCodePageState();
}

class _TeacherCodePageState extends State<TeacherCodePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  final _studentCodeCtrl = TextEditingController();
  final _teacherActivationCtrl = TextEditingController();

  bool _loading = false;
  String? _myTeacherCode;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadTeacherCodeIfAny();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _studentCodeCtrl.dispose();
    _teacherActivationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherCodeIfAny() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final code = await FirestoreService.instance.getMyTeacherCode(user.uid);
    if (!mounted) return;
    setState(() => _myTeacherCode = code);
  }

  Future<void> _connectAsStudent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final code = _studentCodeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código da professora.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirestoreService.instance.connectStudentToTeacherByCode(
        uid: user.uid,
        code: code, teacherCode: '',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Conectada à professora!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _activateAsTeacher() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final activationCode = _teacherActivationCtrl.text.trim().toUpperCase();
    if (activationCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código de ativação.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // 1) ativa
      await FirestoreService.instance.activateAsTeacher(
        uid: user.uid,
        code: activationCode, activationCode: '', name: '',
      );

      // 2) recarrega o código da professora (o "código pra alunas")
      final newCode = await FirestoreService.instance.getMyTeacherCode(user.uid);

      if (!mounted) return;
      setState(() => _myTeacherCode = newCode);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newCode == null
                ? '👑 Modo professora ativado!'
                : '👑 Modo professora ativado! Seu código: $newCode',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações • Professora'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Sou aluna'),
            Tab(text: 'Sou professora'),
          ],
        ),
      ),
      body: AbsorbPointer(
        absorbing: _loading,
        child: TabBarView(
          controller: _tabs,
          children: [
            // ======== ALUNA ========
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Digite o código da sua professora',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _studentCodeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Código da professora (ex: ABCD12)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _connectAsStudent,
                      child: _loading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Conectar'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Depois de conectar, você vai ver músicas e exercícios liberados pela professora.',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
            ),

            // ======== PROFESSORA ========
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ativar modo professora',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _teacherActivationCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Código de ativação (secreto)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _activateAsTeacher,
                      child: _loading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Ativar professora'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.primary.withOpacity(0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seu código para alunos:',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          _myTeacherCode ?? 'Ainda não gerado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Passe esse código para suas alunas colocarem na aba "Sou aluna".',
                          style: TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ],
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

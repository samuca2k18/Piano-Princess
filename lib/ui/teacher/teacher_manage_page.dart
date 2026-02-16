import 'package:flutter/material.dart';

class TeacherManagePage extends StatelessWidget {
  const TeacherManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão')),
      body: const Center(
        child: Text(
          'Aqui o professor vai controlar os alunos 👩‍🏫',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

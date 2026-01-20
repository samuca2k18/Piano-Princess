import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano Princess'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sair (mock)',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'HOME (mockada)\nAgora vamos preencher com músicas, jogos, pintar e exercícios ✨',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HistoryPlaceholderScreen extends StatelessWidget {
  const HistoryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonScreen(title: 'History');
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const SafeArea(
        child: Center(
          child: Text('Coming soon'),
        ),
      ),
    );
  }
}

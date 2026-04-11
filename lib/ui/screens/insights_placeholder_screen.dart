import 'package:flutter/material.dart';

class InsightsPlaceholderScreen extends StatelessWidget {
  const InsightsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insights'),
      ),
      body: SafeArea(
        child: Center(
          child: Text('Coming soon'),
        ),
      ),
    );
  }
}

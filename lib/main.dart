import 'package:flutter/material.dart';
import 'package:student_report/widgets/app_bar.dart';
import 'package:student_report/widgets/generate_button.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: Image.asset('assets/sekolah.webp', fit: BoxFit.cover),
              ),
              GenerateButton(),
            ],
          ),
        ),
      ),
    );
  }
}

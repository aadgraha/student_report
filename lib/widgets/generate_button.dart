import 'dart:async';

import 'package:flutter/material.dart';
import 'package:student_report/shared/colors.dart';
import 'package:student_report/widgets/step_progress_bar.dart';

class GenerateButton extends StatefulWidget {
  const GenerateButton({super.key});

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton> {
  bool _inProgress = false;
  @override
  Widget build(BuildContext context) {
    void onPressed() {
      setState(() {
        _inProgress = true;
      });
      int n = 0;
      Timer? timer;
      final snackBar = SnackBar(
        padding: EdgeInsets.only(bottom: 10, top: 5, right: 10, left: 10),
        backgroundColor: AppColors.buttonBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        behavior: SnackBarBehavior.floating,
        content: StatefulBuilder(
          builder: (context, ss) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (!context.mounted) return;
              if (n < 10) {
                n++;
                ss(() {}); // rebuilds only the Snackbar content
              } else {
                t.cancel();
                ScaffoldMessenger.of(
                  context,
                ).hideCurrentSnackBar(); // optional: auto close
              }
            });
            return Column(
              children: [
                Text(
                  'Sedang memproses data ($n/10)',
                  style: TextStyle(
                    color: AppColors.buttonFrColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                StepProgressBar(totalSteps: 10, currentStep: n),
              ],
            );
          },
        ),
        duration: Duration(days: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) {
        timer?.cancel();
        _inProgress = false;
        setState(() {});
      });
    }

    return Tooltip(
      message: 'Clik untuk mengupload file excel',
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.buttonBgColor),
        ),
        onPressed: !_inProgress ? onPressed : null,
        child: Icon(Icons.upload, size: 50, color: AppColors.buttonFrColor),
      ),
    );
  }
}

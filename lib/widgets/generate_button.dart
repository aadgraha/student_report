import 'dart:async';

import 'package:flutter/material.dart';
import 'package:student_report/shared/colors.dart';
import 'package:student_report/widgets/step_progress_bar.dart';

class GenerateButton extends StatelessWidget {
  const GenerateButton({super.key});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      int n = 0;
      Timer? timer;
      final snackBar = SnackBar(
        backgroundColor: AppColors.buttonBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        behavior: SnackBarBehavior.floating,
        content: StatefulBuilder(
          builder: (context, setState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (!context.mounted) return;
              if (n < 10) {
                n++;
                setState(() {}); // rebuilds only the Snackbar content
              } else {
                t.cancel();
                ScaffoldMessenger.of(
                  context,
                ).hideCurrentSnackBar(); // optional: auto close
              }
            });
            return Column(
              children: [StepProgressBar(totalSteps: 10, currentStep: n)],
            );
          },
        ),
        duration: Duration(days: 3),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(snackBar).closed.then((_) => timer?.cancel());
    }

    return Tooltip(
      message: 'Clik untuk mengupload file excel',
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.buttonBgColor),
        ),
        onPressed: onPressed,
        child: Icon(Icons.upload, size: 50, color: AppColors.buttonFrColor),
      ),
    );
  }
}

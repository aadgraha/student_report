import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_report/bloc/step_bloc.dart' as step_bloc;
import 'package:student_report/util/colors.dart';
import 'package:student_report/util/generate_pdf.dart';
import 'package:student_report/widgets/step_progress_bar.dart';

class GenerateButton extends StatefulWidget {
  const GenerateButton({super.key});

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton> {
  final _stepBloc = step_bloc.StepBloc();
  var _inProgress = false;

  @override
  void dispose() {
    _stepBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showSnackBar() {
      final snackBar = SnackBar(
        padding: EdgeInsets.only(bottom: 10, top: 5, right: 10, left: 10),
        backgroundColor: AppColors.buttonBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        behavior: SnackBarBehavior.floating,
        content: BlocBuilder<step_bloc.StepBloc, step_bloc.StepState>(
          bloc: _stepBloc,
          builder: (context, state) {
            return Column(
              children: [
                if (state.message != null)
                  Text(
                    state.message!,
                    style: TextStyle(
                      color: AppColors.buttonFrColor,
                      fontSize: 16,
                    ),
                  ),
                SizedBox(height: 5),
                Builder(
                  builder: (context) {
                    if ((state.total != null) && (state.now != null)) {
                      return StepProgressBar(
                        totalSteps: state.total!,
                        currentStep: state.now!,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ],
            );
          },
        ),
        duration: Duration(days: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Tooltip(
      message: !_inProgress ? 'Klik untuk mengupload file excel' : '',
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.buttonBgColor),
        ),
        onPressed:
            !_inProgress
                ? () {
                  generatePdf(
                    stepBloc: _stepBloc,
                    onStart: () {
                      setState(() {
                        _inProgress = true;
                      });
                      showSnackBar();
                    },
                    onDone: () async {
                      final scaffoldMessager = ScaffoldMessenger.of(context);
                      Future.delayed(Duration(milliseconds: 1250), () {
                        scaffoldMessager.hideCurrentSnackBar();
                        setState(() {
                          _inProgress = false;
                        });
                      });
                    },
                  );
                }
                : null,
        child: Icon(Icons.upload, size: 50, color: AppColors.buttonFrColor),
      ),
    );
  }
}

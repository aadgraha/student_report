import 'dart:async';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:student_report/util/colors.dart';
import 'package:student_report/widgets/step_progress_bar.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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

    void readExcel() async {
      final data = <Map<String, dynamic>>[];
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (pickedFile != null) {
        var bytes = pickedFile.files.single.bytes!.toList();
        var excel = Excel.decodeBytes(bytes);
        for (var table in excel.tables.keys) {
          final rowData = <Map<String, dynamic>>[];
          final row = excel.tables[table]!.rows;
          for (var i = 0; i < row.length; i++) {
            if (i == 0) continue;
            rowData.add({
              'student_name': row[i][0]?.value ?? '',
              'bind_1': row[i][1]?.value ?? '',
              'bing_1': row[i][2]?.value ?? '',
              'mtk_1': row[i][3]?.value ?? '',
              'ipa_1': row[i][4]?.value ?? '',
            });
          }
          data.add({table: rowData});
        }
        final pdfBytes = await rootBundle.load('assets/template.pdf');
        final pdfData = pdfBytes.buffer.asUint8List();
        final outputDoc = PdfDocument();
        for (var sheet in data) {
          for (var entry in sheet.entries) {
            final rows = entry.value;
            for (var row in rows) {
              final document = PdfDocument(inputBytes: pdfData);
              final form = document.form;
              for (var i = 0; i < form.fields.count; i++) {
                (form.fields[i] as PdfTextBoxField).font = PdfStandardFont(
                  PdfFontFamily.timesRoman,
                  12,
                );
                if (form.fields[i].name == 'student_name') {
                  (form.fields[i] as PdfTextBoxField).text =
                      row['student_name'].toString();
                }
                if (form.fields[i].name == 'bind_1') {
                  (form.fields[i] as PdfTextBoxField).text =
                      row['bind_1'].toString();
                }
                if (form.fields[i].name == 'bing_1') {
                  (form.fields[i] as PdfTextBoxField).text =
                      row['bing_1'].toString();
                }
                if (form.fields[i].name == 'mtk_1') {
                  (form.fields[i] as PdfTextBoxField).text =
                      row['mtk_1'].toString();
                }
                if (form.fields[i].name == 'ipa_1') {
                  (form.fields[i] as PdfTextBoxField).text =
                      row['ipa_1'].toString();
                }
              }

              form.setDefaultAppearance(true);
              form.flattenAllFields();
              await document.save();
              outputDoc.pages.add().graphics.drawPdfTemplate(
                document.pages[0].createTemplate(),
                const Offset(0, 0),
              );
              document.dispose();
            }
          }
        }
        final finalBytes = await outputDoc.save();
        outputDoc.dispose();
        await Printing.layoutPdf(
          onLayout: (format) => Uint8List.fromList(finalBytes),
        );
      }
    }

    return Tooltip(
      message: 'Clik untuk mengupload file excel',
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.buttonBgColor),
        ),
        onPressed: () => readExcel(),
        // onPressed: !_inProgress ? onPressed : null,
        child: Icon(Icons.upload, size: 50, color: AppColors.buttonFrColor),
      ),
    );
  }
}

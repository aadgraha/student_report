import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_report/util/colors.dart';
import 'package:student_report/util/file_picker.dart';
import 'package:student_report/widgets/step_progress_bar.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:html' as html;

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

        // Process each sheet
        for (var sheet in data) {
          for (var entry in sheet.entries) {
            final rows = entry.value;

            // Process each student row
            for (var row in rows) {
              // Load a *new* copy of the template for each student
              final document = PdfDocument(inputBytes: pdfData);
              final form = document.form;

              // Fill PDF fields (make sure field names match the ones in your template)
              (form.fields[3] as PdfTextBoxField).text =
                  row['student_name'].toString();
              (form.fields[7] as PdfTextBoxField).text =
                  row['bind_1'].toString();

              (form.fields[8] as PdfTextBoxField).text =
                  row['mtk_1'].toString();
              (form.fields[9] as PdfTextBoxField).text =
                  row['ipa_1'].toString();

              // Flatten the form so values are saved visibly
              form.setDefaultAppearance(true);
              form.flattenAllFields();

              // Save to bytes
              await document.save();
              outputDoc.pages.add().graphics.drawPdfTemplate(
                document.pages[0].createTemplate(),
                const Offset(0, 0),
              );
              document.dispose();

              // TODO: Handle file output or add to zip
              // For example, you could store them in a list
            }
          }
        }
        final finalBytes = await outputDoc.save();
        outputDoc.dispose();
        final blob = html.Blob([finalBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'merged_output.pdf')
              ..click();
        html.Url.revokeObjectUrl(url);
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

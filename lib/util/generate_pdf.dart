import 'dart:developer';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:student_report/bloc/step_bloc.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void generatePdf({
  required StepBloc stepBloc,
  required void Function() onDone,
  required void Function() onStart,
}) async {
  try {
    final data = <Map<String, dynamic>>[];
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile != null) {
      onStart();
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
      var currentRow = 0;
      var totalRow =
          data
              .fold<num>(
                0,
                (sum, sheet) =>
                    sum +
                    sheet.values.fold<num>(0, (s, rows) => s + rows.length),
              )
              .toInt();
      for (var sheet in data) {
        for (var entry in sheet.entries) {
          final rows = entry.value;
          for (var row in rows) {
            currentRow++;
            final document = PdfDocument(inputBytes: pdfData);
            stepBloc.setValue((
              message: 'Generating PDF files : ($currentRow/$totalRow)',
              now: currentRow,
              total: totalRow,
            ));
            await Future(() {});
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
      onDone();
    }
  } catch (e) {
    log(e.toString());
  }
}

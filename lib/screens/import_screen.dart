import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raw_material/components/app_button.dart';
import 'package:raw_material/components/app_header.dart';
import 'package:raw_material/screens/scan_screen.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  void _pickFile(BuildContext context) {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    ).then((result) {
      if (result != null) {
        final file = File(result.files.single.path!);
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => ScanScreen(file: file),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const AppHeader(),
            const Spacer(flex: 2),
            AppButton(
              icon: Icons.download,
              text: 'Import',
              onPressed: () => _pickFile(context),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

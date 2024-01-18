import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raw_material/screens/import_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        FilePicker.platform.clearTemporaryFiles().then((value) {
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (context) => const ImportScreen(),
          ));
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Raw Material',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Icon(
            Icons.document_scanner_outlined,
            size: 96,
            color: Theme.of(context).primaryColor,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

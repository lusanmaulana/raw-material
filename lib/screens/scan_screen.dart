import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:raw_material/components/app_button.dart';
import 'package:raw_material/components/app_header.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.file});

  final File file;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _importedCodes = <String>[];
  final _scannedCodes = <String>[];
  final _assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    final codes = widget.file
        .readAsStringSync()
        .split('\n')
        .where((e) => e.isNotEmpty)
        .map((e) => e.trim())
        .toList();
    _importedCodes.addAll(codes);
    _scannedCodes.addAll(codes.map((e) => ''));
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  void _barcodeDetected(String barcode) {
    if (barcode.isNotEmpty) {
      if (_importedCodes.contains(barcode)) {
        if (!_scannedCodes.contains(barcode)) {
          _assetsAudioPlayer.open(
            Audio(
              'assets/audios/oke.mp3',
              metas: Metas(title: 'oke'),
            ),
          );
          final index = _importedCodes.indexOf(barcode);
          setState(() {
            _scannedCodes[index] = barcode;
          });
        } else {
          if ((_assetsAudioPlayer.getCurrentAudioTitle == 'oke' ||
                  _assetsAudioPlayer.getCurrentAudioTitle == 'double') &&
              _assetsAudioPlayer.isPlaying.value) {
            return;
          }
          _assetsAudioPlayer.open(
            Audio(
              'assets/audios/double.mp3',
              metas: Metas(title: 'double'),
            ),
          );
        }
      } else {
        if (_assetsAudioPlayer.getCurrentAudioTitle == 'salah' &&
            _assetsAudioPlayer.isPlaying.value) {
          return;
        }
        _assetsAudioPlayer.open(
          Audio(
            'assets/audios/salah.mp3',
            metas: Metas(title: 'salah'),
          ),
        );
      }
    }
  }

  void _saveFile() async {
    await FileSaver.instance.saveAs(
      name: 'export_${DateTime.now().toIso8601String()}',
      ext: 'txt',
      mimeType: MimeType.text,
      file: widget.file,
    );
    await FilePicker.platform.clearTemporaryFiles();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: BarcodeKeyboardListener(
          caseSensitive: true,
          onBarcodeScanned: _barcodeDetected,
          child: Column(
            children: [
              const AppHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Data Import : ${_importedCodes.length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Data Scan : ${_scannedCodes.where((e) => e.isNotEmpty).length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int i = 0; i < _importedCodes.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 20,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: _scannedCodes[i].isNotEmpty
                                        ? Colors.white
                                        : Colors.yellow,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _scannedCodes[i].isNotEmpty
                                          ? ''
                                          : _importedCodes[i],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 20,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: _scannedCodes[i].isNotEmpty
                                        ? Colors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _scannedCodes[i].isNotEmpty
                                          ? _scannedCodes[i]
                                          : '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // AppButton(
              //   icon: Icons.check,
              //   text: 'Check',
              //   padding: const EdgeInsets.symmetric(vertical: 8),
              //   onPressed: () {
              //     _barcodeDetected("RM-001");
              //   },
              // ),
              if (_scannedCodes.where((e) => e.isNotEmpty).length ==
                  _importedCodes.length) ...[
                AppButton(
                  icon: Icons.upload,
                  text: 'Export',
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: _saveFile,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

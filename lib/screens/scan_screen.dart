import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:raw_material/components/app_button.dart';
import 'package:raw_material/components/app_header.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.file});

  final File file;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _showScanner = false;
  bool _enableTorch = false;
  final _importedCodes = <String>[];
  final _scannedCodes = <String>[];
  MobileScannerController? _mobileScannerController;
  final _assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    final codes = widget.file
        .readAsStringSync()
        .split('\n')
        .where((e) => e.isNotEmpty)
        .map((e) => e.trim())
        .toList();
    debugPrint(codes.join(', '));
    _importedCodes.addAll(codes);
    _scannedCodes.addAll(codes.map((e) => ''));
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  void _scanDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      debugPrint('RESULT: $value');
      if (_scannedCodes.contains(value)) {
        return;
      }

      debugPrint('${_importedCodes.contains(value)}');
      if (_importedCodes.contains(value)) {
        _assetsAudioPlayer.open(
          Audio('assets/audios/oke.mp3'),
        );
        final index = _importedCodes.indexOf(value!);
        setState(() {
          _scannedCodes[index] = value;
        });
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data Import : ${_importedCodes.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
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
                        fontSize: 20,
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
                          vertical: 4,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 32,
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
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 32,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  if (_showScanner)
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 80),
                              bottom: BorderSide(width: 80),
                            ),
                          ),
                          child: MobileScanner(
                            controller: _mobileScannerController,
                            fit: BoxFit.fitWidth,
                            onDetect: _scanDetected,
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: IconButton(
                            onPressed: () async {
                              await _mobileScannerController?.toggleTorch();
                              setState(() {
                                _enableTorch = !_enableTorch;
                              });
                            },
                            icon: Icon(
                              _enableTorch ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  AppButton(
                    icon: _showScanner
                        ? Icons.cancel_outlined
                        : Icons.document_scanner_outlined,
                    text: _showScanner ? 'Stop' : 'Scan',
                    onPressed: () {
                      setState(() {
                        _showScanner = !_showScanner;
                        if (_showScanner) {
                          _mobileScannerController = MobileScannerController();
                        }
                      });
                    },
                  ),
                  if (_scannedCodes.where((e) => e.isNotEmpty).length ==
                      _importedCodes.length) ...[
                    const SizedBox(height: 16),
                    AppButton(
                      icon: Icons.upload,
                      text: 'Export',
                      onPressed: _saveFile,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/colors.dart';
import '../../services/qr_service.dart';
import '../../services/record_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late AnimationController _laserAnimationController;

  bool _isProcessing = false;
  bool _torchEnabled = false;

  final TextEditingController _manualTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _laserAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserAnimationController.dispose();
    _scannerController.dispose();
    _manualTokenController.dispose();
    super.dispose();
  }

  Future<void> _showResultDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(
          isSuccess ? LucideIcons.checkCircle : LucideIcons.alertCircle,
          size: 44,
          color: isSuccess ? AppColors.success : AppColors.danger,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final token = barcode.rawValue?.trim();

    if (token == null || token.isEmpty) return;

    await _processQrToken(token);
  }

  Future<void> _processQrToken(String token) async {
    if (_isProcessing || token.trim().isEmpty) return;

    final qrService = context.read<QrService>();
    final recordService = context.read<RecordService>();
    final router = GoRouter.of(context);

    setState(() => _isProcessing = true);

    try {
      await _scannerController.stop();

      final record = await qrService.resolveQrToken(token);

      if (!mounted) return;

      if (record != null) {
        // Refresh the patient's medical records.
        await recordService.fetchMyRecords();

        if (!mounted) return;

        await _showResultDialog(
          title: 'Record Retrieved',
          message:
              'The medical record was successfully verified and retrieved. You can now view its details.',
          isSuccess: true,
        );

        if (!mounted) return;

        // Navigate using the Firestore document ID.
        router.push('/records/${record.id}');
      } else {
        await _showResultDialog(
          title: 'Record Retrieval Failed',
          message:
              qrService.errorMessage ??
              'The QR code could not be matched to an accessible medical record. Please check the code and try again.',
          isSuccess: false,
        );

        if (!mounted) return;

        setState(() => _isProcessing = false);

        await _scannerController.start();
      }
    } catch (e) {
      if (!mounted) return;

      await _showResultDialog(
        title: 'Scanning Error',
        message:
            'Something went wrong while retrieving the medical record. Please try again.\n\n$e',
        isSuccess: false,
      );

      if (!mounted) return;

      setState(() => _isProcessing = false);

      try {
        await _scannerController.start();
      } catch (_) {
        // Camera may no longer be available.
      }
    }
  }

  void _showManualTokenDialog() {
    _manualTokenController.clear();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Enter Medical Record ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If your camera is unavailable, enter the medical record ID shown with the provider-generated QR code.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualTokenController,
              decoration: const InputDecoration(
                hintText: 'Enter record ID...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final recordId = _manualTokenController.text.trim();

              if (recordId.isEmpty) return;

              Navigator.pop(dialogContext);
              _processQrToken(recordId);
            },
            child: const Text('Retrieve Record'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.72;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scan Provider QR Code'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.flashlight,
              color: _torchEnabled ? Colors.amber : Colors.white,
            ),
            onPressed: () async {
              await _scannerController.toggleTorch();

              if (!mounted) return;

              setState(() {
                _torchEnabled = !_torchEnabled;
              });
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.keyboard, color: Colors.white),
            tooltip: 'Manual Entry',
            onPressed: _showManualTokenDialog,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcodeDetected,
            errorBuilder: (context, error) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.cameraOff,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Camera Unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Camera permission not granted or device has no camera available. You can enter the record ID manually.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        onPressed: _showManualTokenDialog,
                        icon: const Icon(LucideIcons.keyboard, size: 18),
                        label: const Text('Enter Record ID'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Dark overlay with transparent scanning area.
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.65),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: scanAreaSize,
                    width: scanAreaSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scanning frame and animated laser.
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: scanAreaSize,
              height: scanAreaSize,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent, width: 2.5),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _laserAnimationController,
                    builder: (context, child) {
                      return Positioned(
                        top:
                            _laserAnimationController.value *
                                (scanAreaSize - 20) +
                            10,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.9),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction card.
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Align QR code within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'The QR code contains a record ID only. Your medical information is retrieved securely after authentication.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 16),
                    Text(
                      'Retrieving Health Record...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

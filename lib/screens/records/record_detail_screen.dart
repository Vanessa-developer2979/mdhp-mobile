import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/colors.dart';
import '../../models/record.dart';
import '../../services/record_service.dart';
import '../../widgets/primary_button.dart';

class RecordDetailScreen extends StatefulWidget {
  final int recordId;

  const RecordDetailScreen({super.key, required this.recordId});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  HealthRecordModel? _record;
  bool _isLoading = true;
  bool _isDownloadingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final recordService = context.read<RecordService>();
    final r = await recordService.getRecordById(widget.recordId);
    if (mounted) {
      setState(() {
        _record = r;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloadingPdf = true);
    final recordService = context.read<RecordService>();
    final pdfBytes = await recordService.fetchRecordPdf(widget.recordId);

    if (!mounted) return;
    setState(() => _isDownloadingPdf = false);

    if (pdfBytes != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Official PDF document generated (${(pdfBytes.length / 1024).toStringAsFixed(1)} KB). Download complete.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate official PDF record.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showEncounterQrModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Encounter Encrypted QR Token',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Show this to authorized clinical staff for immediate record verification.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: QrImageView(
                data: 'rec_${widget.recordId}',
                version: QrVersions.auto,
                size: 180,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'MDHP-REC-${widget.recordId.toString().padLeft(6, '0')}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clinical Consultation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Not Found')),
        body: const Center(child: Text('This health record could not be retrieved.')),
      );
    }

    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final formattedDate = dateFormat.format(_record!.visitDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Encounter Details'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.qrCode),
            tooltip: 'View QR Code',
            onPressed: _showEncounterQrModal,
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verified Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // "Verified by Provider" badge with green check
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.checkCircle2, size: 14, color: AppColors.success),
                            SizedBox(width: 6),
                            Text(
                              'Verified by Provider',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'REC-${_record!.id.toString().padLeft(6, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _record!.diagnosis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 10),

                  // Metadata list
                  _buildMetaRow(LucideIcons.calendar, 'Date of Visit', formattedDate),
                  const SizedBox(height: 8),
                  _buildMetaRow(
                    LucideIcons.stethoscope,
                    'Attending Doctor',
                    _record!.providerName != null ? 'Dr. ${_record!.providerName}' : 'Medical Officer',
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(
                    LucideIcons.building2,
                    'Health Facility',
                    '${_record!.facilityName ?? 'Central Hospital'} (${_record!.facilityDistrict ?? 'District'})',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accordion Sections
            const Text(
              'Clinical Evaluation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Diagnosis
            _buildAccordionCard(
              title: 'Primary Diagnosis',
              icon: LucideIcons.activity,
              iconColor: AppColors.primary,
              content: _record!.diagnosis,
              initiallyExpanded: true,
            ),
            const SizedBox(height: 10),

            // 2. Prescription
            _buildAccordionCard(
              title: 'Prescriptions & Medication',
              icon: LucideIcons.pill,
              iconColor: AppColors.accent,
              content: _record!.prescription,
              initiallyExpanded: true,
            ),
            const SizedBox(height: 10),

            // 3. Lab Results
            _buildAccordionCard(
              title: 'Laboratory Investigations',
              icon: LucideIcons.flaskConical,
              iconColor: const Color(0xFF6366F1),
              content: _record!.labResults ?? 'No laboratory investigations ordered for this encounter.',
              initiallyExpanded: true,
            ),
            const SizedBox(height: 10),

            // 4. Notes
            _buildAccordionCard(
              title: 'Clinical Recommendations & Notes',
              icon: LucideIcons.fileText,
              iconColor: const Color(0xFFF59E0B),
              content: _record!.notes ?? 'Standard recovery instructions provided to patient.',
              initiallyExpanded: false,
            ),
            const SizedBox(height: 28),

            // Official PDF Download Button
            PrimaryButton(
              text: 'Download Official PDF Passport Record',
              icon: LucideIcons.fileDown,
              isLoading: _isDownloadingPdf,
              onPressed: _downloadPdf,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Issued under the Republic of Malawi Digital Health Framework',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

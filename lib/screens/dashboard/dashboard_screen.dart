import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/record_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/record_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordService>().fetchMyRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final recordService = context.watch<RecordService>();
    final user = auth.currentUser;
    final firstName = user != null ? user.fullName.split(' ').first : 'Citizen';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: const Center(
                child: Icon(LucideIcons.shieldCheck, size: 20, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Malawi Digital Health Passport',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.accentLight,
                  ),
                ),
                Text(
                  'Welcome, $firstName',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.white),
            onPressed: () => context.push('/alerts'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => recordService.fetchMyRecords(),
        color: AppColors.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-width TEAL "Scan Provider QR Code" card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.accent,
                      Color(0xFF236C6A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.qrCode,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan Provider QR Code',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Scan QR code provided by your doctor',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.accentDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        icon: const Icon(LucideIcons.camera, size: 18, color: AppColors.accentDark),
                        label: const Text(
                          'Launch Scanner',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentDark,
                          ),
                        ),
                        onPressed: () => context.push('/scan'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2x2 Grid of features
              const Text(
                'Services & Access',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  StatCard(
                    title: 'Citizen Identity',
                    value: 'My Profile',
                    icon: LucideIcons.userCheck,
                    iconColor: AppColors.primary,
                    iconBackground: AppColors.primary.withValues(alpha: 0.1),
                    onTap: () => context.push('/profile'),
                  ),
                  StatCard(
                    title: '${recordService.records.length} Recorded',
                    value: 'My Health Records',
                    icon: LucideIcons.fileText,
                    iconColor: AppColors.accent,
                    iconBackground: AppColors.accentLight,
                    onTap: () => context.push('/records'),
                  ),
                  StatCard(
                    title: 'Preferences & PIN',
                    value: 'Settings',
                    icon: LucideIcons.settings,
                    iconColor: const Color(0xFF6366F1),
                    iconBackground: const Color(0xFFEEF2FF),
                    onTap: () => context.push('/settings'),
                  ),
                  StatCard(
                    title: 'Notifications',
                    value: '0 New Alerts',
                    icon: LucideIcons.bellRing,
                    iconColor: const Color(0xFFF59E0B),
                    iconBackground: const Color(0xFFFEF3C7),
                    onTap: () => context.push('/alerts'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Health Records Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Recent Health Records',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (recordService.isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ] else if (recordService.records.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(LucideIcons.clipboardList, size: 40, color: AppColors.textMuted),
                      SizedBox(height: 10),
                      Text(
                        'No Consultation Records Yet',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your digital passport records will appear here after visiting a clinic.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                for (final record in recordService.records.take(3))
                  RecordCard(
                    record: record,
                    onTap: () => context.push('/records/${record.id}'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

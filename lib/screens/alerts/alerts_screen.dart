import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'title': 'National Immunization Campaign',
        'category': 'MOH Advisory',
        'date': 'Nov 05, 2026',
        'body': 'Routine childhood immunization and booster administration is ongoing at all district health centres and Christian Health Association of Malawi (CHAM) facilities.',
        'icon': LucideIcons.shieldCheck,
        'color': AppColors.accent,
      },
      {
        'title': 'Seasonal Malaria Prevention Program',
        'category': 'Prevention Notice',
        'date': 'Nov 01, 2026',
        'body': 'Free long-lasting insecticidal net (LLIN) distributions and indoor residual spraying scheduled across Lilongwe and Blantyre districts.',
        'icon': LucideIcons.alertTriangle,
        'color': AppColors.warning,
      },
      {
        'title': 'Digital Health Passport Verified',
        'category': 'Account Security',
        'date': 'Oct 28, 2026',
        'body': 'Your National Registration Bureau (NRB) identity verification is complete. Consultation records are cryptographically secured.',
        'icon': LucideIcons.checkCircle2,
        'color': AppColors.success,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Alerts & Notices'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final item = alerts[index];
          final color = item['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['category'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          Text(
                            item['date'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['body'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

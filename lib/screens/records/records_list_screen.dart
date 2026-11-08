import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/colors.dart';
import '../../services/record_service.dart';
import '../../models/record.dart';
import '../../widgets/record_card.dart';
import '../../widgets/empty_state.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordService>().fetchMyRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HealthRecordModel> _getFilteredRecords(List<HealthRecordModel> records) {
    if (_searchQuery.isEmpty) return records;
    final query = _searchQuery.toLowerCase();
    return records.where((r) {
      return r.diagnosis.toLowerCase().contains(query) ||
          (r.providerName?.toLowerCase().contains(query) ?? false) ||
          (r.facilityName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recordService = context.watch<RecordService>();
    final filtered = _getFilteredRecords(recordService.records);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Health Records'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => recordService.fetchMyRecords(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search diagnosis, doctor, or clinic...',
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Records List Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => recordService.fetchMyRecords(),
              color: AppColors.accent,
              child: recordService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? EmptyState(
                          icon: LucideIcons.fileX,
                          title: 'No Matching Records',
                          message: _searchQuery.isNotEmpty
                              ? 'No clinical records found matching "$_searchQuery".'
                              : 'No health records have been uploaded to your passport yet.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final record = filtered[index];
                            return RecordCard(
                              record: record,
                              onTap: () => context.push('/records/${record.id}'),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

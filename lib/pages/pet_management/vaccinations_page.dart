import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/pet_management/vaccination_model.dart';
import 'package:pet_owner_mobile/services/vaccination_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Vaccination_card.dart';

class VaccinationsScreen extends StatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  State<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  final VaccinationService _service = VaccinationService();
  late Future<List<VaccinationModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchOwnerVaccinations();
  }

  void _refresh() => setState(() {
        _future = _service.fetchOwnerVaccinations();
      });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          'Vaccinations',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<List<VaccinationModel>>(
        future: _future,
        builder: (context, snapshot) {
          // ── Loading ───────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ─────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: sw * 0.15, color: Colors.red.shade300),
                    SizedBox(height: sh * 0.02),
                    Text(
                      'Failed to load vaccinations.\nPlease try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: sw * 0.038, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: sh * 0.025),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final vaccinations = snapshot.data ?? [];

          // ── Empty ─────────────────────────────────────────────────────
          if (vaccinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vaccines_outlined,
                      size: sw * 0.18, color: Colors.grey.shade300),
                  SizedBox(height: sh * 0.02),
                  Text(
                    'No vaccination records',
                    style: TextStyle(
                      fontSize: sw * 0.042,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    'Your pets\' vaccination history will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: sw * 0.033, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          // ── Group by status ───────────────────────────────────────────
          final overdue = vaccinations
              .where((v) => v.status.toLowerCase() == 'overdue')
              .toList();
          final upcoming = vaccinations
              .where((v) => v.status.toLowerCase() == 'upcoming')
              .toList();
          final completed = vaccinations
              .where((v) => v.status.toLowerCase() == 'completed')
              .toList();
          final other = vaccinations
              .where((v) => !['overdue', 'upcoming', 'completed']
                  .contains(v.status.toLowerCase()))
              .toList();

          // Summary counts
          final overdueCount = overdue.length;
          final upcomingCount = upcoming.length;
          final completedCount = completed.length;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04, vertical: sh * 0.02),
              children: [
                // ── Summary banner ──────────────────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04, vertical: sh * 0.018),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkPink,
                        AppColors.darkPink.withOpacity(0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(sw * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPink.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        count: vaccinations.length,
                        label: 'Total',
                        icon: Icons.vaccines_outlined,
                        sw: sw,
                        sh: sh,
                      ),
                      _SummaryDivider(),
                      _SummaryItem(
                        count: upcomingCount,
                        label: 'Upcoming',
                        icon: Icons.schedule_rounded,
                        sw: sw,
                        sh: sh,
                      ),
                      _SummaryDivider(),
                      _SummaryItem(
                        count: overdueCount,
                        label: 'Overdue',
                        icon: Icons.error_outline_rounded,
                        sw: sw,
                        sh: sh,
                        highlight: overdueCount > 0,
                      ),
                      _SummaryDivider(),
                      _SummaryItem(
                        count: completedCount,
                        label: 'Done',
                        icon: Icons.check_circle_outline_rounded,
                        sw: sw,
                        sh: sh,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.024),

                // Overdue first (most urgent)
                if (overdue.isNotEmpty) ...[
                  _GroupHeader(
                      title: 'Overdue',
                      color: const Color(0xFFC62828),
                      icon: Icons.error_outline_rounded,
                      sw: sw),
                  SizedBox(height: sh * 0.01),
                  ...overdue.map((v) => Padding(
                        padding: EdgeInsets.only(bottom: sh * 0.014),
                        child: VaccinationCard(vaccination: v),
                      )),
                ],

                if (upcoming.isNotEmpty) ...[
                  if (overdue.isNotEmpty) SizedBox(height: sh * 0.008),
                  _GroupHeader(
                      title: 'Upcoming',
                      color: const Color(0xFF1565C0),
                      icon: Icons.schedule_rounded,
                      sw: sw),
                  SizedBox(height: sh * 0.01),
                  ...upcoming.map((v) => Padding(
                        padding: EdgeInsets.only(bottom: sh * 0.014),
                        child: VaccinationCard(vaccination: v),
                      )),
                ],

                if (other.isNotEmpty) ...[
                  SizedBox(height: sh * 0.008),
                  _GroupHeader(
                      title: 'Other',
                      color: Colors.grey.shade600,
                      icon: Icons.info_outline_rounded,
                      sw: sw),
                  SizedBox(height: sh * 0.01),
                  ...other.map((v) => Padding(
                        padding: EdgeInsets.only(bottom: sh * 0.014),
                        child: VaccinationCard(vaccination: v),
                      )),
                ],

                if (completed.isNotEmpty) ...[
                  if (overdue.isNotEmpty ||
                      upcoming.isNotEmpty ||
                      other.isNotEmpty)
                    SizedBox(height: sh * 0.008),
                  _GroupHeader(
                      title: 'Completed',
                      color: const Color(0xFF2E7D32),
                      icon: Icons.check_circle_outline_rounded,
                      sw: sw),
                  SizedBox(height: sh * 0.01),
                  ...completed.map((v) => Padding(
                        padding: EdgeInsets.only(bottom: sh * 0.014),
                        child: VaccinationCard(vaccination: v),
                      )),
                ],

                SizedBox(height: sh * 0.01),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Summary banner helpers ────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final double sw, sh;
  final bool highlight;

  const _SummaryItem({
    required this.count,
    required this.label,
    required this.icon,
    required this.sw,
    required this.sh,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: highlight
                ? const Color(0xFFFFCDD2)
                : Colors.white.withOpacity(0.85),
            size: sw * 0.05),
        SizedBox(height: sh * 0.004),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: sw * 0.046,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: sw * 0.026,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: Colors.white.withOpacity(0.25),
      );
}

// ── Group header ──────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final double sw;

  const _GroupHeader({
    required this.title,
    required this.color,
    required this.icon,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: sw * 0.038, color: color),
        SizedBox(width: sw * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}


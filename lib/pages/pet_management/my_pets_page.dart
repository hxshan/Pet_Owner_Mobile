import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/store/pet_scope.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/pet_card_widget.dart';
import 'package:pet_owner_mobile/widgets/pet_updates_card_widget.dart';

// ── Local event model ────────────────────────────────────────────────────────

class _PetEvent {
  final String message;
  final String type; // 'appointment' | 'vaccination_due' | 'vaccination_overdue'
  final DateTime date;
  final String petId;

  const _PetEvent({
    required this.message,
    required this.type,
    required this.date,
    required this.petId,
  });

  factory _PetEvent.fromJson(Map<String, dynamic> json) => _PetEvent(
        message: (json['message'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        date: DateTime.tryParse((json['date'] ?? '').toString())?.toLocal() ??
            DateTime.now(),
        petId: (json['petId'] ?? '').toString(),
      );

  bool get isOverdue => type == 'vaccination_overdue';

  int get _daysUntil => date.difference(DateTime.now()).inDays;

  /// Critical = overdue OR vaccination due within 3 days
  bool get isCritical {
    if (isOverdue) return true;
    if (type == 'vaccination_due') return _daysUntil <= 3;
    return false;
  }

  bool get isAppointment => type == 'appointment';

  String get label {
    if (isOverdue) return 'OVERDUE';
    if (type == 'vaccination_due') {
      final d = _daysUntil;
      if (d <= 0) return 'DUE TODAY';
      if (d <= 3) return 'DUE SOON';
      if (d <= 7) return 'Due Soon';
      return 'Upcoming';
    }
    if (isAppointment) return 'Appointment';
    return 'Reminder';
  }

  // ── Colours ───────────────────────────────────────────────────────────────

  Color get accentColor {
    if (isOverdue) return AppColors.errorMessage;
    if (type == 'vaccination_due') {
      final d = _daysUntil;
      if (d <= 3) return AppColors.errorMessage;
      if (d <= 7) return const Color(0xFFE65100); // deep-orange
      return const Color(0xFF2E7D32); // green
    }
    if (isAppointment) return const Color(0xFF1565C0); // blue
    return Colors.grey.shade700;
  }

  Color get backgroundColor {
    if (isOverdue) return AppColors.errorMessage.withOpacity(0.08);
    if (type == 'vaccination_due') {
      final d = _daysUntil;
      if (d <= 3) return AppColors.errorMessage.withOpacity(0.08);
      if (d <= 7) return const Color(0xFFFFF3E0); // orange tint
      return const Color(0xFFE8F5E9); // green tint
    }
    if (isAppointment) return const Color(0xFFE3F2FD); // blue tint
    return Colors.grey.shade100;
  }

  IconData get icon {
    if (isOverdue) return Icons.warning_amber_rounded;
    if (type == 'vaccination_due') {
      if (_daysUntil <= 3) return Icons.warning_amber_rounded;
      return Icons.vaccines_outlined;
    }
    if (isAppointment) return Icons.calendar_today_outlined;
    return Icons.notifications_outlined;
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({Key? key}) : super(key: key);

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final _petService = PetService();

  List<_PetEvent> _events = [];
  bool _eventsLoading = true;
  bool _eventsError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PetScope.of(context).loadOnce();
        _loadEvents();
      }
    });
  }

  Future<void> _loadEvents() async {
    setState(() {
      _eventsLoading = true;
      _eventsError = false;
    });
    try {
      final raw = await _petService.getUpcomingEvents();
      if (!mounted) return;
      setState(() {
        _events = raw.map((e) => _PetEvent.fromJson(e)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
      });
    } catch (_) {
      if (mounted) setState(() => _eventsError = true);
    } finally {
      if (mounted) setState(() => _eventsLoading = false);
    }
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _handleEventTap(_PetEvent event) {
    if (event.isAppointment) {
      context.pushNamed('UpcomingAppointmentsScreen');
    } else {
      // vaccination_due / vaccination_overdue → pet profile
      context.pushNamed(
        'PetProfileScreen',
        pathParameters: {'petId': event.petId},
      );
    }
  }

  // ── Date formatter ────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final store = PetScope.of(context);
    final isLoading = store.isLoading || !store.isLoaded;
    final pets = store.pets.length > 2 ? store.pets.sublist(0, 2) : store.pets;
    final hasMore = store.pets.length > 2;

    // Split events into the two display buckets
    final important =
        _events.where((e) => e.isCritical).toList();
    final upcoming =
        _events.where((e) => !e.isCritical).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            PetScope.of(context).refresh();
            await _loadEvents();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05,
                vertical: sh * 0.01,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Pets',
                        style: TextStyle(
                          fontSize: sw * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await context.pushNamed('AddPetScreen');
                          if (mounted) PetScope.of(context).refresh();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04,
                            vertical: sh * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.black87, width: 1.2),
                            borderRadius:
                                BorderRadius.circular(sw * 0.02),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add,
                                  color: Colors.black87,
                                  size: sw * 0.045),
                              SizedBox(width: sw * 0.01),
                              Text(
                                'New Pet',
                                style: TextStyle(
                                  fontSize: sw * 0.032,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sh * 0.025),

                  // ── Pet Cards ─────────────────────────────────────────
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (store.pets.isEmpty)
                    Center(
                      child: Text(
                        'No pets yet. Add your first pet!',
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          color: Colors.black45,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pets.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: sh * 0.02),
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return PetCard(
                          sw: sw,
                          sh: sh,
                          pet: pet,
                          onDeleted: () => PetScope.of(context).refresh(),
                        );
                      },
                    ),

                  // ── View All ──────────────────────────────────────────
                  if (hasMore) ...[
                    SizedBox(height: sh * 0.02),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            context.pushNamed('ViewAllPetsScreen'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.darkPink,
                          textStyle: TextStyle(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('View All Pets'),
                      ),
                    ),
                  ],

                  SizedBox(height: sh * 0.03),

                  // ── Important Updates ─────────────────────────────────
                  if (_eventsLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_eventsError)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: sw * 0.12, color: Colors.red.shade300),
                            SizedBox(height: sh * 0.012),
                            Text(
                              'Failed to load reminders.',
                              style: TextStyle(
                                  fontSize: sw * 0.036,
                                  color: Colors.grey.shade600),
                            ),
                            SizedBox(height: sh * 0.012),
                            ElevatedButton.icon(
                              onPressed: _loadEvents,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkPink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.03),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    if (important.isNotEmpty) ...[
                      Text(
                        'Important Updates',
                        style: TextStyle(
                          fontSize: sw * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: sh * 0.015),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: important.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: sh * 0.015),
                        itemBuilder: (_, i) =>
                            _buildEventCard(important[i], sw, sh),
                      ),
                      SizedBox(height: sh * 0.03),
                    ],

                    // ── Upcoming Reminders ────────────────────────────
                    if (upcoming.isNotEmpty) ...[
                      Text(
                        'Upcoming Reminders',
                        style: TextStyle(
                          fontSize: sw * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: sh * 0.015),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: upcoming.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: sh * 0.015),
                        itemBuilder: (_, i) =>
                            _buildEventCard(upcoming[i], sw, sh),
                      ),
                      SizedBox(height: sh * 0.03),
                    ],

                    // Empty state — only shown when loaded and truly empty
                    if (important.isEmpty && upcoming.isEmpty) ...[
                      Text(
                        'Upcoming Reminders',
                        style: TextStyle(
                          fontSize: sw * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: sh * 0.015),
                      Container(
                        padding: EdgeInsets.all(sw * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(sw * 0.03),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green.shade400,
                                size: sw * 0.06),
                            SizedBox(width: sw * 0.03),
                            Text(
                              'All caught up! No pending reminders.',
                              style: TextStyle(
                                fontSize: sw * 0.034,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sh * 0.03),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(_PetEvent event, double sw, double sh) {
    return UpdateCard(
      sw: sw,
      sh: sh,
      backgroundColor: event.backgroundColor,
      borderColor: event.accentColor,
      titleColor: event.accentColor,
      title: event.label,
      date: _formatDate(event.date),
      description: event.message,
      icon: event.icon,
      onTap: () => _handleEventTap(event),
    );
  }
}


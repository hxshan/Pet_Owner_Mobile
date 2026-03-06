import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/services/adoption_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({Key? key}) : super(key: key);

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  final AdoptionService _service = AdoptionService();
  List<AdoptionApplication> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final apps = await _service.getMyApplications();
      setState(() => _applications = apps);
    } catch (e) {
      final msg = e.toString().contains('401') ||
              e.toString().toLowerCase().contains('unauthorized')
          ? 'Please log in to view your applications.'
          : 'Failed to load applications. Pull to refresh.';
      setState(() => _errorMessage = msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _withdraw(AdoptionApplication app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: Text(
          'Are you sure you want to withdraw your application for ${app.petName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Withdraw',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.withdrawApplication(app.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application withdrawn successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadApplications(); // Refresh list
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to withdraw. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'My Applications',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.darkPink))
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
              color: AppColors.darkPink,
              onRefresh: _loadApplications,
              child: _applications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _applications.length,
                      itemBuilder: (context, index) {
                        return _buildApplicationCard(_applications[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildApplicationCard(AdoptionApplication app) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet photo
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: app.petPhoto != null && app.petPhoto!.isNotEmpty
                  ? Image.network(
                      app.petPhoto!,
                      width: 65.w,
                      height: 65.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _photoFallback(),
                    )
                  : _photoFallback(),
            ),
            SizedBox(width: 12.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.petName.isNotEmpty ? app.petName : 'Pet',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Applied ${DateFormat('dd MMM yyyy').format(app.createdAt)}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
                  _StatusBadge(status: app.status),
                ],
              ),
            ),

            // Withdraw button for pending apps
            if (app.status == 'Pending')
              TextButton(
                onPressed: () => _withdraw(app),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                ),
                child: Text(
                  'Withdraw',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _photoFallback() {
    return Container(
      width: 65.w,
      height: 65.w,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.pets, color: AppColors.darkPink, size: 28.sp),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 70.sp, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text(
                'No applications yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
              SizedBox(height: 6.h),
              Text(
                'Browse pets and apply for adoption',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _loadApplications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case 'Approved':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;
      case 'Rejected':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        break;
      case 'Under Review':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        icon = Icons.hourglass_top_outlined;
        break;
      case 'Withdrawn':
      case 'Cancelled':
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        icon = Icons.remove_circle_outline;
        break;
      default: // Pending
        bg = AppColors.mainColor.withOpacity(0.2);
        fg = AppColors.darkPink;
        icon = Icons.pending_outlined;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: fg),
          SizedBox(width: 4.w),
          Text(
            status,
            style: TextStyle(
              fontSize: 12.sp,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

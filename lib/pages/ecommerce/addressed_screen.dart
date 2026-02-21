import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> addresses = [
    {
      'label': 'Home',
      'icon': Icons.home_outlined,
      'name': 'John Doe',
      'address': '42 Maple Street, Apt 3B',
      'city': 'New York, NY 10001',
      'phone': '+1 (555) 123-4567',
    },
    {
      'label': 'Work',
      'icon': Icons.business_outlined,
      'name': 'John Doe',
      'address': '350 Fifth Avenue, Floor 12',
      'city': 'New York, NY 10118',
      'phone': '+1 (555) 987-6543',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          'My Addresses',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: sw * 0.045,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: addresses.length,
                separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
                itemBuilder: (context, index) {
                  return _buildAddressCard(addresses[index], index, sw, sh);
                },
              ),
            ),
            SizedBox(height: sh * 0.02),
            _buildAddNewButton(sw, sh),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    Map<String, dynamic> addr,
    int index,
    double sw,
    double sh,
  ) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkPink.withOpacity(0.05)
              : AppColors.lightGray,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(
            color: isSelected ? AppColors.darkPink : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.all(sw * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  addr['icon'] as IconData,
                  color: isSelected ? AppColors.darkPink : Colors.black54,
                  size: sw * 0.05,
                ),
                SizedBox(width: sw * 0.02),
                Text(
                  addr['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: sw * 0.038,
                    color: isSelected ? AppColors.darkPink : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.darkPink,
                    size: sw * 0.05,
                  ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: sw * 0.045,
                    color: Colors.black38,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Divider(height: sh * 0.025, color: Colors.black12),
            Text(
              addr['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: sw * 0.035,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.005),
            Text(
              addr['address'] as String,
              style: TextStyle(color: Colors.black54, fontSize: sw * 0.033),
            ),
            Text(
              addr['city'] as String,
              style: TextStyle(color: Colors.black54, fontSize: sw * 0.033),
            ),
            SizedBox(height: sh * 0.005),
            Text(
              addr['phone'] as String,
              style: TextStyle(color: Colors.black38, fontSize: sw * 0.03),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewButton(double sw, double sh) {
    return GestureDetector(
      onTap: () {
        // navigate to add address form
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: sh * 0.02),
        decoration: BoxDecoration(
          color: AppColors.darkPink,
          borderRadius: BorderRadius.circular(sw * 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: sw * 0.05),
            SizedBox(width: sw * 0.02),
            Text(
              'Add New Address',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: sw * 0.038,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/ecommerce/address_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _service = EcommerceService();

  List<Address> _addresses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _service.listMyAddressModels();
      if (!mounted) return;
      setState(() {
        _addresses = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _setDefault(Address addr) async {
    try {
      await _service.setDefaultAddress(id: addr.id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to set default: $e')));
    }
  }

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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: sw * 0.035,
                      ),
                    ),
                    SizedBox(height: sh * 0.02),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: _addresses.isEmpty
                        ? _buildEmpty(sw, sh)
                        : ListView.separated(
                            itemCount: _addresses.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: sh * 0.015),
                            itemBuilder: (context, index) {
                              final addr = _addresses[index];
                              return _buildAddressCard(addr, sw, sh);
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

  Widget _buildEmpty(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: sw * 0.18,
            color: Colors.black26,
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No addresses yet',
            style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            'Add an address to checkout faster.',
            style: TextStyle(fontSize: sw * 0.034, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address addr, double sw, double sh) {
    final isSelected = addr.isDefault == true;

    final icon = (addr.label ?? 'HOME').toUpperCase() == 'WORK'
        ? Icons.business_outlined
        : Icons.home_outlined;

    return GestureDetector(
      onTap: () => _setDefault(addr),
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
                  icon,
                  color: isSelected ? AppColors.darkPink : Colors.black54,
                  size: sw * 0.05,
                ),
                SizedBox(width: sw * 0.02),
                Text(
                  (addr.label ?? 'HOME').toUpperCase(),
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
                  onPressed: () async {
                    final changed = await context.pushNamed(
                      'EditAddressScreen',
                      extra: addr,
                    );
                    if (changed == true) _load();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Divider(height: sh * 0.025, color: Colors.black12),
            Text(
              addr.name ?? '-',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: sw * 0.035,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.005),
            Text(
              addr.addressLine1 ?? '-',
              style: TextStyle(color: Colors.black54, fontSize: sw * 0.033),
            ),
            if ((addr.addressLine2 ?? '').trim().isNotEmpty)
              Text(
                addr.addressLine2!,
                style: TextStyle(color: Colors.black54, fontSize: sw * 0.033),
              ),
            Text(
              '${addr.city ?? ''}${(addr.postalCode ?? '').isNotEmpty ? ', ${addr.postalCode}' : ''}',
              style: TextStyle(color: Colors.black54, fontSize: sw * 0.033),
            ),
            SizedBox(height: sh * 0.005),
            Text(
              addr.phone ?? '-',
              style: TextStyle(color: Colors.black38, fontSize: sw * 0.03),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewButton(double sw, double sh) {
    return GestureDetector(
      onTap: () async {
        final changed = await context.pushNamed('AddAddressScreen');
        if (changed == true) _load();
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

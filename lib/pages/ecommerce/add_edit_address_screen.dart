import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/ecommerce/address_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? initial; 

  const AddEditAddressScreen({Key? key, this.initial}) : super(key: key);

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _service = EcommerceService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _label;
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _district;
  late final TextEditingController _province;
  late final TextEditingController _country;
  late final TextEditingController _postal;

  bool _makeDefault = false;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;

    _label = TextEditingController(text: a?.label ?? 'HOME');
    _name = TextEditingController(text: a?.name ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _line1 = TextEditingController(text: a?.addressLine1 ?? '');
    _line2 = TextEditingController(text: a?.addressLine2 ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _district = TextEditingController(text: a?.district ?? '');
    _province = TextEditingController(text: a?.province ?? '');
    _country = TextEditingController(text: a?.country ?? 'Sri Lanka');
    _postal = TextEditingController(text: a?.postalCode ?? '');

    _makeDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _label.dispose();
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _district.dispose();
    _province.dispose();
    _country.dispose();
    _postal.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final addr = Address(
        id: widget.initial?.id ?? '',
        label: _label.text.trim(),
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        addressLine1: _line1.text.trim(),
        addressLine2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
        city: _city.text.trim(),
        district: _district.text.trim(),
        province: _province.text.trim(),
        country: _country.text.trim(),
        postalCode: _postal.text.trim().isEmpty ? null : _postal.text.trim(),
        isDefault: _makeDefault,
      );

      if (_isEdit) {
        await _service.updateAddress(id: widget.initial!.id, address: addr);
      } else {
        await _service.createAddress(addr);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save address: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
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
          _isEdit ? 'Edit Address' : 'Add Address',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: sw * 0.045,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black38, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sh * 0.005),

                // Label picker 
                _buildSectionHeader('Address Label', sw),
                SizedBox(height: sh * 0.012),
                _buildLabelPicker(sw),
                SizedBox(height: sh * 0.025),

                //  Contact info 
                _buildSectionHeader('Contact Information', sw),
                SizedBox(height: sh * 0.012),
                _field(
                  sw,
                  controller: _name,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validatorMsg: 'Name is required',
                ),
                SizedBox(height: sh * 0.012),
                _field(
                  sw,
                  controller: _phone,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validatorMsg: 'Phone is required',
                ),
                SizedBox(height: sh * 0.025),

                //  Address details ─
                _buildSectionHeader('Address Details', sw),
                SizedBox(height: sh * 0.012),
                _field(
                  sw,
                  controller: _line1,
                  label: 'Address Line 1',
                  icon: Icons.location_on_outlined,
                  validatorMsg: 'Address Line 1 is required',
                ),
                SizedBox(height: sh * 0.012),
                _field(
                  sw,
                  controller: _line2,
                  label: 'Address Line 2 (optional)',
                  icon: Icons.add_location_alt_outlined,
                ),
                SizedBox(height: sh * 0.012),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        sw,
                        controller: _city,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                        validatorMsg: 'Required',
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: _field(
                        sw,
                        controller: _postal,
                        label: 'Postal Code',
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.012),
                _field(
                  sw,
                  controller: _district,
                  label: 'District',
                  icon: Icons.map_outlined,
                  validatorMsg: 'District is required',
                ),
                SizedBox(height: sh * 0.012),
                _field(
                  sw,
                  controller: _province,
                  label: 'Province',
                  icon: Icons.terrain_outlined,
                  validatorMsg: 'Province is required',
                ),
                SizedBox(height: sh * 0.012),
                _field(
                  sw,
                  controller: _country,
                  label: 'Country',
                  icon: Icons.flag_outlined,
                  validatorMsg: 'Country is required',
                ),
                SizedBox(height: sh * 0.02),

                //  Default toggle 
                Container(
                  decoration: BoxDecoration(
                    color: _makeDefault
                        ? AppColors.darkPink.withOpacity(0.06)
                        : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(sw * 0.035),
                    border: Border.all(
                      color: _makeDefault
                          ? AppColors.darkPink.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: SwitchListTile(
                    value: _makeDefault,
                    onChanged: (v) => setState(() => _makeDefault = v),
                    activeColor: AppColors.darkPink,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04,
                      vertical: sh * 0.004,
                    ),
                    title: Text(
                      'Set as default address',
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w600,
                        color: _makeDefault
                            ? AppColors.darkPink
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Used automatically at checkout',
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.03),

                //  Submit button ─
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPink,
                      disabledBackgroundColor:
                          AppColors.darkPink.withOpacity(0.6),
                      padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.04),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEdit ? 'Update Address' : 'Save Address',
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Section header ─

  Widget _buildSectionHeader(String title, double sw) {
    return Text(
      title,
      style: TextStyle(
        fontSize: sw * 0.034,
        fontWeight: FontWeight.bold,
        color: Colors.black45,
        letterSpacing: 0.4,
      ),
    );
  }

  //  Label picker (chip row) 

  Widget _buildLabelPicker(double sw) {
    const options = <Map<String, dynamic>>[
      {'value': 'HOME', 'icon': Icons.home_outlined},
      {'value': 'WORK', 'icon': Icons.business_outlined},
      {'value': 'OTHER', 'icon': Icons.place_outlined},
    ];

    return Row(
      children: options.map((opt) {
        final value = opt['value'] as String;
        final icon = opt['icon'] as IconData;
        final isSelected =
            (_label.text.isEmpty ? 'HOME' : _label.text.toUpperCase()) == value;

        return Padding(
          padding: EdgeInsets.only(right: sw * 0.03),
          child: GestureDetector(
            onTap: () => setState(() => _label.text = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05,
                vertical: sw * 0.028,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.darkPink.withOpacity(0.08)
                    : const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(
                  color: isSelected
                      ? AppColors.darkPink
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: sw * 0.045,
                    color: isSelected ? AppColors.darkPink : Colors.black45,
                  ),
                  SizedBox(width: sw * 0.015),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: sw * 0.032,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.darkPink : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  //  Text field ─

  Widget _field(
    double sw, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMsg,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: sw * 0.035, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: sw * 0.033, color: Colors.black45),
        prefixIcon: Icon(icon, size: sw * 0.045, color: Colors.black38),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sw * 0.038,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: BorderSide(color: AppColors.darkPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validatorMsg == null
          ? null
          : (v) {
              if (v == null || v.trim().isEmpty) return validatorMsg;
              return null;
            },
    );
  }
}
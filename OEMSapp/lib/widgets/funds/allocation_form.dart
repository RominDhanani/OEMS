import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../premium/premium_dropdown.dart';
import '../premium/premium_button.dart';
import '../../core/utils/path_utils.dart';
import '../common/shake_widget.dart';

class AllocationForm extends ConsumerStatefulWidget {
  final List<UserModel> managers;
  final Function(Map<String, dynamic> data, String? filePath) onSubmit;
  final VoidCallback onCancel;
  final bool isLoading;
  final Map<String, dynamic>? initialData;

  const AllocationForm({
    super.key,
    required this.managers,
    required this.onSubmit,
    required this.onCancel,
    this.isLoading = false,
    this.initialData,
  });

  @override
  ConsumerState<AllocationForm> createState() => _AllocationFormState();
}

class _AllocationFormState extends ConsumerState<AllocationForm> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMode = 'CASH';
  int? _selectedManagerId;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _expansionId;
  
  // Cheque fields
  final _chequeNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  DateTime? _chequeDate;
  final _accountHolderController = TextEditingController();
  File? _chequeImage;
  
  // UPI fields
  final _upiIdController = TextEditingController();
  final _transactionIdController = TextEditingController();
  
  String? _existingImageUrl;
  String? _rawExistingImagePath; // NEW field to store relative path

  final _recipientShakeKey = GlobalKey<ShakeWidgetState>();
  final _amountShakeKey = GlobalKey<ShakeWidgetState>();
  final _chequeNumberShakeKey = GlobalKey<ShakeWidgetState>();
  final _bankNameShakeKey = GlobalKey<ShakeWidgetState>();
  final _accountHolderShakeKey = GlobalKey<ShakeWidgetState>();
  final _upiIdShakeKey = GlobalKey<ShakeWidgetState>();
  final _transactionIdShakeKey = GlobalKey<ShakeWidgetState>();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _paymentMode = widget.initialData!['payment_mode'] ?? 'CASH';
      _selectedManagerId = widget.initialData!['to_user_id'];
      _amountController.text = widget.initialData!['amount']?.toString() ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
      
      if (_paymentMode == 'CHEQUE') {
        _chequeNumberController.text = widget.initialData!['cheque_number'] ?? '';
        _bankNameController.text = widget.initialData!['bank_name'] ?? '';
        _accountHolderController.text = widget.initialData!['account_holder_name'] ?? '';
        if (widget.initialData!['cheque_date'] != null) {
          _chequeDate = DateTime.tryParse(widget.initialData!['cheque_date']);
        }
      } else if (_paymentMode == 'UPI') {
        _upiIdController.text = widget.initialData!['upi_id'] ?? '';
        _transactionIdController.text = widget.initialData!['transaction_id'] ?? '';
      }
      _expansionId = widget.initialData!['expansion_id'] is int 
          ? widget.initialData!['expansion_id'] 
          : int.tryParse(widget.initialData!['expansion_id']?.toString() ?? '');

      if (widget.initialData!['cheque_image_path'] != null) {
        _rawExistingImagePath = widget.initialData!['cheque_image_path'];
        _existingImageUrl = PathUtils.normalizeImageUrl(_rawExistingImagePath);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _chequeNumberController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _upiIdController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _chequeImage = File(image.path);
        _existingImageUrl = null;
        _rawExistingImagePath = null;
      });
    }
  }

  void _submit() {
    bool isValid = _formKey.currentState!.validate();
    
    if (_selectedManagerId == null) _recipientShakeKey.currentState?.shake();
    if (_amountController.text.isEmpty) _amountShakeKey.currentState?.shake();
    if (_paymentMode == 'CHEQUE') {
      if (_chequeNumberController.text.isEmpty) _chequeNumberShakeKey.currentState?.shake();
      if (_bankNameController.text.isEmpty) _bankNameShakeKey.currentState?.shake();
      if (_accountHolderController.text.isEmpty) _accountHolderShakeKey.currentState?.shake();
    } else if (_paymentMode == 'UPI') {
      if (_upiIdController.text.isEmpty) _upiIdShakeKey.currentState?.shake();
      if (_transactionIdController.text.isEmpty) _transactionIdShakeKey.currentState?.shake();
    }

    if (!isValid || _selectedManagerId == null) {
      if (_selectedManagerId == null) {
        ref.read(toastProvider.notifier).show(
          message: "Please select a recipient",
          type: ToastType.warning,
        );
      }
      return;
    }

    if (isValid) {
      final data = {
        'to_user_id': _selectedManagerId.toString(),
        'amount': _amountController.text,
        'description': _descriptionController.text,
        'payment_mode': _paymentMode,
      };

      if (_paymentMode == 'CHEQUE') {
        data['cheque_number'] = _chequeNumberController.text;
        data['bank_name'] = _bankNameController.text;
        data['cheque_date'] = _chequeDate?.toIso8601String().split('T')[0] ?? '';
        data['account_holder_name'] = _accountHolderController.text;
        
        // Pass existing image path if no new image picked
        if (_chequeImage == null && _rawExistingImagePath != null) {
          data['existing_cheque_image_path'] = _rawExistingImagePath!;
        }
      } else if (_paymentMode == 'UPI') {
        data['upi_id'] = _upiIdController.text;
        data['transaction_id'] = _transactionIdController.text;
      }

      if (_expansionId != null) {
        data['expansion_id'] = _expansionId.toString();
      }

      widget.onSubmit(data, _chequeImage?.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.initialData != null ? "Edit Allocation" : "Allocate Funds",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Mode Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _ModeButton(
                    label: "Cash",
                    icon: Icons.money_rounded,
                    isActive: _paymentMode == 'CASH',
                    onTap: () => setState(() => _paymentMode = 'CASH'),
                  ),
                  const SizedBox(width: 12),
                  _ModeButton(
                    label: "Cheque",
                    icon: Icons.account_balance_rounded,
                    isActive: _paymentMode == 'CHEQUE',
                    onTap: () => setState(() => _paymentMode = 'CHEQUE'),
                  ),
                  const SizedBox(width: 12),
                  _ModeButton(
                    label: "UPI",
                    icon: Icons.qr_code_2_rounded,
                    isActive: _paymentMode == 'UPI',
                    onTap: () => setState(() => _paymentMode = 'UPI'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Manager Selection
                    ShakeWidget(
                      key: _recipientShakeKey,
                      child: PremiumDropdown<int>(
                        label: "Recipient",
                        initialValue: _selectedManagerId,
                        prefixIcon: Icons.person_rounded,
                        items: widget.managers.map((m) => PremiumDropdownItem(
                          value: m.id,
                          label: m.fullName,
                          icon: Icons.account_circle_rounded,
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedManagerId = v),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Amount
                    _buildLabel(context, "Amount"),
                    ShakeWidget(
                      key: _amountShakeKey,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(context, "0.00"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    _buildLabel(context, "Description / Note"),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: _inputDecoration(context, "E.g. Allocation for office supplies..."),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Context-specific fields
                    if (_paymentMode == 'CHEQUE') _buildChequeFields(theme),
                    if (_paymentMode == 'UPI') _buildUpiFields(theme),
                    if (_paymentMode == 'CASH') _buildCashNote(theme),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: PremiumButton(
                onPressed: _submit,
                isLoading: widget.isLoading,
                label: "ALLOCATE FUND",
                loadingLabel: "ALLOCATING...",
                borderRadius: 16,
                height: 56,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w900, 
          fontSize: 10, 
          color: theme.colorScheme.onSurface.withOpacity(0.7), 
          letterSpacing: 1.2
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.35)),
      filled: true,
      fillColor: theme.colorScheme.onSurface.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08))
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08))
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildChequeFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context, "Cheque Number"),
                  ShakeWidget(
                    key: _chequeNumberShakeKey,
                    child: TextFormField(
                      controller: _chequeNumberController,
                      decoration: _inputDecoration(context, "######"),
                      validator: (v) => _paymentMode == 'CHEQUE' && v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context, "Bank Name"),
                  ShakeWidget(
                    key: _bankNameShakeKey,
                    child: TextFormField(
                      controller: _bankNameController,
                      decoration: _inputDecoration(context, "E.g. HDFC Bank"),
                      validator: (v) => _paymentMode == 'CHEQUE' && v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context, "Cheque Date"),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _chequeDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => _chequeDate = picked);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 18, color: theme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            _chequeDate == null ? "Select Date" : DateFormat('dd-MM-yyyy').format(_chequeDate!),
                            style: TextStyle(fontWeight: FontWeight.w700, color: _chequeDate == null ? theme.colorScheme.onSurface.withOpacity(0.35) : null),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel(context, "Account Holder Name"),
        ShakeWidget(
          key: _accountHolderShakeKey,
          child: TextFormField(
            controller: _accountHolderController,
            decoration: _inputDecoration(context, "Name on account"),
            validator: (v) => _paymentMode == 'CHEQUE' && v!.isEmpty ? "Required" : null,
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel(context, "Cheque Photo"),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primaryColor.withOpacity(0.1), width: 2, style: BorderStyle.solid),
            ),
            child: _chequeImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(_chequeImage!, fit: BoxFit.cover),
                  )
                : _existingImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          _existingImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 32),
                              const SizedBox(height: 12),
                              const Text("Failed to load existing image", style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_rounded, color: theme.primaryColor, size: 32),
                          const SizedBox(height: 12),
                          Text("Upload Cheque Photo", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                          Text("JPG, PNG up to 5MB", style: theme.textTheme.bodySmall),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpiFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "UPI ID"),
        ShakeWidget(
          key: _upiIdShakeKey,
          child: TextFormField(
            controller: _upiIdController,
            decoration: _inputDecoration(context, "username@bank"),
            validator: (v) => _paymentMode == 'UPI' && v!.isEmpty ? "Required" : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel(context, "Transaction ID"),
        ShakeWidget(
          key: _transactionIdShakeKey,
          child: TextFormField(
            controller: _transactionIdController,
            decoration: _inputDecoration(context, "TXN123456789"),
            validator: (v) => _paymentMode == 'UPI' && v!.isEmpty ? "Required" : null,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Verify the transaction ID from your UPI app before submitting.",
                  style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text("Ready to Allocate", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Ensure you have handed over the physical cash of ${_amountController.text.isEmpty ? '0.00' : _amountController.text} to the manager.",
            style: TextStyle(height: 1.5, color: Colors.green[800], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


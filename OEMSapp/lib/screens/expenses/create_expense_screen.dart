import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expense_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../core/constants/api_constants.dart';
import '../../widgets/common/sticky_bottom_cta.dart';
import '../../models/expense_model.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/premium_dropdown.dart';
import '../../core/utils/design_utils.dart';
import '../../widgets/common/shake_widget.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  const CreateExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _customCategoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedDepartment;
  final List<String> _filePaths = [];
  List<ExpenseDocument> _existingDocuments = [];

  final _titleShakeKey = GlobalKey<ShakeWidgetState>();
  final _amountShakeKey = GlobalKey<ShakeWidgetState>();
  final _categoryShakeKey = GlobalKey<ShakeWidgetState>();
  final _departmentShakeKey = GlobalKey<ShakeWidgetState>();
  final _customCategoryShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _descController.text = widget.expense!.description ?? '';
      _selectedDate = widget.expense!.expenseDate;
      _selectedDepartment = widget.expense!.department;
      
      // Handle category/custom category
      if (ApiConstants.expenseCategories.contains(widget.expense!.category)) {
        _selectedCategory = widget.expense!.category;
      } else {
        _selectedCategory = 'Other';
        _customCategoryController.text = widget.expense!.category;
      }
      
      // Fetch existing documents
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchExistingDocs();
      });
    }
  }

  Future<void> _fetchExistingDocs() async {
    if (widget.expense == null) return;
    final docs = await ref.read(expenseProvider.notifier).fetchExpenseDocuments(widget.expense!.id);
    if (mounted) {
      setState(() {
        _existingDocuments = docs;
      });
    }
  }

  Future<void> _deleteExistingDoc(int docId) async {
    final success = await ref.read(expenseProvider.notifier).deleteDocument(widget.expense!.id, docId);
    if (success && mounted) {
      _fetchExistingDocs();
      ref.read(toastProvider.notifier).show(message: "Document deleted", type: ToastType.success);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _filePaths.addAll(result.paths.whereType<String>());
      });
    }
  }

  Future<void> _handleSubmit() async {
    bool isValid = _formKey.currentState!.validate();
    
    if (_titleController.text.trim().isEmpty) _titleShakeKey.currentState?.shake();
    if (_amountController.text.trim().isEmpty) _amountShakeKey.currentState?.shake();
    if (_selectedCategory == null) _categoryShakeKey.currentState?.shake();
    if (_selectedDepartment == null) _departmentShakeKey.currentState?.shake();
    if (_selectedCategory == 'Other' && _customCategoryController.text.trim().isEmpty) _customCategoryShakeKey.currentState?.shake();

    if (!isValid || _selectedCategory == null || _selectedDepartment == null) {
      if (_selectedCategory == null) {
          ref.read(toastProvider.notifier).show(message: "Select category", type: ToastType.warning);
      } else if (_selectedDepartment == null) {
          ref.read(toastProvider.notifier).show(message: "Select department", type: ToastType.warning);
      }
      return;
    }

    if (isValid) {
      // For creation, at least one voucher is required. For edit, it's optional if existing docs exist.
      if (widget.expense == null && _filePaths.isEmpty) {
        ref.read(toastProvider.notifier).show(message: "Please upload at least one voucher", type: ToastType.warning);
        return;
      }

      final effectiveCategory = _selectedCategory == 'Other'
          ? _customCategoryController.text.trim()
          : _selectedCategory;

      if (_selectedCategory == 'Other' && _customCategoryController.text.trim().isEmpty) {
        ref.read(toastProvider.notifier).show(message: "Please enter a custom category name", type: ToastType.warning);
        return;
      }

      final data = {
        'title': _titleController.text.trim(),
        'amount': _amountController.text.trim(),
        'category': effectiveCategory,
        'department': _selectedDepartment,
        'expense_date': _selectedDate.toIso8601String().split('T')[0],
        'description': _descController.text.trim(),
      };

      bool success;
      if (widget.expense != null) {
        success = await ref.read(expenseProvider.notifier).updateExpense(widget.expense!.id, data, _filePaths);
      } else {
        success = await ref.read(expenseProvider.notifier).createExpense(data, _filePaths);
      }
      
      if (mounted) {
        if (success) {
          ref.read(toastProvider.notifier).show(
            message: widget.expense != null ? "Expense updated successfully" : "Expense created successfully",
            type: ToastType.success,
          );
          context.pop();
        } else {
          ref.read(toastProvider.notifier).show(
            message: widget.expense != null ? "Failed to update expense" : "Failed to create expense",
            type: ToastType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(expenseProvider).isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.expense != null ? "Edit Expense" : "Add Expense", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      bottomNavigationBar: StickyBottomCTA(
        label: widget.expense != null ? "UPDATE EXPENSE" : "ADD EXPENSE",
        loadingLabel: widget.expense != null ? "UPDATING..." : "SUBMITTING...",
        icon: Icons.check_circle_rounded,
        isLoading: isLoading,
        onPressed: _handleSubmit,
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 100 + MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.description_rounded, color: theme.primaryColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Expense Details",
                                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                                ),
                                Text(
                                  "Provide precise information for the audit trail",
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ShakeWidget(
                        key: _titleShakeKey,
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: "Title",
                            hintText: "e.g., Office Supplies, SaaS Subscription",
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(0.03),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                          validator: (val) => val!.isEmpty ? "Identification required" : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ShakeWidget(
                              key: _categoryShakeKey,
                              child: PremiumDropdown<String>(
                                label: "Category",
                                initialValue: _selectedCategory,
                                items: ApiConstants.expenseCategories.map((c) {
                                  final info = DesignUtils.getCategoryInfo(c);
                                  return PremiumDropdownItem(
                                    value: c,
                                    label: c,
                                    icon: info.icon,
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedCategory = val);
                                  _categoryShakeKey.currentState?.shake(); // To clear if needed, optional
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ShakeWidget(
                              key: _departmentShakeKey,
                              child: PremiumDropdown<String>(
                                label: "Department",
                                initialValue: _selectedDepartment,
                                items: ['IT', 'HR', 'Marketing', 'Sales', 'Operations', 'Finance', 'Logistics']
                                    .map((d) => PremiumDropdownItem(
                                          value: d,
                                          label: d,
                                          icon: Icons.business_center_rounded,
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedDepartment = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedCategory == 'Other') ...[
                        const SizedBox(height: 20),
                        ShakeWidget(
                          key: _customCategoryShakeKey,
                          child: TextFormField(
                            controller: _customCategoryController,
                            decoration: InputDecoration(
                              labelText: "Custom Category Name",
                              prefixIcon: const Icon(Icons.category_rounded),
                              filled: true,
                              fillColor: theme.colorScheme.onSurface.withOpacity(0.03),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                            validator: (val) =>
                                _selectedCategory == 'Other' && (val == null || val.isEmpty) ? "Identify entity" : null,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.primaryColor.withOpacity(0.15), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AMOUNT",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: theme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ShakeWidget(
                              key: _amountShakeKey,
                              child: TextFormField(
                                controller: _amountController,
                                style: GoogleFonts.outfit(
                                  fontSize: 42, 
                                  fontWeight: FontWeight.w900, 
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -1.5,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(Icons.payments_rounded, color: theme.primaryColor, size: 36),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                  hintText: "0.00",
                                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) => val!.isEmpty ? "Amount is required" : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 20, color: theme.primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Date",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    Text(DateFormat('dd-MM-yyyy').format(_selectedDate),
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Add context or specific details for this expenditure...",
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withOpacity(0.03),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.attach_file_rounded, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Voucher/Document",
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              Text("Supported formats: PDF, JPG, PNG",
                                  style: TextStyle(
                                      fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.65))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_existingDocuments.isNotEmpty) ...[
                        const Text("Existing Vouchers",
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        ..._existingDocuments.map((doc) => _buildDocTile(
                              title: "Artifact #${doc.id}",
                              onDelete: () => _deleteExistingDoc(doc.id),
                              isExisting: true,
                            )),
                        const SizedBox(height: 24),
                      ],
                      Text("NEW UPLOADS",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: theme.brightness == Brightness.dark ? theme.colorScheme.secondary : theme.primaryColor, letterSpacing: 1)),
                      const SizedBox(height: 12),
                      if (_filePaths.isEmpty)
                        InkWell(
                          onTap: _pickFiles,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: theme.primaryColor.withOpacity(0.2), style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_rounded, color: theme.primaryColor, size: 32),
                                const SizedBox(height: 8),
                                const Text("Click to upload voucher",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text("PDF, JPG, PNG up to 10MB",
                                    style: TextStyle(
                                        fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._filePaths.asMap().entries.map((entry) => _buildDocTile(
                              title: entry.value.split('/').last,
                              onDelete: () => setState(() => _filePaths.removeAt(entry.key)),
                            )),
                      if (_filePaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextButton.icon(
                            onPressed: _pickFiles,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text("Add More Documents"),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildDocTile({required String title, required VoidCallback onDelete, bool isExisting = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(isExisting ? Icons.assignment_turned_in_rounded : Icons.file_present_rounded,
                size: 18, color: isExisting ? Colors.green : theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}


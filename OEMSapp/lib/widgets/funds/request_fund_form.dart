import 'package:flutter/material.dart';
import '../premium/premium_button.dart';

class RequestFundForm extends StatefulWidget {
  final Function(Map<String, dynamic> data) onSubmit;
  final VoidCallback onCancel;
  final bool isLoading;

  const RequestFundForm({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  State<RequestFundForm> createState() => _RequestFundFormState();
}

class _RequestFundFormState extends State<RequestFundForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'requested_amount': _amountController.text,
        'description': _descriptionController.text,
      });
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    child: Icon(Icons.request_quote_rounded, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Request Funds",
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.textTheme.labelSmall?.color?.withOpacity(0.5)),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("AMOUNT REQUESTED"),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("0.00"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildLabel("PURPOSE / JUSTIFICATION"),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _inputDecoration("Why do you need these funds?"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: PremiumButton(
                onPressed: _submit,
                isLoading: widget.isLoading,
                label: "SUBMIT REQUEST",
                loadingLabel: "SUBMITTING...",
                borderRadius: 16,
                height: 56,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black.withOpacity(0.5), letterSpacing: 0.5),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/totp_account.dart';
import '../providers/totp_provider.dart';

class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  void dispose() {
    _issuerController.dispose();
    _accountNameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newAccount = TotpAccount(
        issuer: _issuerController.text.trim(),
        accountName: _accountNameController.text.trim(),
        secret: _secretController.text.trim().replaceAll(' ', ''),
      );

      final provider = context.read<TotpProvider>();
      provider.addAccount(newAccount);

      Navigator.of(context).pop(); // Close dialog
    }
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add TOTP Account'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(labelText: 'Issuer'),
                validator: _validateNotEmpty,
              ),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: _validateNotEmpty,
              ),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(labelText: 'Secret (Base32)'),
                validator: (value) {
                  final res = _validateNotEmpty(value);
                  if (res != null) return res;
                  // Add basic Base32 validation (optional)
                  final base32Regex = RegExp(r'^[A-Z2-7]+=*$');
                  if (!base32Regex.hasMatch(value!.replaceAll(' ', '').toUpperCase())) {
                    return 'Invalid Base32 format';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // cancel button
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

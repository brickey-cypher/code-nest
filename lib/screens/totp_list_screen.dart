import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/totp_provider.dart';
import '../models/totp_account.dart';

class TotpListScreen extends StatelessWidget {
  const TotpListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TotpProvider>(context);
    final accounts = provider.accounts;
    final codes = provider.currentCodes;

    return Scaffold(
appBar: AppBar(
  title: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          child: Image.asset(
            'assets/icons/icon.png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 18),
        const Text(
          'CodeNest',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  ),
),
      body: accounts.isEmpty
          ? const Center(child: Text('No accounts found'))
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final code = codes[account.secret] ?? '------';
                final secondsRemaining = provider.secondsRemaining;

                return ListTile(
                  title: Text('${account.issuer} (${account.accountName})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: $code (Expires in $secondsRemaining s)'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: secondsRemaining / 30,
                        backgroundColor: Colors.grey[300],
                        color: Colors.deepPurple,
                        minHeight: 4,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, provider, account);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAccountDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TotpProvider provider, TotpAccount account) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete ${account.issuer} (${account.accountName})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeAccount(account);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final issuerController = TextEditingController();
    final accountNameController = TextEditingController();
    final secretController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add TOTP Account'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: issuerController,
                  decoration: const InputDecoration(labelText: 'Issuer'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Please enter issuer' : null,
                ),
                TextFormField(
                  controller: accountNameController,
                  decoration: const InputDecoration(labelText: 'Account Name'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Please enter account name' : null,
                ),
                TextFormField(
                  controller: secretController,
                  decoration: const InputDecoration(labelText: 'Secret'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter secret';
                    }
                    final pattern = RegExp(r'^[A-Z2-7]+=*$'); // Simple Base32 check
                    if (!pattern.hasMatch(value.trim().toUpperCase())) {
                      return 'Invalid secret (must be Base32)';
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final account = TotpAccount(
                  issuer: issuerController.text.trim(),
                  accountName: accountNameController.text.trim(),
                  secret: secretController.text.trim().toUpperCase(),
                );
                final provider = Provider.of<TotpProvider>(dialogContext, listen: false);
                provider.addAccount(account);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/socket_service.dart';

class CurrencySettingsModal extends ConsumerWidget {
  const CurrencySettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    const currencies = [
      {'code': 'INR', 'name': 'Indian Rupee', 'flag': '🇮🇳'},
      {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸'},
      {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺'},
      {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
      {'code': 'CAD', 'name': 'Canadian Dollar', 'flag': '🇨🇦'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺'},
      {'code': 'AED', 'name': 'UAE Dirham', 'flag': '🇦🇪'},
      {'code': 'SAR', 'name': 'Saudi Riyal', 'flag': '🇸🇦'},
      {'code': 'CNY', 'name': 'Chinese Yuan', 'flag': '🇨🇳'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Currency",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (settings.isLoadingRates)
                  const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "All amounts will be converted based on live exchange rates.",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final code = currency['code']!;
                final isSelected = settings.currency == code;

                return ListTile(
                  leading: Text(currency['flag']!, style: const TextStyle(fontSize: 24)),
                  title: Text(currency['name']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(code, style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.primaryColor : Colors.grey,
                      )),
                      if (isSelected) const SizedBox(width: 8),
                      if (isSelected) Icon(Icons.check_circle, color: theme.primaryColor, size: 20),
                    ],
                  ),
                  onTap: () {
                    notifier.setCurrency(code);
                    // Broadcast to all connected clients
                    ref.read(socketServiceProvider).emitCurrencyChange(code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

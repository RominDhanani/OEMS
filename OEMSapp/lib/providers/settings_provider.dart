import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/report_generator.dart';
import 'toast_provider.dart';
import '../widgets/common/erp_toast.dart';
import '../core/constants/api_constants.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final String currency;
  final Map<String, double> rates;
  final bool isLoadingRates;
  final String? error;
  final String? serverIp;

  SettingsState({
    this.currency = 'INR',
    this.rates = const {
      'INR': 1.0,
      'USD': 0.012,
      'EUR': 0.011,
      'GBP': 0.0095,
      'JPY': 1.80,
      'CAD': 0.016,
      'AUD': 0.018,
      'AED': 0.044,
      'SAR': 0.045,
      'CNY': 0.086
    },
    this.isLoadingRates = false,
    this.error,
    this.serverIp,
  });

  String get currencySymbol {
    const configs = {
      'INR': '₹',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'AED': 'د.إ',
      'SAR': 'SR',
      'CNY': '¥',
    };
    return configs[currency] ?? '₹';
  }

  SettingsState copyWith({
    String? currency,
    Map<String, double>? rates,
    bool? isLoadingRates,
    String? error,
    String? serverIp,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
      rates: rates ?? this.rates,
      isLoadingRates: isLoadingRates ?? this.isLoadingRates,
      error: error ?? this.error,
      serverIp: serverIp ?? this.serverIp,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load saved currency
    final savedCurrency = await _storage.read(key: 'selected_currency');
    if (savedCurrency != null) {
      state = state.copyWith(currency: savedCurrency);
    }
    
    // Load saved server IP
    final savedIp = await _storage.read(key: 'server_ip');
    if (savedIp != null) {
      state = state.copyWith(serverIp: savedIp);
    }
    
    // Auto-discover if current IP is unreachable AND it's a local-style IP
    final currentUrl = ApiConstants.getBaseUrl(state.serverIp);
    if (!(await _isServerReachable(currentUrl))) {
      if (!mounted) return;
      
      // If the saved custom IP is dead, clear it to fallback to production
      if (state.serverIp != null) {
        await resetServerIp();
      }

      // Only auto-discover if we are NOT trying to connect to a production URL
      if (!currentUrl.contains('vercel.app')) {
        await discoverServer();
      }
    }
    
    if (!mounted) return;
    // Sync with ReportGenerator immediately
    _syncWithReportGenerator();

    // Check TTL and fetch if needed
    final lastFetchedStr = await _storage.read(key: 'rates_last_fetched');
    if (!mounted) return;
    final DateTime? lastFetched = lastFetchedStr != null ? DateTime.parse(lastFetchedStr) : null;
    
    if (lastFetched == null || DateTime.now().difference(lastFetched).inHours >= 1) {
      await _fetchLiveRates();
    } else {
      // Load saved rates
      final savedRatesStr = await _storage.read(key: 'cached_rates');
      if (!mounted) return;
      if (savedRatesStr != null) {
        try {
          final Map<String, dynamic> rawRates = Map<String, dynamic>.from(
            Uri.splitQueryString(savedRatesStr).map((k, v) => MapEntry(k, double.parse(v)))
          );
          final Map<String, double> rates = rawRates.map((key, value) => MapEntry(key, value.toDouble()));
          state = state.copyWith(rates: rates);
        } catch (_) {}
      }
    }
  }

  Future<void> _fetchLiveRates() async {
    state = state.copyWith(isLoadingRates: true);
    try {
      final response = await _dio.get('https://open.er-api.com/v6/latest/INR');
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> rawRates = data['rates'];
        final Map<String, double> rates = rawRates.map((key, value) => MapEntry(key, value.toDouble()));
        
        // Persist
        await _storage.write(key: 'rates_last_fetched', value: DateTime.now().toIso8601String());
        final String ratesStr = rates.entries.map((e) => "${e.key}=${e.value}").join("&");
        await _storage.write(key: 'cached_rates', value: ratesStr);

        state = state.copyWith(rates: rates, isLoadingRates: false);
        _syncWithReportGenerator();
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoadingRates: false, error: e.toString());
    }
  }

  Future<void> setCurrency(String currency, {bool fromSocket = false, Ref? ref}) async {
    if (state.currency == currency) return; // No change needed
    state = state.copyWith(currency: currency);
    await _storage.write(key: 'selected_currency', value: currency);
    _syncWithReportGenerator();
    
    if (ref != null) {
      ref.read(toastProvider.notifier).show(
        message: 'Currency updated to $currency${fromSocket ? ' (Live Sync)' : ''}',
        type: ToastType.info,
      );
    }
  }

  void _syncWithReportGenerator() {
    final config = _getCurrencyConfig(state.currency);
    final rate = state.rates[state.currency] ?? 1.0;
    
    // Explicit null-safety checks
    final symbol = config['symbol'] ?? '₹';
    final locale = config['locale'] ?? 'en-IN';
    
    ReportGenerator.updatePdfConfig(
      symbol: symbol,
      locale: locale,
      rate: rate,
    );
  }

  String formatCurrency(double amount) {
    final rate = state.rates[state.currency] ?? 1.0;
    final convertedAmount = amount * rate;
    
    final config = _getCurrencyConfig(state.currency);
    final format = NumberFormat.currency(
      symbol: config['symbol'],
      locale: config['locale'],
      decimalDigits: 2,
    );
    
    return format.format(convertedAmount);
  }

  String getSymbol() {
    return _getCurrencyConfig(state.currency)['symbol'] ?? '₹';
  }

  Map<String, String> _getCurrencyConfig(String code) {
    const configs = {
      'INR': {'symbol': '₹', 'locale': 'en-IN', 'name': 'Indian Rupee'},
      'USD': {'symbol': '\$', 'locale': 'en-US', 'name': 'US Dollar'},
      'EUR': {'symbol': '€', 'locale': 'de-DE', 'name': 'Euro'},
      'GBP': {'symbol': '£', 'locale': 'en-GB', 'name': 'British Pound'},
      'JPY': {'symbol': '¥', 'locale': 'ja-JP', 'name': 'Japanese Yen'},
      'CAD': {'symbol': 'C\$', 'locale': 'en-CA', 'name': 'Canadian Dollar'},
      'AUD': {'symbol': 'A\$', 'locale': 'en-AU', 'name': 'Australian Dollar'},
      'AED': {'symbol': 'د.إ', 'locale': 'ar-AE', 'name': 'UAE Dirham'},
      'SAR': {'symbol': 'SR', 'locale': 'ar-SA', 'name': 'Saudi Riyal'},
      'CNY': {'symbol': '¥', 'locale': 'zh-CN', 'name': 'Chinese Yuan'},
    };
    return configs[code] ?? configs['INR']!;
  }

  List<Map<String, String>> getAvailableCurrencies() {
    return [
      {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
      {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
      {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
      {'code': 'AED', 'name': 'UAE Dirham', 'symbol': 'د.إ'},
      {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'SR'},
      {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    ];
  }

  void exportData(List<List<dynamic>> rows, List<String> headers, String title) {
    ReportGenerator.generateExcel(title: title, headers: headers, data: rows);
  }

  Future<void> setServerIp(String ip) async {
    state = state.copyWith(serverIp: ip);
    await _storage.write(key: 'server_ip', value: ip);
  }

  Future<void> resetServerIp() async {
    state = state.copyWith(serverIp: null);
    await _storage.delete(key: 'server_ip');
  }

  Future<String?> discoverServer() async {
    if (state.isLoadingRates) return null;
    state = state.copyWith(isLoadingRates: true);
    
    try {
      // 1. Determine local subnet candidates
      final List<String> subnets = ['192.168.0', '192.168.1', '192.168.100', '10.0.2'];
      final List<int> ports = [5000, 3000];
      
      // 2. Perform parallel probes for common ranges first for speed
      // Range: .1,.2, .100-.110, .190-.200
      final List<int> priorityRange = [1, 2, 100, 101, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200];
      
      for (final subnet in subnets) {
        for (final port in ports) {
          // Optimized parallel probing
          final List<Future<String?>> probes = priorityRange.map((i) async {
            final String testIp = "$subnet.$i";
            try {
              final response = await _dio.get(
                'http://$testIp:$port/api/health',
                options: Options(
                  receiveTimeout: const Duration(seconds: 1),
                  sendTimeout: const Duration(seconds: 1),
                ),
              );
              if (response.statusCode == 200 && response.data['status'] == 'OK') {
                return (port == 5000) ? testIp : "$testIp:$port";
              }
            } catch (_) {}
            return null;
          }).toList();

          final List<String?> results = await Future.wait(probes);
          final String? found = results.firstWhere((r) => r != null, orElse: () => null);
          
          if (found != null) {
            await setServerIp(found);
            return found;
          }
        }
      }
    } finally {
      if (mounted) {
        state = state.copyWith(isLoadingRates: false);
      }
    }
    return null;
  }

  Future<bool> _isServerReachable(String url) async {
    try {
      final String healthUrl = url.endsWith('/api') ? "$url/health" : url.contains('/api/') ? url : "$url/api/health";
      
      final response = await _dio.get(
        healthUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 10), // Increased for Vercel cold starts
          sendTimeout: const Duration(seconds: 10)
        ),
      ).timeout(const Duration(seconds: 12));
      return response.statusCode == 200 && (response.data['status'] == 'OK' || response.data['status'] == 'success');
    } catch (_) {
      return false;
    }
  }
}

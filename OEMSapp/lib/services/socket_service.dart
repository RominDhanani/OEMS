import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/fund_provider.dart';
import '../providers/expansion_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/report_provider.dart';
import 'package:logger/logger.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final serverIp = ref.watch(settingsProvider.select((s) => s.serverIp));
  final service = SocketService(ref, serverIp);
  ref.onDispose(() => service.dispose());
  return service;
});

class SocketService {
  final Ref _ref;
  final String? _serverIp;
  io.Socket? _socket;
  final _logger = Logger();
  
  // Streams for external listeners
  final _eventController = StreamController<String>.broadcast();
  Stream<String> get eventStream => _eventController.stream;
  Map<String, dynamic> lastData = {};

  SocketService(this._ref, this._serverIp);

  void connect() {
    if (_socket != null && _socket!.connected) return;

    final user = _ref.read(authProvider).user;
    if (user == null) return;

    // Derive base URL from ApiConstants
    final baseUrl = ApiConstants.getBaseUrl(_serverIp).replaceAll('/api', '');

    _socket = io.io(baseUrl, io.OptionBuilder()
        .setTransports(['websocket']) // Force websockets for instant delivery
        .enableForceNew() // Ensure fresh connection
        .enableAutoConnect()
        .setReconnectionAttempts(10)
        .setReconnectionDelay(3000)
        .setExtraHeaders({'origin': baseUrl})
        .build());

    _socket?.onConnect((_) {
      _logger.i('Flutter connected to WebSockets');
      _socket?.emit('joinUserRoom', user.id);
      _socket?.emit('joinRoleRoom', user.role);
    });

    _socket?.onDisconnect((_) => _logger.w('Disconnected from WebSockets'));

    _socket?.on('expenseUpdated', (_) {
      _notify('expenseUpdated');
      _ref.invalidate(expenseProvider);
      _ref.invalidate(notificationProvider);
      _ref.invalidate(reportProvider);
    });
    _socket?.on('fundUpdated', (_) {
      _notify('fundUpdated');
      _ref.invalidate(fundProvider);
      _ref.invalidate(notificationProvider);
      _ref.invalidate(reportProvider);
    });
    _socket?.on('expansionUpdated', (_) {
      _notify('expansionUpdated');
      _ref.invalidate(expansionProvider);
      _ref.invalidate(notificationProvider);
      _ref.invalidate(reportProvider);
    });
    _socket?.on('notificationReceived', (_) {
      _notify('notificationReceived');
      _ref.invalidate(notificationProvider);
    });
    _socket?.on('userUpdated', (_) => _notify('userUpdated'));
    _socket?.on('settingsUpdated', (data) {
      _logger.i('RAW Socket settings payload: $data');
      try {
        if (data != null) {
          final String? updatedCurrency = data['currency']?.toString();
          if (updatedCurrency != null) {
            _logger.i('Successfully parsed currency: $updatedCurrency. Dispatching to provider...');
            _ref.read(settingsProvider.notifier).setCurrency(updatedCurrency, fromSocket: true, ref: _ref);
          }
        }
      } catch (e) {
        _logger.e('Error applying socket currency update: $e');
      }
      _notify('settingsUpdated');
    });
    _socket?.on('connect_error', (err) => _logger.e('Socket Connect Error: $err'));
    _socket?.on('connect_timeout', (_) => _logger.e('Socket Connect Timeout'));
    _socket?.on('error', (err) => _logger.e('Socket Error: $err'));
  }

  void _notify(String event) {
    _logger.d('Socket event received: $event');
    _eventController.add(event);
  }

  void emitCurrencyChange(String currency) {
    _socket?.emit('changeCurrency', {'currency': currency});
    _logger.i('Emitted changeCurrency: $currency');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}

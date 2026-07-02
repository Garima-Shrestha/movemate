import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

class SocketService {
  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String userId, String role) {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final serverUrl = dotenv.env['SOCKET_URL'] ?? '';

    _socket = IO.io(serverUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      print("SOCKET CONNECTED");
      print("USER ID = $userId");
      print("ROLE = $role");

      _socket!.emit('joinRoom', {'userId': userId, 'role': role});
    });

    _socket!.onDisconnect((_) {
      print("SOCKET DISCONNECTED");
    });

    _socket!.onReconnect((_) {
      print("SOCKET RECONNECTED");
    });
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void off(String event) {
    _socket?.off(event);
  }
}
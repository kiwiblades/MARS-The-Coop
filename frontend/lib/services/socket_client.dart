/*
  Wrapper for Socket emits/listening, manages Socket.io connection for entire app.
  Follows Singleton pattern like TokenManager, so there's only ever one persistent connection
  across all socket-based services. This avoids duplicate connections and event listeners which
  would cause events to fire multiple times and waste resources.
*/

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/services/token_manager.dart';
import '../config/env.dart';

class SocketClient {
  // private constructor prevents external instantiation
  static final SocketClient _instance = SocketClient._internal();
  static SocketClient get instance => _instance;
  SocketClient._internal();

  IO.Socket? _socket;
  final TokenManager _tokens = TokenManager.instance; // fetch single TokenManager instance

  bool get isConnected => _socket?.connected ?? false;

  // build and connect socket w/ current access token attached, same auth header as ApiClient
  Future<void> connect() async {
    // skip if already connected, so the fcn is safe to call repeatedly (no need to check isConnected externally)
    if (isConnected) return;

    final token = await _tokens.getAccessToken();

    _socket = IO.io(
      Env.apiBaseUrl,
      IO.OptionBuilder()
        .setTransports(['websocket']) // bypass http polling, straight to ws
        .disableAutoConnect() // connect manually after setting options
        .enableReconnection() // auto-reconnect if connection drop
        .setReconnectionAttempts(5) // give up after 5 failed attempts
        .setReconnectionDelay(2000) // wait 2s between attempts
        .setExtraHeaders({
          // attach access token so backend can authenticate socket handshake
          if (token != null && token.isNotEmpty)
            'authorization': 'Bearer $token', 
        })
        .build(),
    );

    _socket!.onConnect((_) {
      print('[SocketClient] connected: ${_socket!.id}');
    });

    // fires on intentional and unintentional disconnects
    _socket!.onDisconnect((_) {
      print('[SocketClient] disconnected');
    });

    // fires if handshake fails (server error, bad token, etc)
    _socket!.onConnectError((e) {
      print('[SocketClient] connection error: $e');
    });

    // fires after successful auto reconnect after a drop
    _socket!.onReconnect((_) {
      print('[SocketClient] reconnected');
    });

    _socket!.connect();
  }

  // disconnect and clear the socket, call on logout
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose(); // release internal socket.io resources
    _socket = null;
    print('[SocketClient] disconnected and disposed');
  }

  // --- room management, here because it's used by multiple services

  // join a socket.io room to receive events emitted to that room
  // called when opening a chatroom before listening for messages or daily questions
  void joinRoom(String chatId) {
    _assertConnected();
    _socket!.emit('join_room', chatId);
    print('[SocketClient] joined room: $chatId');
  }

  // leave a socket.io room, aclled when navigating away from a chatroom
  void leaveRoom(String chatId) {
    _assertConnected();
    _socket!.emit('leave_room', chatId);
    print('[SocketClient] left room: $chatId');
  }

  Future<void> waitUntilConnected({Duration timeout = const Duration(seconds: 5)}) async {
    if (isConnected) return;
    final completer = Completer<void>();

    _socket!.onConnect((_) {
      if (!completer.isCompleted) completer.complete();
    });
    _socket!.onConnectError((e) {
      if (!completer.isCompleted) {
        completer.completeError('Socket connection failed: $e');
      }
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () => throw TimeoutException('Socket connection timed out'),
    );
  }

  // --- foundational emit/on, services call these rather than using the socket directly

  // emit named event with a payload to the server
  void emit(String event, dynamic data) {
    _assertConnected();
    _socket!.emit(event, data);
  }

  // on: return a broadcast stream for a socket event, multiple listeners can subscribe to
  // the same event to receive the stream
  Stream<Map<String, dynamic>> on(String event) {
    _assertConnected();
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _socket!.on(event, (data) {
      try {
        // socket.io delivers data as a dynamic Map, cast to Map<String, dynamic>
        controller.add(Map<String, dynamic>.from(data as Map));
      } catch(e) {
        print('[SocketClient] failed to parse event "$event": $e');
      }
    });
    return controller.stream;
  }

  // connection should be verified before attempting to emit events or listen on events
  void _assertConnected() {
    if (_socket == null || !isConnected) {
      throw StateError('[SocketClient] not connected, call connect() first');
    }
  }
}
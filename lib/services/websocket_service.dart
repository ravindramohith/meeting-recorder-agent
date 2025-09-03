import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebSocketService extends ChangeNotifier {
  static const String wsUrl = 'ws://localhost:8000/ws';
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  StreamSubscription? _subscription;
  
  bool get isConnected => _isConnected;
  
  Future<bool> connect() async {
    try {
      print('🔗 Connecting to WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen for messages from server
      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _isConnected = false;
          notifyListeners();
        },
      );
      
      _isConnected = true;
      notifyListeners();
      print('✅ WebSocket connected successfully');
      return true;
      
    } catch (e) {
      print('❌ Failed to connect WebSocket: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      print('📨 Received: ${data['type']} - ${data['timestamp']}');
      
      switch (data['type']) {
        case 'chunk_received':
          print('✅ Chunk confirmed: ${data['chunk_size']} bytes, total: ${data['total_chunks']}');
          break;
        case 'session_started':
          print('🎬 Session started: ${data['timestamp']}');
          break;
        case 'session_ended':
          print('🛑 Session ended: ${data['filename'] ?? 'No file'}');
          break;
      }
    } catch (e) {
      print('❌ Error parsing WebSocket message: $e');
    }
  }
  
  Future<void> startSession() async {
    if (!_isConnected) return;
    
    final message = {
      'type': 'start_session',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _channel!.sink.add(json.encode(message));
    print('📤 Sent start_session');
  }
  
  Future<void> sendAudioChunk(Uint8List audioData) async {
    if (!_isConnected) return;
    
    try {
      // Encode audio data as base64
      final base64Audio = base64.encode(audioData);
      
      final message = {
        'type': 'audio_chunk',
        'data': base64Audio,
        'timestamp': DateTime.now().toIso8601String(),
        'size': audioData.length,
      };
      
      _channel!.sink.add(json.encode(message));
      print('📤 Sent audio chunk: ${audioData.length} bytes');
      
    } catch (e) {
      print('❌ Failed to send audio chunk: $e');
    }
  }
  
  Future<void> endSession() async {
    if (!_isConnected) return;
    
    final message = {
      'type': 'end_session',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _channel!.sink.add(json.encode(message));
    print('📤 Sent end_session');
  }
  
  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
    print('🔌 WebSocket disconnected');
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

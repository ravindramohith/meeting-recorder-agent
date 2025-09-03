import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'websocket_service.dart';

class AudioService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final WebSocketService _webSocketService = WebSocketService();
  bool _isRecording = false;
  Timer? _chunkTimer;
  String? _currentRecordingPath;
  
  bool get isRecording => _isRecording;
  WebSocketService get webSocketService => _webSocketService;
  
  Future<bool> requestPermissions() async {
    try {
      // Use the record plugin's built-in permission system for macOS
      final hasPermission = await _recorder.hasPermission();
      print('Microphone permission check: $hasPermission');
      
      if (hasPermission) {
        print('✅ Microphone permission already granted');
        return true;
      } else {
        print('❌ Microphone permission not granted - user needs to grant in System Preferences');
        return false;
      }
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }
  
  Future<bool> startRecording() async {
    try {
      print('Starting recording process...');
      
      // Check permissions first
      if (!await requestPermissions()) {
        print('❌ Microphone permission denied');
        return false;
      }
      print('✅ Microphone permission granted');
      
      // Check if recorder is available
      final isAvailable = await _recorder.hasPermission();
      print('Recorder permission check: $isAvailable');
      
      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = path.join(tempDir.path, 'meeting_$timestamp.m4a');
      print('Recording path: $_currentRecordingPath');
      
      // Start recording with simplified config for better compatibility
      print('Starting recorder...');
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          numChannels: 1, // Mono recording
        ),
        path: _currentRecordingPath!,
      );
      
      // Verify recording actually started
      final isRecording = await _recorder.isRecording();
      print('Recording verification: $isRecording');
      
      if (!isRecording) {
        print('❌ Recording failed to start');
        return false;
      }
      
      _isRecording = true;
      notifyListeners();
      
      // Start sending chunks every 10 seconds
      _startChunkTimer();
      
      print('✅ Recording started successfully: $_currentRecordingPath');
      return true;
      
    } catch (e) {
      print('❌ Failed to start recording: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }
  
  Future<void> stopRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _chunkTimer?.cancel();
        _isRecording = false;
        notifyListeners();
        
        print('Recording stopped');
        
        // Send final chunk if needed
        if (_currentRecordingPath != null) {
          await _sendFinalAudioFile();
        }
      }
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }
  
  void _startChunkTimer() {
    _chunkTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_isRecording) {
        await _sendAudioChunk();
      } else {
        timer.cancel();
      }
    });
  }
  
  Future<void> _sendAudioChunk() async {
    try {
      if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
        final file = File(_currentRecordingPath!);
        final bytes = await file.readAsBytes();
        
        // Send chunk to FastAPI server
        await _sendToServer(bytes, isChunk: true);
      }
    } catch (e) {
      print('Failed to send audio chunk: $e');
    }
  }
  
  Future<void> _sendFinalAudioFile() async {
    try {
      if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
        final file = File(_currentRecordingPath!);
        final bytes = await file.readAsBytes();
        
        // Send final file to FastAPI server
        await _sendToServer(bytes, isChunk: false);
        
        // Clean up temporary file
        await file.delete();
      }
    } catch (e) {
      print('Failed to send final audio file: $e');
    }
  }
  
  Future<void> _sendToServer(Uint8List audioData, {required bool isChunk}) async {
    try {
      if (isChunk) {
        await _webSocketService.sendAudioChunk(audioData);
      } else {
        // Send final file via WebSocket
        await _webSocketService.sendAudioChunk(audioData);
      }
    } catch (e) {
      print('Failed to send audio to server: $e');
    }
  }
  
  @override
  void dispose() {
    _chunkTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}

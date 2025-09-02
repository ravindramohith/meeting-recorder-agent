import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'network_service.dart';

class AudioService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final NetworkService _networkService = NetworkService();
  bool _isRecording = false;
  Timer? _chunkTimer;
  String? _currentRecordingPath;
  
  bool get isRecording => _isRecording;
  
  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }
  
  Future<bool> startRecording() async {
    try {
      // Check permissions first
      if (!await requestPermissions()) {
        print('Microphone permission denied');
        return false;
      }
      
      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = path.join(tempDir.path, 'meeting_$timestamp.m4a');
      
      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );
      
      _isRecording = true;
      notifyListeners();
      
      // Start sending chunks every 10 seconds
      _startChunkTimer();
      
      print('Recording started: $_currentRecordingPath');
      return true;
      
    } catch (e) {
      print('Failed to start recording: $e');
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
        await _networkService.sendAudioChunk(audioData);
      } else {
        // Send final file for transcription
        final filename = 'meeting_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _networkService.sendForTranscription(audioData, filename);
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

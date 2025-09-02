import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  static const String baseUrl = 'http://localhost:5000';
  late final Dio _dio;
  
  NetworkService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
    
    // Add interceptors for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // Don't log audio data
        responseBody: true,
        logPrint: (object) => print(object),
      ));
    }
  }
  
  /// Send audio chunk to FastAPI server
  Future<bool> sendAudioChunk(Uint8List audioData) async {
    try {
      final formData = FormData.fromMap({
        'audio_data': MultipartFile.fromBytes(
          audioData,
          filename: 'audio_chunk_${DateTime.now().millisecondsSinceEpoch}.m4a',
          contentType: DioMediaType('audio', 'mp4'),
        ),
      });
      
      final response = await _dio.post('/audio-chunk', data: formData);
      
      if (response.statusCode == 200) {
        print('Audio chunk sent successfully: ${response.data}');
        return true;
      } else {
        print('Failed to send audio chunk: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('Network error sending audio chunk: $e');
      return false;
    }
  }
  
  /// Start a new recording session
  Future<bool> startSession() async {
    try {
      final response = await _dio.post('/start-session');
      
      if (response.statusCode == 200) {
        print('Recording session started: ${response.data}');
        return true;
      } else {
        print('Failed to start session: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('Network error starting session: $e');
      return false;
    }
  }
  
  /// End the recording session
  Future<bool> endSession() async {
    try {
      final response = await _dio.post('/end-session');
      
      if (response.statusCode == 200) {
        print('Recording session ended: ${response.data}');
        return true;
      } else {
        print('Failed to end session: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('Network error ending session: $e');
      return false;
    }
  }
  
  /// Check server status
  Future<bool> checkServerStatus() async {
    try {
      final response = await _dio.get('/status');
      
      if (response.statusCode == 200) {
        print('Server status: ${response.data}');
        return true;
      } else {
        return false;
      }
      
    } catch (e) {
      print('Server not reachable: $e');
      return false;
    }
  }
  
  /// Send complete audio file for transcription
  Future<Map<String, dynamic>?> sendForTranscription(Uint8List audioData, String filename) async {
    try {
      final formData = FormData.fromMap({
        'audio_file': MultipartFile.fromBytes(
          audioData,
          filename: filename,
          contentType: DioMediaType('audio', 'mp4'),
        ),
      });
      
      final response = await _dio.post('/transcribe', data: formData);
      
      if (response.statusCode == 200) {
        print('Transcription completed: ${response.data}');
        return response.data;
      } else {
        print('Failed to transcribe: ${response.statusCode}');
        return null;
      }
      
    } catch (e) {
      print('Network error during transcription: $e');
      return null;
    }
  }
}

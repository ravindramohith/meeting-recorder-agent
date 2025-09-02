import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrayManager {
  static const MethodChannel _channel = MethodChannel('meeting_recorder/tray');
  
  static Function()? onStartRecording;
  static Function()? onStopRecording;
  static Function()? onShowWindow;
  
  static Future<void> initialize({
    required Function() onStart,
    required Function() onStop,
    required Function() onShow,
  }) async {
    onStartRecording = onStart;
    onStopRecording = onStop;
    onShowWindow = onShow;
    
    // Set up method call handler
    _channel.setMethodCallHandler(_handleMethodCall);
    
    try {
      await _channel.invokeMethod('initTray');
    } catch (e) {
      print('Failed to initialize system tray: $e');
    }
  }
  
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'startRecording':
        onStartRecording?.call();
        break;
      case 'stopRecording':
        onStopRecording?.call();
        break;
      case 'showWindow':
        onShowWindow?.call();
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} is not implemented',
        );
    }
  }
  
  static Future<void> updateRecordingState(bool isRecording) async {
    try {
      await _channel.invokeMethod('updateRecordingState', {
        'isRecording': isRecording,
      });
    } catch (e) {
      print('Failed to update recording state: $e');
    }
  }
  
  static Future<void> setTooltip(String tooltip) async {
    try {
      await _channel.invokeMethod('setTooltip', {
        'tooltip': tooltip,
      });
    } catch (e) {
      print('Failed to set tooltip: $e');
    }
  }
}

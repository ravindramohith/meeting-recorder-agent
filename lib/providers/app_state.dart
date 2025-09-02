import 'package:flutter/foundation.dart';
import '../services/audio_service.dart';
import '../services/network_service.dart';
import '../services/system_tray_service.dart';

class AppState extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final NetworkService _networkService = NetworkService();
  final SystemTrayService _systemTrayService = SystemTrayService();
  
  bool _isRecording = false;
  bool _isServerConnected = false;
  String _statusMessage = 'Ready';
  
  // Getters
  bool get isRecording => _isRecording;
  bool get isServerConnected => _isServerConnected;
  String get statusMessage => _statusMessage;
  AudioService get audioService => _audioService;
  SystemTrayService get systemTrayService => _systemTrayService;
  
  AppState() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    // Check server connection
    await _checkServerConnection();
    
    // Initialize system tray
    await _systemTrayService.initSystemTray(
      onStart: startRecording,
      onStop: stopRecording,
      onShow: showMainWindow,
    );
    
    // Listen to audio service changes
    _audioService.addListener(_onAudioServiceChanged);
  }
  
  void _onAudioServiceChanged() {
    final wasRecording = _isRecording;
    _isRecording = _audioService.isRecording;
    
    if (wasRecording != _isRecording) {
      _systemTrayService.updateRecordingState(_isRecording);
      _updateStatusMessage();
      notifyListeners();
    }
  }
  
  Future<void> _checkServerConnection() async {
    _isServerConnected = await _networkService.checkServerStatus();
    _updateStatusMessage();
    notifyListeners();
  }
  
  void _updateStatusMessage() {
    if (!_isServerConnected) {
      _statusMessage = 'Server not connected (localhost:5000)';
    } else if (_isRecording) {
      _statusMessage = 'Recording in progress...';
    } else {
      _statusMessage = 'Ready to record';
    }
  }
  
  Future<void> startRecording() async {
    if (!_isServerConnected) {
      await _checkServerConnection();
      if (!_isServerConnected) {
        _statusMessage = 'Cannot start: Server not available';
        notifyListeners();
        return;
      }
    }
    
    _statusMessage = 'Starting recording...';
    notifyListeners();
    
    // Start session on server
    final sessionStarted = await _networkService.startSession();
    if (!sessionStarted) {
      _statusMessage = 'Failed to start server session';
      notifyListeners();
      return;
    }
    
    // Start audio recording
    final recordingStarted = await _audioService.startRecording();
    if (!recordingStarted) {
      _statusMessage = 'Failed to start recording';
      notifyListeners();
      return;
    }
    
    _statusMessage = 'Recording started';
    notifyListeners();
  }
  
  Future<void> stopRecording() async {
    _statusMessage = 'Stopping recording...';
    notifyListeners();
    
    // Stop audio recording
    await _audioService.stopRecording();
    
    // End session on server
    await _networkService.endSession();
    
    _statusMessage = 'Recording stopped';
    notifyListeners();
  }
  
  void showMainWindow() {
    // This will be called when user wants to show the main window
    print('Show main window requested');
  }
  
  Future<void> refreshServerConnection() async {
    await _checkServerConnection();
  }
  
  @override
  void dispose() {
    _audioService.removeListener(_onAudioServiceChanged);
    _audioService.dispose();
    _systemTrayService.dispose();
    super.dispose();
  }
}

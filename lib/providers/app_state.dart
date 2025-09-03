import 'package:flutter/foundation.dart';
import '../services/audio_service.dart';
import '../services/network_service.dart';

class AppState extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final NetworkService _networkService = NetworkService();
  
  bool _isRecording = false;
  bool _isServerConnected = false;
  String _statusMessage = 'Ready';
  
  // Getters
  bool get isRecording => _isRecording;
  bool get isServerConnected => _isServerConnected;
  String get statusMessage => _statusMessage;
  AudioService get audioService => _audioService;
  
  AppState() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    // Connect to WebSocket
    await _connectWebSocket();
    
    // Listen to audio service changes
    _audioService.addListener(_onAudioServiceChanged);
  }
  
  Future<void> _connectWebSocket() async {
    _isServerConnected = await _audioService.webSocketService.connect();
    _updateStatusMessage();
    notifyListeners();
  }
  
  void _onAudioServiceChanged() {
    final wasRecording = _isRecording;
    _isRecording = _audioService.isRecording;
    
    if (wasRecording != _isRecording) {
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
      await _connectWebSocket();
      if (!_isServerConnected) {
        _statusMessage = 'Cannot start: WebSocket not connected';
        notifyListeners();
        return;
      }
    }
    
    _statusMessage = 'Starting recording...';
    notifyListeners();
    
    // Start session via WebSocket
    await _audioService.webSocketService.startSession();
    
    // Start audio recording
    final recordingStarted = await _audioService.startRecording();
    if (!recordingStarted) {
      _statusMessage = 'Failed to start recording - Check permissions';
      notifyListeners();
      return;
    }
    
    _statusMessage = 'Recording started successfully';
    notifyListeners();
  }
  
  Future<void> stopRecording() async {
    _statusMessage = 'Stopping recording...';
    notifyListeners();
    
    // Stop audio recording
    await _audioService.stopRecording();
    
    // End session via WebSocket
    await _audioService.webSocketService.endSession();
    
    _statusMessage = 'Recording stopped';
    notifyListeners();
  }
  
  void showMainWindow() {
    // This will be called when user wants to show the main window
    print('Show main window requested');
  }
  
  Future<void> refreshServerConnection() async {
    await _connectWebSocket();
  }
  
  @override
  void dispose() {
    _audioService.removeListener(_onAudioServiceChanged);
    _audioService.dispose();
    super.dispose();
  }
}

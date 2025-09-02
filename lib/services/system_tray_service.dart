import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:flutter/services.dart';

class SystemTrayService {
  final SystemTray _systemTray = SystemTray();
  late Function() onStartRecording;
  late Function() onStopRecording;
  late Function() onShowWindow;
  
  bool _isRecording = false;
  
  Future<void> initSystemTray({
    required Function() onStart,
    required Function() onStop,
    required Function() onShow,
  }) async {
    onStartRecording = onStart;
    onStopRecording = onStop;
    onShowWindow = onShow;
    
    // Initialize system tray
    await _systemTray.initSystemTray(
      title: "Meeting Recorder",
      iconPath: _isRecording 
        ? 'assets/icons/mic_on.png' 
        : 'assets/icons/mic_off.png',
    );
    
    // Set up context menu
    await _setupContextMenu();
    
    // Set up click handlers
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        _toggleRecording();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }
  
  Future<void> _setupContextMenu() async {
    final Menu menu = Menu();
    
    await menu.buildFrom([
      MenuItemLabel(
        label: _isRecording ? 'Stop Recording' : 'Start Recording',
        onClicked: (menuItem) => _toggleRecording(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Show Window',
        onClicked: (menuItem) => onShowWindow(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (menuItem) => _quitApp(),
      ),
    ]);
    
    await _systemTray.setContextMenu(menu);
  }
  
  void _toggleRecording() {
    if (_isRecording) {
      onStopRecording();
    } else {
      onStartRecording();
    }
  }
  
  Future<void> updateRecordingState(bool isRecording) async {
    _isRecording = isRecording;
    
    // Update icon
    await _systemTray.setImage(
      _isRecording 
        ? 'assets/icons/mic_on.png' 
        : 'assets/icons/mic_off.png'
    );
    
    // Update context menu
    await _setupContextMenu();
    
    // Update tooltip
    await _systemTray.setToolTip(
      _isRecording ? 'Recording in progress...' : 'Click to start recording'
    );
  }
  
  void _quitApp() {
    SystemNavigator.pop();
  }
  
  Future<void> dispose() async {
    await _systemTray.destroy();
  }
}

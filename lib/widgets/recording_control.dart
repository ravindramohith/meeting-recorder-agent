import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class RecordingControl extends StatelessWidget {
  const RecordingControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Title
              const Text(
                'Meeting Recorder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Recording Button
              GestureDetector(
                onTap: () async {
                  if (appState.isRecording) {
                    await appState.stopRecording();
                  } else {
                    await appState.startRecording();
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appState.isRecording ? Colors.red : Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: (appState.isRecording ? Colors.red : Colors.blue)
                            .withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    appState.isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Recording Status
              if (appState.isRecording) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              
              // Status Message
              Text(
                appState.statusMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: appState.isServerConnected 
                    ? Colors.green.shade700 
                    : Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Server Status & Refresh Button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appState.isServerConnected 
                        ? Colors.green 
                        : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appState.isServerConnected ? 'Server Online' : 'Server Offline',
                    style: TextStyle(
                      fontSize: 11,
                      color: appState.isServerConnected 
                        ? Colors.green.shade700 
                        : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => appState.refreshServerConnection(),
                    child: Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quick Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuickAction(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      // TODO: Open settings
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAction(
                    icon: Icons.close,
                    label: 'Hide',
                    onTap: () {
                      // Hide window (keep running in background)
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

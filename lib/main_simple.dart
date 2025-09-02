import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'widgets/recording_control.dart';

void main() {
  runApp(const MeetingRecorderApp());
}

class MeetingRecorderApp extends StatelessWidget {
  const MeetingRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Meeting Recorder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const CompactRecorderWindow(),
      ),
    );
  }
}

class CompactRecorderWindow extends StatelessWidget {
  const CompactRecorderWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Container(
            width: 300,
            height: 120,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appState.isRecording ? Colors.red : Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: (appState.isRecording ? Colors.red : Colors.blue)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        appState.isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Status Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appState.isRecording ? 'Recording...' : 'Ready',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: appState.isRecording ? Colors.red : Colors.black87,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          appState.statusMessage,
                          style: TextStyle(
                            fontSize: 11,
                            color: appState.isServerConnected 
                              ? Colors.green.shade700 
                              : Colors.red.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Server Status Indicator
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appState.isServerConnected 
                                  ? Colors.green 
                                  : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'localhost:5000',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Settings Button
                  GestureDetector(
                    onTap: () {
                      // TODO: Open settings or hide window
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

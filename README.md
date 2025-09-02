# Meeting Recorder Agent

A minimal macOS desktop application that records meeting audio and sends it to a FastAPI server for transcription processing.

## Features

- 🎙️ **Minimal Interface**: Clean, compact window similar to Supercut AI
- 🔴 **One-Click Recording**: Simple start/stop recording with visual feedback
- 🌐 **Real-time Streaming**: Sends audio chunks to FastAPI server every 10 seconds
- 📊 **Server Status**: Live connection status to localhost:5000
- 🔒 **Privacy-First**: All audio processing happens locally

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   FastAPI Server │    │ Elasticsearch   │
│   (macOS UI)    │───▶│  (localhost:5000)│───▶│   Database      │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Setup Instructions

### 1. Start the FastAPI Server

```bash
# Navigate to the project root
cd /Users/ravindramohithp/flutter-dev

# Install Python dependencies
pip install -r requirements.txt

# Start the FastAPI server
python fastapi_audio_server.py
```

The server will start on `http://localhost:5000`

### 2. Run the Flutter App

```bash
# Navigate to the Flutter app directory
cd meeting_recorder_agent

# Get Flutter dependencies
flutter pub get

# Run the macOS app
flutter run -d macos
```

## Usage

1. **Start Recording**: Click the blue microphone button
2. **Stop Recording**: Click the red stop button when recording
3. **Server Status**: Green dot indicates FastAPI server is connected
4. **Refresh**: Click the refresh icon to check server connection

## API Endpoints

The FastAPI server provides these endpoints:

- `POST /start-session` - Start a new recording session
- `POST /audio-chunk` - Receive audio chunks from the app
- `POST /end-session` - End recording session and process audio
- `GET /status` - Check server status
- `POST /transcribe` - Transcribe complete audio files

## Permissions Required

The app requires the following macOS permissions:
- **Microphone Access**: To record audio
- **Network Access**: To send data to FastAPI server

## Development Notes

### Project Structure
```
lib/
├── main.dart                 # Main app entry point
├── providers/
│   └── app_state.dart       # Global app state management
├── services/
│   ├── audio_service.dart   # Audio recording functionality
│   └── network_service.dart # HTTP communication with FastAPI
└── widgets/
    └── recording_control.dart # UI components
```

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **record**: Audio recording plugin
- **dio**: HTTP client for API communication
- **provider**: State management
- **permission_handler**: macOS permissions

## Troubleshooting

### Common Issues

1. **"Server Offline" Error**
   - Ensure FastAPI server is running on localhost:5000
   - Check firewall settings
   - Verify server logs for errors

2. **"Permission Denied" for Microphone**
   - Grant microphone access in System Preferences > Security & Privacy
   - Restart the app after granting permissions

3. **Recording Not Starting**
   - Check microphone permissions
   - Ensure no other apps are using the microphone
   - Check server connection status

### Logs
- Flutter app logs: Check Xcode console or terminal output
- FastAPI server logs: Check terminal where server is running

## Future Enhancements

- [ ] Add transcription integration (Whisper, AssemblyAI, etc.)
- [ ] Implement proper system tray functionality
- [ ] Add keyboard shortcuts for recording control
- [ ] Support for different audio formats
- [ ] Meeting platform integration (Zoom, Teams)
- [ ] Automatic meeting detection
- [ ] Speaker diarization
- [ ] Real-time transcript display

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on macOS
5. Submit a pull request

## License

MIT License - see LICENSE file for details
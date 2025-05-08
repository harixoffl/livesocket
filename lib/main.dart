import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(const MaterialApp(home: WebRTCVideoStream()));
}

class WebRTCVideoStream extends StatefulWidget {
  const WebRTCVideoStream({super.key});

  @override
  _WebRTCVideoStreamState createState() => _WebRTCVideoStreamState();
}

class _WebRTCVideoStreamState extends State<WebRTCVideoStream> {
  late RTCPeerConnection _peerConnection;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _remoteStream;

  @override
  void initState() {
    super.initState();
    _initializeWebRTC();
  }

  Future<void> _initializeWebRTC() async {
    await _remoteRenderer.initialize();

    // WebRTC Configuration
    Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19307'},
      ],
    };

    _peerConnection = await createPeerConnection(config);

    // Listen for remote track (video stream)
    _peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteStream = event.streams.first;
          _remoteRenderer.srcObject = _remoteStream;
        });
      }
    };

    // Replace with your WebRTC signaling method (e.g., WebSockets)
    _connectToSignalingServer();
  }

  void _connectToSignalingServer() async {
    // Send Offer to WebRTC server
    RTCSessionDescription offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    // Send `offer.sdp` to your WebRTC signaling server
    // Get answer SDP from server and setRemoteDescription(answer)
  }

  @override
  void dispose() {
    _peerConnection.close();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("WebRTC Video Stream")), body: Center(child: _remoteStream != null ? RTCVideoView(_remoteRenderer) : const CircularProgressIndicator()));
  }
}

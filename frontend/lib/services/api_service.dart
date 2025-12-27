import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  String _baseUrl = 'http://10.0.2.2:8000';
  Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  void setBaseUrl(String url) {
    if (!url.startsWith('http')) {
      url = 'http://$url';
    }
    _baseUrl = url;
    _dio.options.baseUrl = url;
    print("API Base URL updated to: $_baseUrl");
  }

  String get baseUrl => _baseUrl;

  WebSocketChannel? _channel;

  Future<void> startProcessing(List<String> links, String? apiKey) async {
    try {
      await _dio.post(
        '/start_processing',
        data: {"links": links, "api_key": apiKey},
      );
    } catch (e) {
      throw Exception('Failed to start processing: $e');
    }
  }

  Future<Map<String, dynamic>> getProgress() async {
    try {
      final response = await _dio.get('/progress');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get progress: $e');
    }
  }

  Stream<dynamic> connectWebSocket() {
    // 1. Clean and Parse Base URL
    var cleanUrl = _baseUrl.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    // Ensure scheme exists
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final uri = Uri.parse(cleanUrl);

    // 2. Determine WebSocket Scheme
    // Force WSS for Render or HTTPS
    String wsScheme = 'ws';
    if (uri.scheme == 'https' || cleanUrl.contains('onrender.com')) {
      wsScheme = 'wss';
    }

    // 3. Construct WS URL
    // If it's Render or standard HTTPS ports, avoid explicit port
    String wsUrl;
    final port = uri.port;

    if (wsScheme == 'wss') {
      // For WSS, only include port if it's NOT 443 and NOT 0
      if (port != 443 && port != 0) {
        wsUrl = '$wsScheme://${uri.host}:$port/ws';
      } else {
        wsUrl = '$wsScheme://${uri.host}/ws';
      }
    } else {
      // For WS (local), include port if it's NOT 80 and NOT 0
      if (port != 80 && port != 0) {
        wsUrl = '$wsScheme://${uri.host}:$port/ws';
      } else {
        wsUrl = '$wsScheme://${uri.host}/ws';
      }
    }

    print("Connecting to WebSocket: $wsUrl");
    final wsUri = Uri.parse(wsUrl);
    _channel = WebSocketChannel.connect(wsUri);
    return _channel!.stream;
  }

  void disconnect() {
    _channel?.sink.close();
  }
}

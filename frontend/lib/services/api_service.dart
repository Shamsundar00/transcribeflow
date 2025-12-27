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

  Stream<dynamic> connectWebSocket() {
    // Convert http/https to ws/wss
    final uri = Uri.parse(_baseUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final wsUrl = '$wsScheme://${uri.host}:${uri.port}/ws';

    print("Connecting to WebSocket: $wsUrl");
    final wsUri = Uri.parse(wsUrl);
    _channel = WebSocketChannel.connect(wsUri);
    return _channel!.stream;
  }

  void disconnect() {
    _channel?.sink.close();
  }
}

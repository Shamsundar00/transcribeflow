import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final testUrl = "https://www.instagram.com/reel/C5p2Z2_y5vH/";

  print("Testing Cobalt API for: $testUrl");

  try {
    final response = await http.post(
      Uri.parse('https://co.wuk.sh/api/json'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"url": testUrl, "vQuality": "720"}),
    );

    print("Status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response: $data");
      if (data['url'] != null) {
        print("SUCCESS! Video Stream URL: ${data['url']}");
      } else {
        print("Failed to get URL from Cobalt.");
      }
    } else {
      print("HTTP Error: ${response.body}");
    }
  } catch (e) {
    print("API Error: $e");
  }
}

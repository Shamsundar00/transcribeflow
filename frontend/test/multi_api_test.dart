import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() async {
  final testUrl = "https://www.instagram.com/reel/C5p2Z2_y5vH/";

  // Cobalt (original & mirror)
  await testCobalt(testUrl, "https://co.wuk.sh/api/json");
  await testCobalt(testUrl, "https://api.cobalt.tools/api/json");
}

Future<void> testCobalt(String url, String apiUrl) async {
  print("\nTesting Cobalt: $apiUrl");
  try {
    final client = http.Client();
    final request = http.Request('POST', Uri.parse(apiUrl))
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0',
      })
      ..body = jsonEncode({"url": url, "vQuality": "720"});

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    print("Status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['url'] != null) {
        print("SUCCESS! Video Stream URL: ${data['url']}");
      } else {
        print("Failed: $data");
      }
    } else {
      print("Fail: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

import 'package:http/http.dart' as http;

void main() async {
  final testUrl =
      "https://www.instagram.com/reel/C5p2Z2_y5vH/"; // Example existing reel

  print("Testing scrape for: $testUrl");

  try {
    final response = await http.get(
      Uri.parse(testUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    );

    if (response.statusCode == 200) {
      final html = response.body;

      // Look for og:video
      final ogVideoRegex = RegExp(
        r'<meta property="og:video" content="([^"]+)"',
      );
      final match = ogVideoRegex.firstMatch(html);

      if (match != null) {
        print("SUCCESS! Found video URL: ${match.group(1)}");
      } else {
        print("FAILED to find og:video tag.");
        print("HTML Preview: ${html.substring(0, 500)}...");
      }
    } else {
      print("HTTP Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Scrape Error: $e");
  }
}

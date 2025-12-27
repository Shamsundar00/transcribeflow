import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionManager {
  // Current app version - UPDATE THIS when you release a new version
  static const String currentVersion = '1.0.0';

  // GitHub raw URL to your version.json file
  // Format: https://raw.githubusercontent.com/{username}/{repo}/main/version.json
  static const String versionCheckUrl =
      'https://raw.githubusercontent.com/Shamsundar00/transcribeflow/main/version.json';

  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final dio = Dio();
      final response = await dio.get(versionCheckUrl);

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final latestVersion = data['version'] as String;
        final downloadUrl = data['download_url'] as String;
        final changelog =
            data['changelog'] as String? ?? 'Bug fixes and improvements';

        if (_isNewerVersion(latestVersion, currentVersion)) {
          return {
            'hasUpdate': true,
            'latestVersion': latestVersion,
            'currentVersion': currentVersion,
            'downloadUrl': downloadUrl,
            'changelog': changelog,
          };
        }
      }
    } catch (e) {
      print('Version check failed: $e');
    }
    return null;
  }

  static bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A192F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF00C6FB), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.system_update, color: Color(0xFF00C6FB)),
            const SizedBox(width: 8),
            const Text(
              'Update Available!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${updateInfo['latestVersion']} is available.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'You have: ${updateInfo['currentVersion']}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's New:",
                    style: TextStyle(
                      color: Color(0xFF00C6FB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    updateInfo['changelog'],
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final url = Uri.parse(updateInfo['downloadUrl']);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C6FB),
              foregroundColor: Colors.black,
            ),
            child: const Text('Download Update'),
          ),
        ],
      ),
    );
  }
}

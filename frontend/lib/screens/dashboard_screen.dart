import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers.dart';
import '../services/api_service.dart';
import '../widgets/cyber_terminal.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    // Listen to WebSocket
    ref.read(apiServiceProvider).connectWebSocket().listen((message) {
      if (message == null) return;
      try {
        final data = jsonDecode(message);
        if (data['type'] == 'log') {
          ref.read(logsProvider.notifier).addLog(data);
        } else if (data['type'] == 'result') {
          ref.read(resultsProvider.notifier).setResult(data['data']);
        }
      } catch (e) {
        print("WS Error: $e");
      }
    });
  }

  void _processLink() async {
    final link = _linkController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (link.isEmpty) return;

    ref.read(logsProvider.notifier).clear();
    try {
      await ref.read(apiServiceProvider).startProcessing([
        link,
      ], apiKey.isNotEmpty ? apiKey : null);
    } catch (e) {
      ref.read(logsProvider.notifier).addLog({
        'message': 'Error starting process: $e',
        'level': 'error',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              backgroundColor: const Color(0xFF0A192F),
              selectedIndex: _navIndex,
              onDestinationSelected: (val) => setState(() => _navIndex = val),
              selectedIconTheme: const IconThemeData(color: Color(0xFF00C6FB)),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.archive),
                  label: Text('Archives'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1550751827-4bd374c3f58b",
                  ), // Cyberpunk placeholder
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _navIndex == 2
                    ? _buildSettings()
                    : _navIndex == 1
                    ? _buildArchives()
                    : _buildDashboard(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _navIndex,
              onTap: (val) => setState(() => _navIndex = val),
              backgroundColor: const Color(0xFF0A192F),
              selectedItemColor: const Color(0xFF00C6FB),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive),
                  label: 'Archives',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            )
          : null,
    );
  }

  // --- Helper Methods ---

  Widget _buildInputSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 180,
      borderRadius: 16,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(
        colors: [const Color(0xFF00C6FB).withOpacity(0.5), Colors.transparent],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _linkController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Target URL',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link, color: Color(0xFF00C6FB)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'API Key (Optional)',
                      prefixIcon: Icon(Icons.vpn_key, color: Color(0xFFFF00CC)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _processLink,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("INITIATE SEQUENCE"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C6FB),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildResultPanel() {
    final result = ref.watch(resultsProvider);

    if (result == null) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 48, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              "Awaiting Data...",
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFF00CC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF00CC).withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TRANSCRIPT READY",
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFFFF00CC),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result['preview'] ?? 'No preview available.',
                style: const TextStyle(color: Colors.white70),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchFile(result['files']?['pdf']),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("PDF"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchFile(result['files']?['docx']),
                      icon: const Icon(Icons.description),
                      label: const Text("DOCX"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().slideX(begin: 0.2),
      ],
    );
  }

  void _launchFile(String? path) async {
    if (path == null) return;
    // Now using HTTP URLs instead of file:// paths
    final Uri uri = Uri.parse(path);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("Could not launch $uri");
    }
  }

  // --- Navigation Pages ---

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TRANSCRIBE FLOW // ENTERPRISE",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00C6FB),
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn().slideY(),
        const SizedBox(height: 24),
        _buildInputSection(),
        const SizedBox(height: 24),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 300, child: CyberTerminal()),
                      const SizedBox(height: 16),
                      _buildResultPanel(),
                    ],
                  ),
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: const CyberTerminal()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildResultPanel()),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArchives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ARCHIVES",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00C6FB),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.archive_outlined, size: 80, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  "No transcriptions saved yet.",
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your completed transcriptions will appear here.",
                  style: GoogleFonts.outfit(
                    color: Colors.white30,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    // Controller refreshed on build to show current URL
    final serverUrlController = TextEditingController(
      text: ref.watch(apiServiceProvider).baseUrl,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SYSTEM CONFIGURATION",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00C6FB),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        GlassmorphicContainer(
          width: double.infinity,
          height: 300,
          borderRadius: 16,
          blur: 15,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              const Color(0xFF00C6FB).withOpacity(0.5),
              Colors.transparent,
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BACKEND CONNECTION",
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: serverUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'http://192.168.1.X:8000',
                    prefixIcon: Icon(Icons.dns, color: Color(0xFF00C6FB)),
                    helperText:
                        "Use 10.0.2.2 for Emulator, or local IP/Ngrok for Mobile",
                    helperStyle: TextStyle(color: Colors.white30),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final url = serverUrlController.text.trim();
                      if (url.isNotEmpty) {
                        ref.read(apiServiceProvider).setBaseUrl(url);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Server URL updated to $url")),
                        );
                        // Reconnect WS
                        ref.read(apiServiceProvider).disconnect();
                        _connectWebSocket();
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("SAVE CONFIGURATION"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C6FB),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers.dart';

class CyberTerminal extends ConsumerWidget {
  const CyberTerminal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider);
    final scrollController = ScrollController();

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFF0A192F,
        ).withOpacity(0.95), // Opaque enough for contrast
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00C6FB).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C6FB).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Color(0xFF00C6FB), size: 20),
              const SizedBox(width: 8),
              Text(
                "SYSTEM TERMINAL // LISTENING...",
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF00C6FB),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF00C6FB), height: 20),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final message = log['message'] ?? '';
                final level = log['level'] ?? 'info';

                Color logColor = Colors.greenAccent;
                if (level == 'error') logColor = Colors.redAccent;
                if (level == 'warning') logColor = Colors.orangeAccent;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "> $message",
                    style: GoogleFonts.jetBrainsMono(
                      color: logColor,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

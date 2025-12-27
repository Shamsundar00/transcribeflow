import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// State for Logs
class LogsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [];
  }

  void addLog(Map<String, dynamic> log) {
    state = [...state, log];
  }

  void clear() {
    state = [];
  }
}

final logsProvider = NotifierProvider<LogsNotifier, List<Map<String, dynamic>>>(
  LogsNotifier.new,
);

// State for Results
class ResultsNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() {
    return null;
  }

  void setResult(Map<String, dynamic>? result) {
    state = result;
  }

  void clear() {
    state = null;
  }
}

final resultsProvider =
    NotifierProvider<ResultsNotifier, Map<String, dynamic>?>(
      ResultsNotifier.new,
    );

import 'game_settings.dart';
import 'player_score.dart';

class MatchHistoryEntry {
  const MatchHistoryEntry({
    required this.id,
    required this.date,
    required this.settings,
    required this.winnerName,
    required this.finalScores,
  });

  final String id;
  final DateTime date;
  final GameSettings settings;
  final String winnerName;
  final List<PlayerScore> finalScores;

  int get totalTurns => finalScores.isEmpty
      ? 0
      : finalScores.map((p) => p.turns.length).reduce((a, b) => a > b ? a : b);
}

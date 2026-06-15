import 'dart:math' as math;
import 'dart_hit.dart';

class PlayerScore {
  const PlayerScore({
    required this.name,
    required this.avatarColorValue,
    required this.remaining,
    required this.totalScored,
    required this.turns,
    required this.isWinner,
  });

  final String name;
  final int avatarColorValue; // Hex ARGB representation
  final int remaining;
  final int totalScored;
  final List<List<DartHit>> turns;
  final bool isWinner;

  double get average {
    if (turns.isEmpty) return 0.0;
    return totalScored / turns.length;
  }

  int get highestTurnScore {
    if (turns.isEmpty) return 0;
    return turns
        .map((t) => t.fold<int>(0, (sum, hit) => sum + hit.score))
        .reduce(math.max);
  }

  int get count180s {
    return turns
        .where((t) => t.fold<int>(0, (sum, hit) => sum + hit.score) == 180)
        .length;
  }

  int get count140plus {
    return turns.where((t) {
      final s = t.fold<int>(0, (sum, hit) => sum + hit.score);
      return s >= 140 && s < 180;
    }).length;
  }

  int get count100plus {
    return turns.where((t) {
      final s = t.fold<int>(0, (sum, hit) => sum + hit.score);
      return s >= 100 && s < 140;
    }).length;
  }

  int get totalThrows => turns.expand((t) => t).length;

  int get doubleHits => turns
      .expand((t) => t)
      .where(
        (hit) => hit.band == SegmentBand.double || hit.band == SegmentBand.bull,
      )
      .length;

  int get tripleHits => turns
      .expand((t) => t)
      .where((hit) => hit.band == SegmentBand.triple)
      .length;

  PlayerScore copyWith({
    String? name,
    int? avatarColorValue,
    int? remaining,
    int? totalScored,
    List<List<DartHit>>? turns,
    bool? isWinner,
  }) {
    return PlayerScore(
      name: name ?? this.name,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      remaining: remaining ?? this.remaining,
      totalScored: totalScored ?? this.totalScored,
      turns: turns ?? this.turns,
      isWinner: isWinner ?? this.isWinner,
    );
  }
}

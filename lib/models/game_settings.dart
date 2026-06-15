enum GameMode { x01, countUp }

enum OutRule { singleOut, doubleOut, masterOut }

class GameSettings {
  const GameSettings({
    required this.mode,
    required this.startingScore,
    required this.outRule,
  });

  final GameMode mode;
  final int startingScore;
  final OutRule outRule;

  GameSettings copyWith({
    GameMode? mode,
    int? startingScore,
    OutRule? outRule,
  }) {
    return GameSettings(
      mode: mode ?? this.mode,
      startingScore: startingScore ?? this.startingScore,
      outRule: outRule ?? this.outRule,
    );
  }
}

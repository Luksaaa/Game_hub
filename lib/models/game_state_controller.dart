import 'package:flutter/material.dart';

import 'dart_hit.dart';
import 'player_score.dart';
import 'game_settings.dart';
import 'match_history.dart';
import 'user_session.dart';
import '../services/auth_repository.dart';

class PlayerProfile {
  PlayerProfile({
    required this.name,
    required this.avatarColorValue,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.totalScored = 0,
    this.totalThrows = 0,
    this.highestTurn = 0,
    this.doubleHits = 0,
    this.tripleHits = 0,
  });

  String name;
  int avatarColorValue;
  int matchesPlayed;
  int matchesWon;
  int totalScored;
  int totalThrows;
  int highestTurn;
  int doubleHits;
  int tripleHits;

  double get averageScore =>
      totalThrows == 0 ? 0.0 : (totalScored / (totalThrows / 3));
}

class GameStateController extends ChangeNotifier {
  GameStateController() {
    _initializeServices();

    // Initialize default profiles
    _profiles.addAll([
      PlayerProfile(name: 'Marko', avatarColorValue: 0xFF0F8B6B),
      PlayerProfile(name: 'Luka', avatarColorValue: 0xFFC7352F),
      PlayerProfile(name: 'Borna', avatarColorValue: 0xFFF6D77B),
    ]);

    // Setup initial match
    _resetMatch();
  }

  final AuthRepository _authRepository = AuthRepository();

  Future<void> _initializeServices() async {
    await _authRepository.initialize();
    _cloudFeaturesAvailable = _authRepository.firebaseReady;
    notifyListeners();
  }

  // Configuration options
  final List<int> scoreOptions = const [301, 501, 701];

  // Navigation tab
  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  UserSession _currentUser = const UserSession(
    id: 'guest',
    displayName: 'Guest',
    email: null,
    avatarColorValue: 0xFF0F8B6B,
    isGuest: true,
  );
  UserSession get currentUser => _currentUser;

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  bool _cloudFeaturesAvailable = false;
  bool get cloudFeaturesAvailable => _cloudFeaturesAvailable;

  String? _accountMessage;
  String? get accountMessage => _accountMessage;

  void changeTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  // Player Profiles registry (for lifetime/session stats)
  final List<PlayerProfile> _profiles = [];
  List<PlayerProfile> get profiles => List.unmodifiable(_profiles);

  final List<PlayerGroupPreset> _playerGroups = [
    PlayerGroupPreset(
      id: 'default-home-group',
      name: 'Home darts crew',
      playerNames: const ['Marko', 'Luka', 'Borna'],
      ownerUserId: 'guest',
      isShared: false,
    ),
  ];
  List<PlayerGroupPreset> get playerGroups => List.unmodifiable(_playerGroups);

  String _selectedPlayerGroupId = 'default-home-group';
  String get selectedPlayerGroupId => _selectedPlayerGroupId;

  PlayerGroupPreset? get selectedPlayerGroup {
    for (final group in _playerGroups) {
      if (group.id == _selectedPlayerGroupId) {
        return group;
      }
    }
    return _playerGroups.isEmpty ? null : _playerGroups.first;
  }

  final List<FollowedUser> _following = [];
  List<FollowedUser> get following => List.unmodifiable(_following);

  // Active game settings
  GameSettings _settings = const GameSettings(
    mode: GameMode.x01,
    startingScore: 501,
    outRule: OutRule.doubleOut,
  );
  GameSettings get settings => _settings;

  // Active match state
  List<PlayerScore> _players = [];
  List<PlayerScore> get players => _players;

  final List<DartHit> _currentTurn = [];
  List<DartHit> get currentTurn => _currentTurn;

  int _currentPlayerIndex = 0;
  int get currentPlayerIndex => _currentPlayerIndex;

  String? _matchMessage;
  String? get matchMessage => _matchMessage;

  PlayerScore get currentPlayer => _players[_currentPlayerIndex];
  bool get matchFinished => _players.any((p) => p.isWinner);

  // Match history list
  final List<MatchHistoryEntry> _matchHistory = [];
  List<MatchHistoryEntry> get matchHistory => List.unmodifiable(_matchHistory);

  // Search Results & state
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<PlayerProfile> get filteredProfiles {
    if (_searchQuery.isEmpty) return _profiles;
    return _profiles
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Account, player groups & following
  Future<void> signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    _isSigningIn = true;
    _accountMessage = null;
    notifyListeners();

    final result = await _authRepository.signInWithGoogle();
    if (result.isSuccess) {
      _currentUser = result.session!;
      _accountMessage = 'Signed in as ${_currentUser.displayName}.';
    } else {
      _accountMessage = result.errorMessage;
    }

    _isSigningIn = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = const UserSession(
      id: 'guest',
      displayName: 'Guest',
      email: null,
      avatarColorValue: 0xFF0F8B6B,
      isGuest: true,
    );
    _accountMessage = 'Signed out. Guest mode is active.';
    notifyListeners();
  }

  void updateUserProfile(String displayName, int avatarColorValue) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _currentUser = _currentUser.copyWith(
      displayName: trimmed,
      avatarColorValue: avatarColorValue,
    );
    _accountMessage = _currentUser.isGuest
        ? 'Guest profile updated locally.'
        : 'Profile updated for this session.';
    notifyListeners();
  }

  void createPlayerGroup(String name, List<String> playerNames) {
    final cleanName = name.trim();
    final cleanPlayers = playerNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    if (cleanName.isEmpty || cleanPlayers.isEmpty) {
      return;
    }

    final group = PlayerGroupPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: cleanName,
      playerNames: cleanPlayers,
      ownerUserId: _currentUser.id,
      isShared: false,
    );
    _playerGroups.add(group);
    _selectedPlayerGroupId = group.id;
    _applyPlayerGroup(group);
    _authRepository.savePlayerGroup(group).catchError((Object error) {
      _accountMessage = 'Could not sync group to Firebase: $error';
    });
    notifyListeners();
  }

  void selectPlayerGroup(String groupId) {
    final group = _playerGroups.where((g) => g.id == groupId).firstOrNull;
    if (group == null) {
      return;
    }

    _selectedPlayerGroupId = group.id;
    _applyPlayerGroup(group);
    notifyListeners();
  }

  void sharePlayerGroup(String groupId) {
    final index = _playerGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) {
      return;
    }

    final shared = _playerGroups[index].copyWith(isShared: true);
    _playerGroups[index] = shared;
    _authRepository.sharePlayerGroup(shared).catchError((Object error) {
      _accountMessage = 'Could not share group to Firebase: $error';
    });
    _accountMessage = _currentUser.isGuest
        ? 'Sign in to sync shared groups to Firebase.'
        : 'Group shared with followers.';
    notifyListeners();
  }

  void followUser(String displayNameOrHandle) {
    final value = displayNameOrHandle.trim();
    if (value.isEmpty) {
      return;
    }

    final normalized = value.startsWith('@') ? value.substring(1) : value;
    final id = normalized.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    if (_following.any((user) => user.id == id)) {
      return;
    }

    final followedUser = FollowedUser(
      id: id,
      displayName: normalized,
      handle: '@$id',
    );
    _following.add(followedUser);
    _authRepository
        .followUser(ownerUserId: _currentUser.id, followedUser: followedUser)
        .catchError((Object error) {
          _accountMessage = 'Could not sync following to Firebase: $error';
        });
    _accountMessage = _currentUser.isGuest
        ? 'Following saved for this guest session.'
        : 'Following ${followedUser.displayName}.';
    notifyListeners();
  }

  void _applyPlayerGroup(PlayerGroupPreset group) {
    for (final playerName in group.playerNames) {
      if (!_profiles.any(
        (p) => p.name.toLowerCase() == playerName.toLowerCase(),
      )) {
        _profiles.add(
          PlayerProfile(
            name: playerName,
            avatarColorValue: _colorForName(playerName),
          ),
        );
      }
    }

    _players = group.playerNames.map((name) {
      final profile = _profiles.firstWhere(
        (p) => p.name.toLowerCase() == name.toLowerCase(),
        orElse: () =>
            PlayerProfile(name: name, avatarColorValue: _colorForName(name)),
      );
      return PlayerScore(
        name: profile.name,
        avatarColorValue: profile.avatarColorValue,
        remaining: _settings.mode == GameMode.x01 ? _settings.startingScore : 0,
        totalScored: 0,
        turns: const [],
        isWinner: false,
      );
    }).toList();
    _currentTurn.clear();
    _currentPlayerIndex = 0;
    _matchMessage = 'Loaded group: ${group.name}.';
  }

  int _colorForName(String name) {
    const colors = [
      0xFF0F8B6B,
      0xFFC7352F,
      0xFFF6D77B,
      0xFF1A6EB4,
      0xFF8E44AD,
      0xFFE67E22,
    ];
    final hash = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return colors[hash % colors.length];
  }

  List<MatchHistoryEntry> get filteredHistory {
    if (_searchQuery.isEmpty) return _matchHistory;
    return _matchHistory.where((m) {
      final query = _searchQuery.toLowerCase();
      final dateStr = '${m.date.day}.${m.date.month}.${m.date.year}';
      return m.winnerName.toLowerCase().contains(query) ||
          m.settings.mode.name.toLowerCase().contains(query) ||
          dateStr.contains(query) ||
          m.finalScores.any((p) => p.name.toLowerCase().contains(query));
    }).toList();
  }

  // Manage Profiles & Players list
  void addPlayerProfile(String name, int colorValue) {
    final existing = _profiles.any(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
    if (existing) return; // Prevent duplicate profile names

    final newProfile = PlayerProfile(name: name, avatarColorValue: colorValue);
    _profiles.add(newProfile);

    // If not in a finished game, add to the active match
    if (!matchFinished) {
      _players.add(
        PlayerScore(
          name: name,
          avatarColorValue: colorValue,
          remaining: _settings.mode == GameMode.x01
              ? _settings.startingScore
              : 0,
          totalScored: 0,
          turns: const [],
          isWinner: false,
        ),
      );
    }
    notifyListeners();
  }

  void deletePlayer(int index) {
    if (_players.length <= 1) return; // Must have at least 1 player

    final removedPlayer = _players.removeAt(index);
    if (_currentPlayerIndex >= _players.length) {
      _currentPlayerIndex = 0;
    }
    _currentTurn.clear();
    _matchMessage = 'Removed ${removedPlayer.name} from current match.';
    notifyListeners();
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final player = _players.removeAt(oldIndex);
    _players.insert(newIndex, player);

    // Keep active player selection pointing to the correct person
    if (_currentPlayerIndex == oldIndex) {
      _currentPlayerIndex = newIndex;
    } else if (oldIndex < _currentPlayerIndex &&
        newIndex >= _currentPlayerIndex) {
      _currentPlayerIndex--;
    } else if (oldIndex > _currentPlayerIndex &&
        newIndex <= _currentPlayerIndex) {
      _currentPlayerIndex++;
    }
    notifyListeners();
  }

  void updatePlayerProfile(String oldName, String newName, int colorValue) {
    final pIndex = _profiles.indexWhere((p) => p.name == oldName);
    if (pIndex != -1) {
      _profiles[pIndex].name = newName;
      _profiles[pIndex].avatarColorValue = colorValue;
    }

    // Also update in the active game if present
    for (int i = 0; i < _players.length; i++) {
      if (_players[i].name == oldName) {
        _players[i] = _players[i].copyWith(
          name: newName,
          avatarColorValue: colorValue,
        );
      }
    }
    notifyListeners();
  }

  // Scoring Logic & Actions
  void handleHit(DartHit hit) {
    if (matchFinished || _currentTurn.length == 3) {
      return;
    }

    _currentTurn.add(hit);
    _matchMessage = null;
    notifyListeners();
  }

  void undoLastHit() {
    if (_currentTurn.isEmpty || matchFinished) {
      return;
    }

    _currentTurn.removeLast();
    _matchMessage = null;
    notifyListeners();
  }

  void addMiss() {
    handleHit(
      const DartHit(
        label: 'MISS',
        score: 0,
        band: SegmentBand.miss,
        dx: 0,
        dy: -0.99,
      ),
    );
  }

  void commitTurn() {
    if (_currentTurn.isEmpty) {
      return;
    }

    final player = currentPlayer;
    final turnScore = _currentTurn.fold<int>(
      0,
      (total, hit) => total + hit.score,
    );
    final nextTurns = [...player.turns, List<DartHit>.from(_currentTurn)];

    if (_settings.mode == GameMode.countUp) {
      _players[_currentPlayerIndex] = player.copyWith(
        remaining: player.remaining + turnScore,
        totalScored: player.totalScored + turnScore,
        turns: nextTurns,
      );
      _matchMessage = '${player.name} scored $turnScore.';
      _advanceTurn();
      notifyListeners();
      return;
    }

    // X01 logic
    final nextRemaining = player.remaining - turnScore;
    final finishingHit = _currentTurn.last;
    final hasValidFinish = _isValidFinish(nextRemaining, finishingHit);
    final isBust =
        nextRemaining < 0 ||
        nextRemaining == 1 ||
        (nextRemaining == 0 && !hasValidFinish);

    if (isBust) {
      _players[_currentPlayerIndex] = player.copyWith(turns: nextTurns);
      _matchMessage =
          '${player.name} busts. Score stays at ${player.remaining}.';

      // Update profiles stats for throw (bust throws still count as throws)
      _updateProfileStatsForPlayer(player.name, _currentTurn, 0, false);

      _advanceTurn();
      notifyListeners();
      return;
    }

    final isWinner = nextRemaining == 0;
    _players[_currentPlayerIndex] = player.copyWith(
      remaining: nextRemaining,
      totalScored: player.totalScored + turnScore,
      turns: nextTurns,
      isWinner: isWinner,
    );

    _matchMessage = isWinner
        ? '${player.name} wins with ${finishingHit.label}!'
        : '${player.name} scored $turnScore.';

    // Update profiles stats for throw
    _updateProfileStatsForPlayer(
      player.name,
      _currentTurn,
      turnScore,
      isWinner,
    );

    if (isWinner) {
      _archiveMatch();
    } else {
      _advanceTurn();
    }
    notifyListeners();
  }

  bool _isValidFinish(int remaining, DartHit hit) {
    if (remaining != 0) {
      return false;
    }

    return switch (_settings.outRule) {
      OutRule.singleOut => true,
      OutRule.doubleOut => hit.isDouble,
      OutRule.masterOut => hit.isDouble || hit.band == SegmentBand.triple,
    };
  }

  void _advanceTurn() {
    _currentTurn.clear();
    if (!matchFinished) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    }
  }

  void _updateProfileStatsForPlayer(
    String name,
    List<DartHit> turn,
    int score,
    bool wonMatch,
  ) {
    final pIndex = _profiles.indexWhere((p) => p.name == name);
    if (pIndex == -1) return;

    final profile = _profiles[pIndex];
    profile.totalThrows += turn.length;
    profile.totalScored += score;

    final turnSum = turn.fold<int>(0, (sum, hit) => sum + hit.score);
    if (turnSum > profile.highestTurn) {
      profile.highestTurn = turnSum;
    }

    for (final hit in turn) {
      if (hit.band == SegmentBand.double || hit.band == SegmentBand.bull) {
        profile.doubleHits++;
      } else if (hit.band == SegmentBand.triple) {
        profile.tripleHits++;
      }
    }

    if (wonMatch) {
      profile.matchesWon++;
    }
  }

  void _archiveMatch() {
    // Update match count for all participants
    for (final player in _players) {
      final pIndex = _profiles.indexWhere((p) => p.name == player.name);
      if (pIndex != -1) {
        _profiles[pIndex].matchesPlayed++;
      }
    }

    final entry = MatchHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      settings: _settings,
      winnerName: currentPlayer.name,
      finalScores: List.from(_players),
    );
    _matchHistory.insert(0, entry);
  }

  // Control & Settings
  void updateSettings({GameMode? mode, int? startingScore, OutRule? outRule}) {
    _settings = GameSettings(
      mode: mode ?? _settings.mode,
      startingScore: startingScore ?? _settings.startingScore,
      outRule: outRule ?? _settings.outRule,
    );
    _resetMatch();
  }

  void startNewMatch() {
    _resetMatch();
  }

  void _resetMatch() {
    // If we have no active players yet, initialize from default profiles
    if (_players.isEmpty) {
      _players = _profiles
          .map(
            (p) => PlayerScore(
              name: p.name,
              avatarColorValue: p.avatarColorValue,
              remaining: _settings.mode == GameMode.x01
                  ? _settings.startingScore
                  : 0,
              totalScored: 0,
              turns: const [],
              isWinner: false,
            ),
          )
          .toList();
    } else {
      // Re-initialize score for existing players
      _players = _players
          .map(
            (p) => PlayerScore(
              name: p.name,
              avatarColorValue: p.avatarColorValue,
              remaining: _settings.mode == GameMode.x01
                  ? _settings.startingScore
                  : 0,
              totalScored: 0,
              turns: const [],
              isWinner: false,
            ),
          )
          .toList();
    }
    _currentTurn.clear();
    _currentPlayerIndex = 0;
    _matchMessage = null;
    notifyListeners();
  }
}

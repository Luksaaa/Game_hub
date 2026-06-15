class UserSession {
  const UserSession({
    required this.id,
    required this.displayName,
    required this.email,
    required this.avatarColorValue,
    required this.isGuest,
  });

  final String id;
  final String displayName;
  final String? email;
  final int avatarColorValue;
  final bool isGuest;

  String get initials {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return isGuest ? 'G' : 'U';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  UserSession copyWith({
    String? id,
    String? displayName,
    String? email,
    int? avatarColorValue,
    bool? isGuest,
  }) {
    return UserSession(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class PlayerGroupPreset {
  const PlayerGroupPreset({
    required this.id,
    required this.name,
    required this.playerNames,
    required this.ownerUserId,
    required this.isShared,
  });

  final String id;
  final String name;
  final List<String> playerNames;
  final String ownerUserId;
  final bool isShared;

  PlayerGroupPreset copyWith({
    String? id,
    String? name,
    List<String>? playerNames,
    String? ownerUserId,
    bool? isShared,
  }) {
    return PlayerGroupPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      playerNames: playerNames ?? this.playerNames,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      isShared: isShared ?? this.isShared,
    );
  }
}

class FollowedUser {
  const FollowedUser({
    required this.id,
    required this.displayName,
    required this.handle,
  });

  final String id;
  final String displayName;
  final String handle;
}

import 'package:flutter/material.dart';

import '../models/game_state_controller.dart';
import '../models/game_settings.dart';
import '../theme/app_palette.dart';
import '../widgets/profile_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.controller, super.key});

  final GameStateController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  int _newPlayerColor = 0xFF0F8B6B; // Default emerald

  final List<int> _colorOptions = const [
    0xFF0F8B6B, // Emerald Green
    0xFFC7352F, // Crimson Red
    0xFFF6D77B, // Amber Gold
    0xFF1A6EB4, // Cobalt Blue
    0xFF8E44AD, // Amethyst Purple
    0xFFE67E22, // Pumpkin Orange
  ];

  @override
  void dispose() {
    _playerNameController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  void _showCreateGroupDialog() {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    _groupNameController.clear();
    final selectedNames = widget.controller.players
        .map((player) => player.name)
        .toSet();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: palette.border),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Player Group',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: palette.text,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: palette.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: palette.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: TextStyle(
                          color: palette.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Players',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: widget.controller.profiles.map((profile) {
                              final isSelected = selectedNames.contains(
                                profile.name,
                              );
                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: palette.primary,
                                checkColor: Colors.white,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  profile.name,
                                  style: TextStyle(
                                    color: palette.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: Color(
                                    profile.avatarColorValue,
                                  ),
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    profile.name.substring(0, 1).toUpperCase(),
                                  ),
                                ),
                                onChanged: (checked) {
                                  setModalState(() {
                                    if (checked ?? false) {
                                      selectedNames.add(profile.name);
                                    } else {
                                      selectedNames.remove(profile.name);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: palette.textMuted),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.primary,
                            ),
                            onPressed: () {
                              widget.controller.createPlayerGroup(
                                _groupNameController.text,
                                selectedNames.toList(),
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save Group'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPlayerDialog() {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    _playerNameController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: palette.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Player',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _playerNameController,
                      decoration: InputDecoration(
                        labelText: 'Player Name',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: palette.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: palette.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: TextStyle(
                        color: palette.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Avatar Color',
                      style: TextStyle(
                        color: palette.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _colorOptions.map((cVal) {
                        final isSelected = cVal == _newPlayerColor;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _newPlayerColor = cVal;
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Color(cVal),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: palette.text, width: 3)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: palette.textMuted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.primary,
                          ),
                          onPressed: () {
                            final name = _playerNameController.text.trim();
                            if (name.isNotEmpty) {
                              widget.controller.addPlayerProfile(
                                name,
                                _newPlayerColor,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Add Player'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmSettingsChange(VoidCallback onChange) {
    // If a match is already under way (some throws made), confirm first
    final hasMatchStarted = widget.controller.players.any(
      (p) => p.turns.isNotEmpty,
    );

    if (hasMatchStarted) {
      final palette = AppPalette.of(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: palette.surface,
          title: const Text('Restart Match?'),
          content: const Text(
            'Changing match settings will reset the current game state and scores. Do you wish to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: palette.textMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: palette.primary),
              onPressed: () {
                Navigator.of(context).pop();
                onChange();
              },
              child: const Text('Yes, Reset'),
            ),
          ],
        ),
      );
    } else {
      onChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final settings = widget.controller.settings;
    final players = widget.controller.players;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Match Setup',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Player Groups',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: palette.text,
                            ),
                          ),
                          Text(
                            'Pick a saved crew for this match.',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: palette.primary,
                      ),
                      tooltip: 'Create group',
                      onPressed: _showCreateGroupDialog,
                      icon: const Icon(Icons.group_add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.controller.playerGroups.map((group) {
                    final isSelected =
                        group.id == widget.controller.selectedPlayerGroupId;
                    return ChoiceChip(
                      label: Text(group.name),
                      selected: isSelected,
                      selectedColor: palette.primarySoft,
                      labelStyle: TextStyle(
                        color: isSelected ? palette.primary : palette.text,
                        fontWeight: FontWeight.w900,
                      ),
                      avatar: Icon(
                        group.isShared ? Icons.public : Icons.group,
                        size: 18,
                        color: isSelected ? palette.primary : palette.textMuted,
                      ),
                      onSelected: (_) {
                        _confirmSettingsChange(() {
                          widget.controller.selectPlayerGroup(group.id);
                        });
                      },
                    );
                  }).toList(),
                ),
                if (widget.controller.selectedPlayerGroup != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.controller.selectedPlayerGroup!.playerNames
                              .join(', '),
                          style: TextStyle(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => widget.controller.sharePlayerGroup(
                          widget.controller.selectedPlayerGroup!.id,
                        ),
                        icon: const Icon(Icons.ios_share, size: 18),
                        label: Text(
                          widget.controller.selectedPlayerGroup!.isShared
                              ? 'Shared'
                              : 'Share',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Game Mode & Rules Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(title: 'Game Mode', palette: palette),
                SegmentedButton<GameMode>(
                  segments: const [
                    ButtonSegment(value: GameMode.x01, label: Text('X01')),
                    ButtonSegment(
                      value: GameMode.countUp,
                      label: Text('Count Up'),
                    ),
                  ],
                  selected: {settings.mode},
                  onSelectionChanged: (selection) {
                    _confirmSettingsChange(() {
                      widget.controller.updateSettings(mode: selection.first);
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (settings.mode == GameMode.x01) ...[
                  _SectionTitle(title: 'Starting Score', palette: palette),
                  Wrap(
                    spacing: 8,
                    children: widget.controller.scoreOptions.map((score) {
                      final isSelected = settings.startingScore == score;
                      return ChoiceChip(
                        label: Text('$score'),
                        selected: isSelected,
                        selectedColor: palette.primarySoft,
                        labelStyle: TextStyle(
                          color: isSelected ? palette.primary : palette.text,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          _confirmSettingsChange(() {
                            widget.controller.updateSettings(
                              startingScore: score,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  _SectionTitle(title: 'Finish Rule', palette: palette),
                  SegmentedButton<OutRule>(
                    segments: const [
                      ButtonSegment(
                        value: OutRule.singleOut,
                        label: Text('Single'),
                      ),
                      ButtonSegment(
                        value: OutRule.doubleOut,
                        label: Text('Double'),
                      ),
                      ButtonSegment(
                        value: OutRule.masterOut,
                        label: Text('Master'),
                      ),
                    ],
                    selected: {settings.outRule},
                    onSelectionChanged: (selection) {
                      _confirmSettingsChange(() {
                        widget.controller.updateSettings(
                          outRule: selection.first,
                        );
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Players List & Management
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Players Lineup',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showAddPlayerDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text(
                  'Add Player',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: SizedBox(
              height: 300,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                onReorder: widget.controller.reorderPlayers,
                itemBuilder: (context, index) {
                  final player = players[index];

                  return Card(
                    key: ValueKey(player.name),
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: palette.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: palette.border),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: Color(player.avatarColorValue),
                        foregroundColor: Colors.white,
                        radius: 16,
                        child: Text(player.name.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(
                        player.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: palette.text,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to edit stats',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: palette.textMuted,
                            ),
                            onPressed: players.length > 1
                                ? () => widget.controller.deletePlayer(index)
                                : null,
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(
                              Icons.drag_handle,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Open profile dialog to view details
                        final pIndex = widget.controller.profiles.indexWhere(
                          (p) => p.name == player.name,
                        );
                        if (pIndex != -1) {
                          showDialog(
                            context: context,
                            builder: (context) => ProfileDialog(
                              profile: widget.controller.profiles[pIndex],
                              controller: widget.controller,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.palette});

  final String title;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: palette.textMuted,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

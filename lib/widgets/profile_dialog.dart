import 'package:flutter/material.dart';

import '../models/game_state_controller.dart';
import '../theme/app_palette.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({
    required this.profile,
    required this.controller,
    super.key,
  });

  final PlayerProfile profile;
  final GameStateController controller;

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  late TextEditingController _nameController;
  late int _selectedColor;

  final List<int> _colorOptions = const [
    0xFF0F8B6B, // Emerald Green
    0xFFC7352F, // Crimson Red
    0xFFF6D77B, // Amber Gold
    0xFF1A6EB4, // Cobalt Blue
    0xFF8E44AD, // Amethyst Purple
    0xFFE67E22, // Pumpkin Orange
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _selectedColor = widget.profile.avatarColorValue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final winRate = widget.profile.matchesPlayed == 0
        ? 0.0
        : (widget.profile.matchesWon / widget.profile.matchesPlayed) * 100;

    return Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Player Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: palette.text,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Edit Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Player Name',
                  labelStyle: TextStyle(color: palette.textMuted),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: palette.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: palette.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(color: palette.text, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // Color Selection
              Text(
                'Avatar Color',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _colorOptions.map((colorVal) {
                  final isSelected = colorVal == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorVal;
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: palette.text,
                                width: 3,
                              )
                            : Border.all(
                                color: Colors.transparent,
                                width: 3,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colorVal).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Statistics Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'Session Stats',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatRow(
                      label: 'Matches Played / Won',
                      value: '${widget.profile.matchesPlayed} / ${widget.profile.matchesWon} (${winRate.toStringAsFixed(0)}%)',
                      palette: palette,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: '3-Dart Average',
                      value: widget.profile.averageScore.toStringAsFixed(1),
                      palette: palette,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: 'Highest Turn Score',
                      value: '${widget.profile.highestTurn}',
                      palette: palette,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: 'Total Throws',
                      value: '${widget.profile.totalThrows}',
                      palette: palette,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: 'Doubles / Triples Hit',
                      value: '${widget.profile.doubleHits} / ${widget.profile.tripleHits}',
                      palette: palette,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: TextStyle(color: palette.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isNotEmpty) {
                        widget.controller.updatePlayerProfile(
                          widget.profile.name,
                          name,
                          _selectedColor,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.palette,
  });

  final String label;
  final String value;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: palette.textMuted, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(color: palette.text, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

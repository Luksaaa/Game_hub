import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/sport_game.dart';
import '../theme/app_palette.dart';

class ComingSoonGameScreen extends StatelessWidget {
  const ComingSoonGameScreen({required this.game, super.key});

  final SportGame game;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final name = l10n.gameName(game.id, game.name);
    final subtitle = l10n.gameSubtitle(game.id, game.subtitle);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        foregroundColor: palette.text,
        scrolledUnderElevation: 0,
        title: Text(name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: game.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(game.icon, color: game.color, size: 40),
              ),
              const SizedBox(height: 18),
              Text(
                '$name scoring',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.t('activity.plannedModes'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in game.modes)
                    Chip(
                      label: Text(mode),
                      backgroundColor: palette.surface,
                      side: BorderSide(color: palette.border),
                      labelStyle: TextStyle(
                        color: palette.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              if (game.participants.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.t('activity.participants'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final participant in game.participants)
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: game.color,
                          foregroundColor: Colors.white,
                          child: Text(participant[0]),
                        ),
                        label: Text(participant),
                        backgroundColor: palette.surface,
                        side: BorderSide(color: palette.border),
                        labelStyle: TextStyle(
                          color: palette.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: game.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.t('activity.backToGames')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/sport_game.dart';
import '../theme/app_palette.dart';
import 'coming_soon_game_screen.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onOpenDarts,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<BuildContext> onOpenDarts;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            final crossAxisCount = isWide ? 2 : 1;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 32 : 16,
                    16,
                    isWide ? 32 : 16,
                    8,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _HubHeader(
                      themeMode: themeMode,
                      onThemeModeChanged: onThemeModeChanged,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 32 : 16,
                    8,
                    isWide ? 32 : 16,
                    24,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final game = sportGames[index];
                      return _GameCard(
                        game: game,
                        onTap: () {
                          if (game.id == 'darts') {
                            onOpenDarts(context);
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ComingSoonGameScreen(game: game),
                            ),
                          );
                        },
                      );
                    }, childCount: sportGames.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: isWide ? 220 : 236,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 32 : 16,
                    0,
                    isWide ? 32 : 16,
                    32,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Darts is ready now. Other games are prepared as modules so they can get their own scoring rules later.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.themeMode, required this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: palette.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.adjust, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Point',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Choose a game',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<ThemeMode>(
          tooltip: 'Theme',
          icon: Icon(Icons.brightness_6, color: palette.text),
          initialValue: themeMode,
          onSelected: onThemeModeChanged,
          itemBuilder: (context) => const [
            PopupMenuItem(value: ThemeMode.system, child: Text('System')),
            PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
            PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
          ],
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});

  final SportGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final isReady = game.status == SportGameStatus.ready;

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isReady ? game.color : palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: game.color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(game.icon, color: game.color, size: 28),
                  ),
                  const Spacer(),
                  _StatusBadge(isReady: isReady),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                game.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    game.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final mode in game.modes.take(3))
                    _ModeChip(label: mode, color: game.color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isReady});

  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isReady ? palette.primarySoft : palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isReady ? 'Ready' : 'Soon',
        style: TextStyle(
          color: isReady ? palette.primary : palette.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

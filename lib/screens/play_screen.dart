import 'package:flutter/material.dart';

import '../models/game_state_controller.dart';
import '../models/game_settings.dart';
import '../models/sport_game.dart';
import '../theme/app_palette.dart';

import '../widgets/dartboard.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    required this.controller,
    required this.isWide,
    required this.game,
    super.key,
  });

  final GameStateController controller;
  final bool isWide;
  final SportGame game;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  GameStateController get controller => widget.controller;
  bool get isWide => widget.isWide;

  void _confirmSaveTurn(BuildContext context, AppPalette palette) {
    final hits = controller.currentTurn;
    if (hits.isEmpty || controller.matchFinished) return;

    final turnTotal = hits.fold(0, (sum, h) => sum + h.score);
    final hitsText = hits.map((h) => h.label).join('  ·  ');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: palette.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Save turn?',
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hitsText,
              style: TextStyle(
                color: palette.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Total: $turnTotal pts',
                style: TextStyle(
                  color: palette.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.undoLastHit();
            },
            child: Text(
              'Redo Last Dart',
              style: TextStyle(
                color: palette.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: palette.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.commitTurn();
            },
            icon: const Icon(Icons.check, size: 16),
            label: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);

    final player = controller.currentPlayer;
    final hits = controller.currentTurn;
    final turnTotal = hits.fold(0, (total, hit) => total + hit.score);
    final message = controller.matchMessage;

    final chips = List.generate(3, (index) {
      final hit = index < hits.length ? hits[index] : null;
      final isActive = index == hits.length && !controller.matchFinished;

      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hit == null
                ? (isActive
                      ? palette.primarySoft.withValues(alpha: 0.5)
                      : palette.surface.withValues(alpha: 0.15))
                : palette.primarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? palette.accent
                  : (hit != null
                        ? palette.primary
                        : palette.border.withValues(alpha: 0.3)),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Text(
            hit?.label ?? 'Dart ${index + 1}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: hit == null
                  ? (isActive
                        ? palette.accent
                        : palette.text.withValues(alpha: 0.4))
                  : palette.primary,
            ),
          ),
        ),
      );
    });

    final currentTurnHeader = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(player.avatarColorValue),
                foregroundColor: Colors.white,
                radius: 20,
                child: Text(
                  player.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Avg: ${player.average.toStringAsFixed(1)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${player.remaining}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: palette.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children:
                chips
                    .expand((chip) => [chip, const SizedBox(width: 8)])
                    .toList()
                  ..removeLast(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Turn total: $turnTotal',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (message != null) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    final dartboardPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        currentTurnHeader,
        const SizedBox(height: 16),
        Expanded(
          child: Center(
          child: widget.game.id == 'darts'
              ? Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Dartboard(
                        enabled: !controller.matchFinished,
                        onHit: controller.handleHit,
                        currentTurn: hits,
                      ),
                    ),
                  ),
                )
              : _buildGenericSportUi(theme, palette),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                onPressed: hits.isEmpty || controller.matchFinished
                    ? null
                    : controller.undoLastHit,
                icon: Icons.undo,
                label: 'Undo',
                palette: palette,
                isSecondary: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                onPressed: controller.matchFinished ? null : controller.addMiss,
                icon: Icons.radio_button_unchecked,
                label: 'Miss',
                palette: palette,
                isSecondary: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                onPressed: hits.isNotEmpty && !controller.matchFinished
                    ? () => _confirmSaveTurn(context, palette)
                    : null,
                icon: Icons.check_circle_outline,
                label: 'Save turn',
                palette: palette,
                isSecondary: false,
              ),
            ),
          ],
        ),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: dartboardPanel),
          const SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: _QuickScoreboardPanel(
              controller: controller,
              palette: palette,
            ),
          ),
        ],
      );
    }

    return dartboardPanel;
  }

  Widget _buildGenericSportUi(ThemeData theme, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.game.icon, size: 64, color: widget.game.color),
          const SizedBox(height: 16),
                      CircleAvatar(
                        backgroundColor: Color(player.avatarColorValue),
                        foregroundColor: Colors.white,
                        radius: 18,
                        child: Text(
                          player.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: palette.text,
                              ),
                            ),
                            Text(
                              'Avg: ${player.average.toStringAsFixed(1)} | Turns: ${player.turns.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${player.remaining}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isCurrent ? palette.primary : palette.text,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Session Mode: ${controller.settings.mode == GameMode.x01 ? "${controller.settings.outRule.name.replaceAll('Out', '').toUpperCase()} OUT" : 'ACCUMULATIVE'}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

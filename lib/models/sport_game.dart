import 'package:flutter/material.dart';

enum SportGameStatus { ready, planned }

class SportGame {
  const SportGame({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
    required this.modes,
  });

  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final SportGameStatus status;
  final List<String> modes;
}

const sportGames = [
  SportGame(
    id: 'darts',
    name: 'Darts',
    subtitle: 'X01, Count up, players, groups and match history',
    icon: Icons.adjust,
    color: Color(0xFF0F8B6B),
    status: SportGameStatus.ready,
    modes: ['301', '501', '701', 'Count up'],
  ),
  SportGame(
    id: 'table-tennis',
    name: 'Table Tennis',
    subtitle: 'Sets, points, serve tracking and match timer',
    icon: Icons.sports_tennis,
    color: Color(0xFF276EF1),
    status: SportGameStatus.planned,
    modes: ['Best of 3', 'Best of 5', '11 points'],
  ),
  SportGame(
    id: 'tennis',
    name: 'Tennis',
    subtitle: 'Games, sets, tie-break and serve order',
    icon: Icons.sports,
    color: Color(0xFFE89A1A),
    status: SportGameStatus.planned,
    modes: ['Singles', 'Doubles', 'Tie-break'],
  ),
  SportGame(
    id: 'football',
    name: 'Football',
    subtitle: 'Score, timer, teams, goals and match events',
    icon: Icons.sports_soccer,
    color: Color(0xFFC7352F),
    status: SportGameStatus.planned,
    modes: ['5v5', '7v7', '11v11'],
  ),
];

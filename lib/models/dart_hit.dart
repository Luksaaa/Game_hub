enum SegmentBand { miss, single, double, triple, outerBull, bull }

class DartHit {
  const DartHit({
    required this.label,
    required this.score,
    required this.band,
    this.number,
    this.dx,
    this.dy,
  });

  final String label;
  final int score;
  final SegmentBand band;
  final int? number;
  
  // Normalized hit coordinate from center (-1.0 to 1.0)
  final double? dx;
  final double? dy;

  bool get isMiss => band == SegmentBand.miss;
  bool get isDouble => band == SegmentBand.double || band == SegmentBand.bull;
}

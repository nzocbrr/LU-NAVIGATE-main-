class CampusLocation {
  const CampusLocation({
    required this.id,
    required this.label,
    required this.top,
    required this.left,
    required this.name,
    required this.description,
    required this.floorsCount,
  });

  final String id;
  final String label;
  final double top;
  final double left;
  final String name;
  final String description;
  final String floorsCount;
}

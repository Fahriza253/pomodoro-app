class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAtUtcMs,
    required this.updatedAtUtcMs,
    this.deletedAtUtcMs,
  });

  final String id;
  final String name;
  final int sortOrder;
  final int? deletedAtUtcMs;
  final int createdAtUtcMs;
  final int updatedAtUtcMs;

  bool get isDeleted => deletedAtUtcMs != null;
}

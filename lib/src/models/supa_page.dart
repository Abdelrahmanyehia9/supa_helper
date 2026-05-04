class SupaPage<T> {
  final List<T> data;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final int perPage;

  const SupaPage({
    required this.data,
    required this.totalCount,
    required this.hasMore,
    required this.currentPage,
    required this.perPage,
  });
}
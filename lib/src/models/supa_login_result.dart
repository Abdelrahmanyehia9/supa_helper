class SupaAuthResult<T> {
  final String idToken ;
  final T? rawData ;
  const SupaAuthResult({required this.idToken, this.rawData});
}
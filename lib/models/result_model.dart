class Result<T> {
  final String message;
  final bool hasError;
  final T? data;

  const Result({
    this.message = '',
    this.hasError = false,
    this.data
  });
}
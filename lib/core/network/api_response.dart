
sealed class ApiResponse<T> {
  const ApiResponse();
}

class ApiSuccess<T> extends ApiResponse<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResponse<T> {
  final String message;
  const ApiFailure(this.message);
}
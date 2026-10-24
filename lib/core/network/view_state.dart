/// Generic ViewState representation for UI loading, error, empty, and success states.
sealed class ViewState<T> {
  const ViewState();

  bool get isInitial => this is ViewStateInitial<T>;
  bool get isLoading => this is ViewStateLoading<T>;
  bool get isSuccess => this is ViewStateSuccess<T>;
  bool get isError => this is ViewStateError<T>;
  bool get isEmpty => this is ViewStateEmpty<T>;

  T? get dataOrNull => switch (this) {
    ViewStateSuccess<T>(data: final d) => d,
    _ => null,
  };

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message, void Function()? retry) error,
    required R Function(String message) empty,
  }) {
    return switch (this) {
      ViewStateInitial<T>() => initial(),
      ViewStateLoading<T>() => loading(),
      ViewStateSuccess<T>(data: final d) => success(d),
      ViewStateError<T>(message: final m, retry: final r) => error(m, r),
      ViewStateEmpty<T>(message: final m) => empty(m),
    };
  }
}

class ViewStateInitial<T> extends ViewState<T> {
  const ViewStateInitial();
}

class ViewStateLoading<T> extends ViewState<T> {
  const ViewStateLoading();
}

class ViewStateSuccess<T> extends ViewState<T> {
  final T data;
  const ViewStateSuccess(this.data);
}

class ViewStateError<T> extends ViewState<T> {
  final String message;
  final void Function()? retry;
  const ViewStateError(this.message, {this.retry});
}

class ViewStateEmpty<T> extends ViewState<T> {
  final String message;
  const ViewStateEmpty({this.message = 'No data available'});
}

/// Custom exception for question loading errors
class QuestionLoadingException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  QuestionLoadingException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() {
    final buffer = StringBuffer('QuestionLoadingException: $message');
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Exception for invalid question data
class InvalidQuestionDataException extends QuestionLoadingException {
  InvalidQuestionDataException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception for missing or corrupted question file
class QuestionFileException extends QuestionLoadingException {
  QuestionFileException(super.message, {super.originalError, super.stackTrace});
}

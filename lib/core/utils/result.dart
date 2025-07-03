// Define uma sealed class (classe selada) que representa o resultado de uma operação
// Pode ser Success ou Failure
sealed class Result<T> {
  const Result();
}

// Representa um resultado bem-sucedido
class Success<T> extends Result<T> {
  // O dado retornado no sucesso
  final T data;

  // Construtor
  const Success(this.data);
}

// Representa um resultado com falha
class Failure<T> extends Result<T> {
  // Mensagem de erro
  final String message;

  // Construtor
  const Failure(this.message);
}

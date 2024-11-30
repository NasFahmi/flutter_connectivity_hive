/// Generalize InterFace For DataBase Repository Implementation
abstract class InterfaceProvider<T> {
  /// Get All Data From DB
  Future<T?> getAll();

  /// Insert Data To Data Base
  Future<void> insertItem({required T object});

  /// is Data Available
  Future<bool> isDataAvailable();

  /// Delete Data From Data Base if data is list
  Future<void> deleteItem({required T object});

  Future<void> clearItem();
}
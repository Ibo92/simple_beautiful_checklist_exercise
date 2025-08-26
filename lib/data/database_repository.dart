abstract class DatabaseRepository {
  // Gibt die Anzahl der Items zurück.
  Future<int> getItemCount();

  // Gibt die Items zurück.
  Future<List<String>> getItems();

  // Fügt ein neues Item hinzu.
  Future<void> addItem(String item);

  // Löscht ein Item an einem bestimmten Index.
  Future<void> deleteItem(int index);

  // Aktualisiert ein Item an einem bestimmten Index.
  Future<void> editItem(int index, String newItem);


 Future<void> clear();

}

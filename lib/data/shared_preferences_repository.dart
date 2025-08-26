//also mein Verständnis von Simon App sagt:
//Items werden als Liste von Strings gespeichert (List<String>). aber 
//Nachteil: Bei jeder Änderung muss die gesamte Liste gespeichert werden.
// Deswegen werde ich Option 2 wählen : Jeder Eintrag bekommt eine eigene 
//ID → "todo_1" = "Einkaufen", "todo_2" = "Flutter lernen".
//Vorteil: Sehr flexibel, man kann einzelne Keys löschen.
//nachteil : bei vielen Items unübersichtlich. wenn wir viele Items haben dann brauchen wir 
//Methoden wie 
//addItem, editItem, deleteItem, getItems, getItemCount umsetzen.


import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Repository für Todos mit SharedPreferences
/// Jeder Todo wird als eigenes Key-Value gespeichert:
///   "todo_ id" : "Mein Text"
class SharedPreferencesRepository {
  static const String _counterKey = "todo_counter"; // // speichert die letzte vergebene ID
  static const String _prefix = "todo_"; // // Präfix für die Keys

  /// Hole alle Todos als Map<id-text
  Future<Map<int, String>> getItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)); //diese keys filtern die mit todo_ anfangen , k ist der key
      final Map<int, String> items = {}; // // leere Map zum Befüllen 
      for (var key in keys) { // // alle passenden Keys durchgehen
        final idStr = key.replaceFirst(_prefix, ""); // // id extrahieren
        final id = int.tryParse(idStr); // // in int umwandeln
        final value = prefs.getString(key); // // Wert holen
         // // nur hinzufügen, wenn id und value nicht null sind
        if (id != null && value != null) {
          items[id] = value; // // in Map speichern
        }
      }
      return items; // // Map zurückgeben
    } catch (e) {
      // // Falls SharedPreferences fehlschlägt, leere Map zurückgeben
      return {};
    }
  }

  /// Anzahl der Todos holen
  Future<int> getItemCount() async {
    try {
      final items = await getItems();
      return items.length;
    } catch (_) { // // Fehler ignorieren
      return 0; // // bei Fehler: 0 zurück
    }
  }

  /// Neues Todo hinzufügen
  Future<void> addItem(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance(); // // SharedPreferences Instanz holen
      int counter = prefs.getInt(_counterKey) ?? 0; // // letzte ID holen , ?? 0 wenn nicht vorhanden
      counter++; // // nächste ID
      await prefs.setString("$_prefix$counter", text); // // neuen Eintrag speichern
      await prefs.setInt(_counterKey, counter); // // speichert neuen Stand als ID
    } catch (e) { 
      // // Fehler einfach abfangen
    }
  }

  /// Todo bearbeiten
  Future<void> editItem(int id, String newText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = "$_prefix$id"; // // Key für das Todo
      if (prefs.containsKey(key)) { // // nur bearbeiten, wenn Key existiert
        await prefs.setString(key, newText); // // neuen Text speichern
      }
    } catch (e) {
      // // ignorieren, wenn etwas schief geht
    }
  }

  /// Todo löschen
  Future<void> deleteItem(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance(); // // SharedPreferences Instanz holen
      await prefs.remove("$_prefix$id"); // // Eintrag löschen
    } catch (e) {
      // // Fehler abfangen
    }
  }

  /// Alles löschen (für Reset)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)); //bedeutet alle keys die mit todo_ anfangen und diese löschen
      for (var key in keys) { // // alle passenden Keys durchgehen
        await prefs.remove(key); // // Eintrag löschen
      }
      await prefs.remove(_counterKey); // // Zähler zurücksetzen
    } catch (e) {
      // // Fehler abfangen
    }
  }
}

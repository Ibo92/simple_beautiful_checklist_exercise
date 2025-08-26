import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';

/// Repository für Todos mit SharedPreferences
/// Jeder Todo wird als eigenes Key-Value gespeichert:
///   "todo_ id" : "Mein Text"
class SharedPreferencesRepository implements DatabaseRepository {
  // implements DatabaseRepository
  static const String _counterKey =
      "todo_counter"; // // speichert die letzte vergebene ID
  static const String _prefix = "todo_"; // // Präfix für die Keys
  static SharedPreferences?
  _prefs; // // SharedPreferences-Instanz (kann null sein bevor init)

  /// Optional: initialisieren (kann in main() aufgerufen werden)
  static Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      print("SharedPreferencesRepository.init() Fehler: $e");
    }
  }

  /// Hilfsmethode: sorgt dafür, dass _prefs initialisiert ist
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs!;
    try {
      _prefs = await SharedPreferences.getInstance();
      return _prefs!; // hier sicher, dass _prefs nicht null ist
    } catch (e) {
      rethrow; // rethrow den Fehler, damit der Aufrufer ihn behandeln kann
    }
  }

  /// Hole alle Todos als Map<id-text
  Future<Map<int, String>> _getEntriesSorted() async {
    // (Hilfsfunktion, intern) // <-- geändert: Typprüfung hinzugefügt
    try {
      final prefs =
          await _getPrefs(); // <-- geändert: statt direkt SharedPreferences.getInstance()
      final keys = prefs.getKeys().where(
        (k) => k.startsWith(_prefix),
      ); //diese keys filtern die mit todo_ anfangen , k ist der key
      final Map<int, String> items = {}; // // leere Map zum Befüllen
      for (var key in keys) {
        // // alle passenden Keys durchgehen
        final idStr = key.replaceFirst(_prefix, ""); // // id extrahieren
        final id = int.tryParse(idStr); // // in int umwandeln
        final value = prefs.get(key); // <-- FIX: dynamisch holen, nicht nur getString()
        // // nur hinzufügen, wenn id != null und value vom Typ String
        if (id != null && value is String) {
          items[id] = value; // // in Map speichern
        }
      }
      // <-- FIX: unnötige komplizierte Map-Manipulation entfernt
      return items; // nur die Map zurückgeben
    } catch (e) {
      print(
        "SharedPreferencesRepository._getEntriesSorted Fehler: $e",
      ); //
      // // Falls SharedPreferences fehlschlägt, leere Map zurückgeben
      return {};
    }
  }

  /// Liefert alle Items als List<String (UI erwartet List)
  @override
  Future<List<String>> getItems() async {
    // Rückgabetyp List<String> (Interface-konform)
    try {
      // wir nutzen die interne Map, sortieren nach id und geben nur die values als List zurück
      final map = await _getEntriesSorted(); //  nutzt helper
      // <-- FIX: Sortierung korrekt umsetzen , vorher war bei mir flasch
      final sortedKeys = map.keys.toList()..sort();
      final List<String> sortedValues = [];
      for (var id in sortedKeys) {
        final value = map[id];
        if (value != null) sortedValues.add(value);
      }
      return sortedValues; // <-- FIX: vorher gab es fehlerhafte Map-Manipulation
    } catch (e) {
      print(
        "SharedPreferencesRepository.getItems Fehler: $e",
      ); 
      return []; // // bei Fehler leere Liste
    }
  }

  /// Anzahl der Todos holen
  @override
  Future<int> getItemCount() async {
    try {
      final items = await getItems(); 
      return items.length;
    } catch (e) {
      
      print(
        "SharedPreferencesRepository.getItemCount Fehler: $e",
      ); 
      return 0; //  bei Fehler: 0 zurück
    }
  }

  /// Neues Todo hinzufügen
  @override
  Future<void> addItem(String text) async {
    try {
      final prefs =
          await _getPrefs(); //  statt direkt getInstance() weil _init() sein könnte
      int counter = prefs.getInt(_counterKey) ?? 0; // // letzte ID holen , ?? 0 wenn nicht vorhanden
      counter++; // // nächste ID
      await prefs.setString(
        "$_prefix$counter",
        text,
      ); // // neuen Eintrag speichern
      await prefs.setInt(
        _counterKey,
        counter,
      ); // // speichert neuen Stand als ID
    } catch (e) {
      print("SharedPreferencesRepository.addItem Fehler: $e",);
      //  Fehler einfach abfangen
    }
  }

  /// Item bearbeiten: index ist die Position in der aktuellen Liste (0..n-1)
  /// Wir bestimmen die id anhand der sortierten Einträge und überschreiben den Key
  @override
  Future<void> editItem(int index, String newText) async {
    // Parameter heißt index (wie UI aufruft)
    try {
      final entriesMap = await _getEntriesSorted(); // Map<int,String>
      final ids = entriesMap.keys.toList()..sort(); // sortierte Ids
      if (index < 0 || index >= ids.length) return; // // Index-Check
      final id = ids[index]; // ID für die Position
      final prefs = await _getPrefs();
      final key = '$_prefix$id';
      if (prefs.containsKey(key)) {
        await prefs.setString(key, newText); // // aktualisieren
      }
    } catch (e) {
      print( "SharedPreferencesRepository.editItem Fehler: $e",); // <-- hinzugefügt
    }
  }

  /// Item löschen: index ist Position in der aktuellen Liste
  @override
  Future<void> deleteItem(int index) async {
    //  index-Parameter (wie UI nutzt)
    try {
      final entriesMap = await _getEntriesSorted();
      final ids = entriesMap.keys.toList()..sort();
      if (index < 0 || index >= ids.length) return; // // Index-Check
      final id = ids[index];
      final prefs = await _getPrefs();
      final key = '$_prefix$id';
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    } catch (e) {
      print( "SharedPreferencesRepository.deleteItem Fehler: $e", ); // <-- hinzugefügt
    }
  }

  /// Alles löschen (Reset)
  
  @override
  Future<void> clear() async {
    // Methode  Interface-konform
    try {
      final prefs = await _getPrefs();
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith(_prefix))
          .toList(); //bedeutet alle keys die mit todo_ anfangen und diese löschen
      for (var key in keys) {
        // // alle passenden Keys durchgehen
        await prefs.remove(key); // // Eintrag löschen
      }
      await prefs.remove(_counterKey); // // Zähler zurücksetzen
    } catch (e) {
      print("SharedPreferencesRepository.clear Fehler: $e"); // <-- hinzugefügt
      // // Fehler abfangen
    }
  }
}


/**
 * Hinweise für die App
Sortierung: _getEntriesSorted() sorgt dafür, dass die Items nach ID sortiert werden, also Reihenfolge bleibt konsistent.
Counter: _counterKey wird beim clear() ebenfalls zurückgesetzt, sodass neue Todos wieder bei 1 starten.
Error Handling: Alle Methoden fangen Fehler ab, daher stürzt die App nicht bei SharedPreferences-Problemen.
 * / */
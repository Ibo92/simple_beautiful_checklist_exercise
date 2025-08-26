import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';
// import 'package:simple_beautiful_checklist_exercise/data/mock_database_repository.dart'; // bisheriges Mock-Repo auskommentieren
import 'package:simple_beautiful_checklist_exercise/data/shared_preferences_repository.dart'; // neues Repo importieren
import 'package:simple_beautiful_checklist_exercise/src/app.dart';

void main() async {
  // Wird benötigt, um auf SharedPreferences zuzugreifen
  WidgetsFlutterBinding.ensureInitialized();

//SharedPreferences einmal initialisieren (beschleunigt späteren Zugriff)
   try {
     await SharedPreferencesRepository.init(); // Init für SharedPreferences (falls vorhanden)
   } catch (e) {
     print("Fehler beim Init abfangen, App soll trotzdem starten");
   }
          // // hier Mock durch SharedPreferences ersetzen
  final DatabaseRepository repository = SharedPreferencesRepository();
   

  runApp(App(repository: repository));
}

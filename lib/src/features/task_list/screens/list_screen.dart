import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';
import 'package:simple_beautiful_checklist_exercise/src/features/task_list/widgets/empty_content.dart';
import 'package:simple_beautiful_checklist_exercise/src/features/task_list/widgets/item_list.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    required this.repository,
  });

  final DatabaseRepository repository;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<String> _items = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateList(); // initial laden
  }

  // <-- Änderung: Rückgabewert von Future<void> anpassen, damit await funktioniert
  Future<void> _updateList() async {
    setState(() {
      isLoading = true; // Ladeindikator
    });

    try {
      final itemsFromRepo = await widget.repository.getItems(); // alle Items holen
          print("DEBUG: Items geladen: $itemsFromRepo"); // <-- Check

      _items
        ..clear()
        ..addAll(itemsFromRepo); // Liste aktualisieren
    } catch (e) {
      print("Fehler beim Laden der Items: $e");
    } finally {
      setState(() {
        isLoading = false; // Ladeindikator aus
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Checkliste'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _items.isEmpty
                      ? const EmptyContent()
                      : ItemList(
                          repository: widget.repository,
                          items: _items,
                          updateOnChange: _updateList, // <-- Änderung: 
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Task Hinzufügen',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          // <-- Änderung: await bei addItem + _updateList
                          if (_controller.text.isNotEmpty) {
                            await widget.repository.addItem(_controller.text);
                                print("DEBUG: hinzugefügt: ${_controller.text}"); // 

                            _controller.clear();
                            await _updateList(); // Liste aktualisieren
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) async {
                      // <-- Änderung: await bei addItem + _updateList
                      if (value.isNotEmpty) {
                        await widget.repository.addItem(value);
                            print("DEBUG: hinzugefügt: $value"); // <-- 

                        _controller.clear();
                        await _updateList(); // Liste aktualisieren
                      }
                    },
                  ),
                ),
                // Optional: Button zum Testen von clear()
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await widget.repository.clear(); // alles löschen
                      await _updateList(); // Liste neu laden
                    },
                    child: const Text("Alles löschen"), // <-- Testbutton
                  ),
                ),
              ],
            ),
    );
  }
}

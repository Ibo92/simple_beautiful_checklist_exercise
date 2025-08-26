import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.repository,
    required this.items,
    required this.updateOnChange,
  });

  final DatabaseRepository repository;
  final List<String> items;
  final Future<void> Function() updateOnChange; // vorher: void Function()

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  TextEditingController editController = TextEditingController(
                    text: items[index],
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Task bearbeiten'),
                        content: TextField(
                          autofocus: true,
                          controller: editController,
                          decoration: const InputDecoration(
                            hintText: "Task bearbeiten",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Abbrechen'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Speichern'),
                            //hier müssen wir async fügen, damit await arbeitet
                            onPressed: () async {
                             await repository.editItem(index, editController.text); //Ä
                             await updateOnChange();//Ä
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                //Ä
                onPressed: () async {
                 await repository.deleteItem(index);
                 await updateOnChange();
                 //Damit wird garantiert, 
                 //dass die UI erst aktualisiert wird, nachdem SharedPreferences die Änderungen gespeichert hat.
                },
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(
        thickness: 1,
        color: Colors.white10,
      ),
    );
  }
}

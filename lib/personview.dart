import 'package:flutter/material.dart';
import 'person.dart';
import 'main.dart';

// ignore: must_be_immutable
class PersonView extends StatefulWidget {
  final List<Person> personList;
  final MyHomePageState homePageState;

  const PersonView(
      {super.key, required this.personList, required this.homePageState});

  @override
  _PersonViewState createState() => _PersonViewState();
}

class _PersonViewState extends State<PersonView> {
  deletePerson(int index) async {
    await widget.homePageState.deletePerson(index);
  }

  renamePerson(int index) async {
    final newName = await widget.homePageState.requestPersonName();
    if (newName == null || newName.isEmpty) return;
    await widget.homePageState.updatePersonName(index, newName);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.personList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Theme.of(context).colorScheme.surfaceVariant,
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage:
                    MemoryImage(widget.personList[index].faceJpg),
              ),
              title: Text(
                widget.personList[index].name,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 24),
                    onPressed: () => renamePerson(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 24),
                    onPressed: () => deletePerson(index),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

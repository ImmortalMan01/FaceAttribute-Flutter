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
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(28.0),
                child: Image.memory(
                  widget.personList[index].faceJpg,
                  width: 56,
                  height: 56,
                ),
              ),
              title: Text(widget.personList[index].name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => renamePerson(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deletePerson(index),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

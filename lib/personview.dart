import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
          return Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            style: NeumorphicStyle(
              depth: 2,
              boxShape: NeumorphicBoxShape.roundRect(
                const BorderRadius.all(Radius.circular(12)),
              ),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(28.0),
                child: Image.memory(
                  widget.personList[index].faceJpg,
                  width: 56,
                  height: 56,
                ),
              ),
              title: NeumorphicText(
                widget.personList[index].name,
                style: const NeumorphicStyle(depth: 1),
                textStyle: NeumorphicTextStyle(fontSize: 16),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: NeumorphicIcon(Icons.edit, size: 24),
                    onPressed: () => renamePerson(index),
                  ),
                  IconButton(
                    icon: NeumorphicIcon(Icons.delete, size: 24),
                    onPressed: () => deletePerson(index),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NameWidget extends StatefulWidget {
  @override
  _NameWidgetState createState() => _NameWidgetState();
}

class _NameWidgetState extends State<NameWidget> {
  final TextEditingController _nameController = TextEditingController();
  final CollectionReference _namesCollection =
      FirebaseFirestore.instance.collection('names');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Enter Name'),
        ),
        ElevatedButton(
          onPressed: () {
            _addName(_nameController.text);
          },
          child: Text('Add Name'),
        ),
        SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: _namesCollection.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            List<Map<String, dynamic>> names = snapshot.data!.docs.map((doc) {
              return {
                'id': doc.id,
                'name': doc['name'].toString(),
              };
            }).toList();

            return Column(
              children: names
                  .map((name) => ListTile(
                        title: Text(name['name']),
                        subtitle: Text(name['id']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteName(name['id']);
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _addName(String name) async {
    await _namesCollection.add({'name': name});
    _nameController.clear();
  }

  Future<void> _deleteName(String name) async {
    await _namesCollection.doc(name).delete();
  }
}

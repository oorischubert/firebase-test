import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ReadExamples extends StatefulWidget {
  const ReadExamples({Key? key}) : super(key: key);

  @override
  State<ReadExamples> createState() => _ReadExamplesState();
}

class _ReadExamplesState extends State<ReadExamples> {
  final _database = FirebaseDatabase.instance.ref();
  Map _result = {};
  String _uid = '';

//gets snapshot of product database instead of activley listening
  void _activateListeners(uid) {
    _database.child('products/$uid').get().then((snapshot) {
      //if object doesnt exist open add product page!!
      final _product = snapshot.value ?? {"name": "DNE", "description": "DNE"};
      setState(() {
        _result = _product as Map;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Read Example")),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_result['name'] ?? ""),
          Text(_result['description'] ?? ""),
          TextFormField(
              decoration: const InputDecoration(labelText: "Desc:"),
              onChanged: (String value) {
                _uid = value;
              }),
          ElevatedButton(
              onPressed: () {
                _activateListeners(_uid);
              },
              child: const Text("Get Product!")),
        ])));
  }
}

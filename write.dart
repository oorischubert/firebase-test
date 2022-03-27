import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class WriteExamples extends StatefulWidget {
  const WriteExamples({Key? key}) : super(key: key);

  @override
  State<WriteExamples> createState() => _WriteExamplesState();
}

class _WriteExamplesState extends State<WriteExamples> {
  final database = FirebaseDatabase.instance.ref();
  String uid = '';
  String name = '';
  String desc = '';
  @override
  Widget build(BuildContext context) {
    final _product = database.child('products');
    void _addUID(x) async { //convert to using then and catcherror as used in "test" in main!
      try {
        //addus uid to the database child "products"
        await _product.set(x);
        print("write sucesfull");
      } catch (error) {
        print("ERROR: $error");
      }
    }

    return Scaffold(
        appBar: AppBar(title: const Text("Write Example")),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormField(
              decoration: const InputDecoration(labelText: "UID:"),
              onChanged: (String value) {
                uid = value;
              }),
          TextFormField(
              decoration: const InputDecoration(labelText: "Name:"),
              onChanged: (String value) {
                name = value;
              }),
          TextFormField(
              decoration: const InputDecoration(labelText: "Desc:"),
              onChanged: (String value) {
                desc = value;
              }),
          ElevatedButton(
              onPressed: () {
                _addUID({
                  uid: {'name': name, 'description': desc}
                });
              },
              child: const Text("Upload")),
        ])));
  }
}

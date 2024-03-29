import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './write.dart';
import './read.dart';
import './product.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //ensure everythings initialized!
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
            future: _fbApp,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                //if error occurs return this!
                // ignore: avoid_print
                print("ERROR: ${snapshot.error.toString()}");
                return const Text("Oops, something went wrong!");
              } else if (snapshot.hasData) {
                //if data returned load up home page!
                return const MyHomePage(title: 'Flutter Demo Home Page');
              } else {
                //if no data has been returned yet show loading screen!
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = '';
  Map _result = {};
  final _database = FirebaseDatabase.instance.ref();
  late StreamSubscription _productStream;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  @override
  void deactivate() {
    super.deactivate();
    _productStream.cancel();
  }

//constantly listens to changes in the test subclass of database as it is in initState!
  void _activateListeners() {
    _database.child('test').onValue.listen((event) {
      final Object? _messages = event.snapshot.value;
      setState(() {
        _result = _messages as Map;
      });
    });
  }

  void _upload(x) {
    //uploads to the database child "test" and replaces whatever was there before
    _database
        .child('test')
        .push()
        .set(x)
        .then((_) => print("upload sucesfull!"))
        .catchError((error) => print("ERROR: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Firebase Test!")),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          //StreamBuilder actively listens to data and updates whenever it changes. Thus no need for setState and activeListeners!
          StreamBuilder(
              stream: _database
                  .child('products')
                  .orderByKey()
                  .limitToLast(10)
                  .onValue,
              builder: (context, snapshot) {
                final prodList = <Widget>[];
                if (snapshot.hasData &&
                    !snapshot.hasError &&
                    (snapshot.data! as DatabaseEvent).snapshot.value != null) {
                  Map myProds =
                      (snapshot.data! as DatabaseEvent).snapshot.value as Map;
                  prodList.addAll(myProds.values.map((value) {
                    final _product =
                        Product.fromRTDB(Map<String, dynamic>.from(value));
                    return ElevatedButton(
                        child: Text(_product.name),
                        onPressed: () {
                          print(_product.description);
                        });
                  }));
                }
                return SizedBox(
                    height: 300,
                    child: ListView(
                      children: prodList,
                    ));
              }),
          TextFormField(
              decoration: const InputDecoration(labelText: "upload:"),
              onChanged: (String value) {
                _text = value;
              }),
          ElevatedButton(
              onPressed: () {
                if (_text != '') {
                  _upload(_text);
                }
              },
              child: const Text("Upload")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WriteExamples()),
                );
              },
              child: const Text("write")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReadExamples()),
                );
              },
              child: const Text("read")),
        ])));
  }
}

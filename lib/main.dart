import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:my_flutter_ar/screenshotexample.dart';
import 'package:wakelock/wakelock.dart';

import 'hello_ar.dart';
import 'objectsonplanesexample.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  static const String _title = 'AR Plugin Demo';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ArFlutterPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
        ),
        body: Column(children: [
          Text('Running on: $_platformVersion\n'),
          Expanded(
            child: ExampleList(),
          ),
        ]),
      ),
    );
  }
}

class ExampleList extends StatelessWidget {
  ExampleList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final examples = [
      // Example(
      //     'Debug Options',
      //     'Visualize feature points, planes and world coordinate system',
      //         () => Navigator.push(context,
      //         MaterialPageRoute(builder: (context) => DebugOptionsWidget()))),
      // Example(
      //     'Local & Online Objects',
      //     'Place 3D objects from Flutter assets and the web into the scene',
      //         () => Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => LocalAndWebObjectsWidget()))),
      Example(
          'Anchors & Objects on Planes',
          'Place 3D objects on detected planes using anchors',
              () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ObjectsOnPlanesWidget()))),
      Example(
          'arcore_flutter_plugin- Gian Marco',
          'Place 3D objects and calculate distance',
              () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => HelloWorld()))),
      // Example(
      //     'Object Transformation Gestures',
      //     'Rotate and Pan Objects',
      //         () => Navigator.push(context,
      //         MaterialPageRoute(builder: (context) => ObjectGesturesWidget()))),
      Example(
          'Screenshots',
          'Place 3D objects on planes and take screenshots',
              () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ScreenshotWidget()))),
      // Example(
      //     'Cloud Anchors',
      //     'Place and retrieve 3D objects using the Google Cloud Anchor API',
      //         () => Navigator.push(context,
      //         MaterialPageRoute(builder: (context) => CloudAnchorWidget()))),
      // Example(
      //     'External Model Management',
      //     'Similar to Cloud Anchors example, but uses external database to choose from available 3D models',
      //         () => Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => ExternalModelManagementWidget())))
    ];
    return ListView(
      children:
      examples.map((example) => ExampleCard(example: example)).toList(),
    );
  }
}

class ExampleCard extends StatelessWidget {
  ExampleCard({Key? key, required this.example}) : super(key: key);
  final Example example;

  @override
  build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          example.onTap();
        },
        child: ListTile(
          title: Text(example.name),
          subtitle: Text(example.description),
        ),
      ),
    );
  }
}

class Example {
  const Example(this.name, this.description, this.onTap);
  final String name;
  final String description;
  final Function onTap;
}










// import 'package:flutter/material.dart';
// import 'package:my_flutter_ar/ar_distance.dart';
// import 'package:my_flutter_ar/hello_ar.dart';
// import 'package:wakelock/wakelock.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   Wakelock.enable();
//
//   runApp(const MyApp());
//
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//
//     Navigator.push(context, MaterialPageRoute(builder: (context) => HelloWorld()));
//     // Navigator.push(context, MaterialPageRoute(builder: (context) => DistanceMeasureScreen()));
//
//
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             SizedBox(
//               width: 300 , height: 300,
//               child: Image.asset('assets/rover.png'),
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'dart:developer';

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:math' as math;

class HelloWorld extends StatefulWidget {
  @override
  _HelloWorldState createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  late ArCoreController arCoreController;
  vector.Vector3 cameraPosition = vector.Vector3.zero();
  List<ArCoreNode> nodes=[];
  String distance = "";
  String distanceFromCam = "";
  MyDirection myDirection  = MyDirection();

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('MY AR Flutter'),
          ),
          body: Center(
            child: Column(
              children: [
                Container(
                  width: 500,
                  height: 500,
                  child: ArCoreView(
                    onArCoreViewCreated: _onArCoreViewCreated,
                    enableTapRecognizer: true,
                    enableUpdateListener: true,


                  ),
                ),
                IconButton(
                    onPressed: () {
                      // _addSphere(arCoreController);
                      _calculateDistance(nodes[0], nodes[1]);
                    },
                    icon: Icon(Icons.area_chart_sharp)),
                Text('distance betwwen node0 , node1: $distance' , style: TextStyle(fontSize: 18),),
                Text('distance from Camera: $distanceFromCam' , style: TextStyle(fontSize: 18),),
                Text('X: ${myDirection.x}' , style: TextStyle(fontSize: 18),),
                Text('Y: ${myDirection.y}' , style: TextStyle(fontSize: 18),),
                Text('Z: ${myDirection.z}' , style: TextStyle(fontSize: 18),),


              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cleaning_services),
        onPressed: (){
          nodes.forEach((element) {
            arCoreController.removeNode(nodeName: element.name);
          });
          nodes.clear();

        },
      ),),
    );
  }



  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = controlOnPlaneTap;
    // print('AAA ${arCoreController.getTrackingState()}');
    //
    // log('AAA ${arCoreController.getTrackingState().toString()}');



    // _addSphere(arCoreController);
    // _addCylindre(arCoreController);
    // _addCube(arCoreController);

  }

  void controlOnPlaneTap(List<ArCoreHitTestResult> results) {
    final hit = results.first;

    print('hit.pose.translation ${hit.pose.translation}');

    addItemImageToScene(hit);

  }


  Future addItemImageToScene(ArCoreHitTestResult hitTestResult) async {


    /// rover.png
    // final bytes =
    // (await rootBundle.load('assets/rover.png')).buffer.asUint8List();
    // final imageItem = ArCoreNode(
    //   image: ArCoreImage(bytes: bytes, width: 300, height: 300),
    //
    //   position: hitTestResult.pose.translation + vector.Vector3(0.0, 0.0, 0.0),
    //   rotation:
    //       hitTestResult.pose.rotation + vector.Vector4(0.0, 0.0, 0.0, 0.0),
    //
    // );
    // arCoreController.addArCoreNodeWithAnchor(imageItem);
    // nodes.add(imageItem);
    // calDistanceFromCamera(imageItem);

    final bytes = await _loadGif('assets/AndroidRobot.gif');
    final material = ArCoreMaterial(
      textureBytes:  bytes,
      metallic: 0.0,
        color: Color.fromARGB(120, 66, 134, 244)
    );

    // ArCoreNode node = ArCoreNode(
    //   // shape: ArCoreSphere(
    //   //
    //   //   radius: 0.2,
    //   //   materials: [material],
    //   // ),
    //   // shape: ArCoreCylinder(materials: [material] ),
    //   image: ArCoreImage(bytes: bytes , width: 200 , height: 200),
    //     position: hitTestResult.pose.translation + vector.Vector3(0.0, 0.0, 0.0),
    //     rotation:
    //         hitTestResult.pose.rotation + vector.Vector4(0.0, 0.0, 0.0, 0.0),
    // );

    ArCoreNode node  = ArCoreReferenceNode(
        name: 'name',
        object3DFileName: 'andy.sfb',
        // objectUrl:
        // "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF/Duck.gltf",
          position: hitTestResult.pose.translation + vector.Vector3(0.0, 0.0, 0.0),
          rotation:
              hitTestResult.pose.rotation + vector.Vector4(0.0, 0.0, 0.0, 0.0),
    );
    arCoreController.addArCoreNodeWithAnchor(node);
    nodes.add(node);
    calDistanceFromCamera(node);

  }

  Future<Uint8List> _loadGif(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }


  double _calculateDistance(ArCoreNode start, ArCoreNode end) {
    double _distance = math.sqrt(
      math.pow(end.position!.value.x - start.position!.value.x, 2) +
          math.pow(end.position!.value.y - start.position!.value.y, 2) +
          math.pow(end.position!.value.z - start.position!.value.z, 2),
    );
    setState(() {
      distance = _distance.toString();
      myDirection.x=cameraPosition.x - start.position!.value.x;
      myDirection.y=cameraPosition.y - start.position!.value.y;
      myDirection.z=cameraPosition.z - start.position!.value.z;
    });



    // cameraPosition.sub(start.position!.value);


    // print("********************");
    // print(cameraPosition.x - start.position!.value.x);
    // print(cameraPosition.y - start.position!.value.y);
    // print(cameraPosition.z - start.position!.value.z);




    return _distance;


  }

  calDistanceFromCamera(ArCoreNode node) async {
    setState(() {
      distanceFromCam = cameraPosition.distanceTo(node.position!.value).toString();
    });




  }


  Future<void> _addSphere(ArCoreController controller) async {
    final material = ArCoreMaterial(color: Color.fromARGB(120, 66, 134, 244));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.05,
    );
    // final node = ArCoreNode(
    //   shape: sphere,
    //   position: vector.Vector3(0, 0, -1.5),
    // );
    final bytes =
        (await rootBundle.load('assets/rover.png')).buffer.asUint8List();
    final node = ArCoreNode(
      image: ArCoreImage(bytes: bytes, width: 300, height: 300),
      position: vector.Vector3(0, 0, -1.5),
      // rotation: hitTestResult.pose.rotation + vector.Vector4(0.0,0.0,0.0,0.0),
    );
    controller.addArCoreNode(node);

    // final node2 = ArCoreNode(
    //   image: ArCoreImage(bytes: null)
    // );
  }

  void _addCylindre(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Colors.red,
      reflectance: 1.0,
    );
    final cylindre = ArCoreCylinder(
      materials: [material],
      radius: 0.5,
      height: 0.3,
    );
    final node = ArCoreNode(
      shape: cylindre,
      position: vector.Vector3(0.0, -0.5, -2.0),
    );
    controller.addArCoreNode(node);
  }

  void _addCube(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.5, 0.5, 0.5),
    );
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(-0.5, 0.5, -3.5),
    );
    controller.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}

class MyDirection{
  double x;
  double y;
  double z;


  MyDirection({this.x = 0.0, this.y=0.0, this.z=0.0,});
}

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class DistanceAR extends StatefulWidget {
  @override
  _DistanceARState createState() => _DistanceARState();
}

class _DistanceARState extends State<DistanceAR> {
  late ArCoreController arCoreController;

  late String anchorId;
  late ArCorePlane plane ;

  @override
  Widget build(BuildContext context) {
    String itemImage = "";

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Hello World'),
          ),
          body: Container(
              width: 500,
              height: 500,
              child: Column(
                children: [
                  ArCoreView(
                    onArCoreViewCreated: _onArCoreViewCreated,
                  ),
                  IconButton(
                      onPressed: () {
                        _addSphere(arCoreController);
                      },
                      icon: Icon(Icons.area_chart_sharp))
                ],
              ))),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = controlOnPlaneTap;

    // _addSphere(arCoreController);
    // _addCylindre(arCoreController);
    // _addCube(arCoreController);
  }

  addAnchor(ArCoreNode node) {
    addPlane(arCoreController, node);
  }

  addPlane(ArCoreController controller, ArCoreNode node) {
    anchorId = node.name!;

    // plane = ArCorePlane.fromMap({"extendX":node.position?.value.x,"extendZ":node.position?.value.z});
    plane.extendX = node.position?.value.x;
    plane.extendZ = node.position?.value.z;

  }

  void controlOnPlaneTap(List<ArCoreHitTestResult> results) {
    final hit = results.first;
    addItemImageToScene(hit);

    print('*****${results.length}');
  }

  Future addItemImageToScene(ArCoreHitTestResult hitTestResult) async {
    final bytes =
        (await rootBundle.load('assets/rover.png')).buffer.asUint8List();
    final imageItem = ArCoreNode(
      image: ArCoreImage(bytes: bytes, width: 300, height: 300),
      // position: vector.Vector3(0, 0, -1.5),
      position: hitTestResult.pose.translation + vector.Vector3(0.0, 0.0, 0.0),
      rotation:
          hitTestResult.pose.rotation + vector.Vector4(0.0, 0.0, 0.0, 0.0),
    );
    arCoreController.addArCoreNodeWithAnchor(imageItem);
    // arCoreController.addArCoreNode(imageItem);
  }

  Future<void> _addSphere(ArCoreController controller) async {
    final material = ArCoreMaterial(color: Color.fromARGB(120, 66, 134, 244),);
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

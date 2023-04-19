import 'dart:io';

import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;


class ScreenshotWidget extends StatefulWidget {
  const ScreenshotWidget({Key? key}) : super(key: key);
  @override
  _ScreenshotWidgetState createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  ARLocationManager? arLocationManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];
   String data = 'Data';

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createNewGlbFile();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Screenshots'),
        ),
        body: 
        Container(
            child:
          Stack(children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: (){

                    // Matrix4 mat4 = arSessionManager!.getCameraPose() as Matrix4;
                    // data = mat4.forward.toString();
                    calDisFromCamera();

                }, child: Text(data , style: TextStyle(color:Color.fromARGB(255, 58, 255, 123)),),),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: onRemoveEverything,
                          child: const Text("Remove Everything")),
                      ElevatedButton(
                          onPressed: onTakeScreenshot,
                          child: const Text("Take Screenshot")),
                    ])
              ],
            ),
          )
        ])));
  }
  Future<void> calDisFromCamera() async {

    final matrix4 = await  arSessionManager!.getCameraPose();
    if (matrix4 != null) {
      // data = matrix4.forward.toString();
      // data = arSessionManager!.getDistanceBetweenVectors(matrix4.forward, nodes[0].position).toString();

      Vector3 start = matrix4.getTranslation();
      Vector3 end = nodes[0].transform.getTranslation();

      double _distance = math.sqrt(
        math.pow(end.x - start.x, 2) +
            math.pow(end.y - start.y, 2) +
            math.pow(end.z - start.z, 2),
      );
      // data = _distance.toString();

     setState(() {
       data=  anchors[0].transformation.getTranslation().distanceTo(matrix4.getTranslation()).toString();
     });

      // double? x = await arSessionManager!.getDistanceBetweenAnchors(anchors[1], anchors[2]);
    //   if(x != null){
    //     data = x.toString();
    // }


    } else {
      // Handle the case where the future returns null
      // ...
    }
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;
    this.arLocationManager = arLocationManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: true,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onNodeTap = onNodeTapped;
  }

  Future<void> onRemoveEverything() async {
    /*nodes.forEach((node) {
      this.arObjectManager.removeNode(node);
    });*/
    // anchors.forEach((anchor)
    for (var anchor in anchors)
     {
      arAnchorManager!.removeAnchor(anchor);
    };
    anchors = [];
  }

  Future<void> onTakeScreenshot() async {
    var image = await arSessionManager!.snapshot();
    await showDialog(
        context: context,
        builder: (_) => Dialog(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(image: image, fit: BoxFit.cover)),
              ),
            ));
  }

  Future<File> createNewGlbFile() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path;
    File file = File('$path/map_pin2.glb');
    ByteData data = await rootBundle.load('assets/map_pin2.glb');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  }
  Future<void> onNodeTapped(List<String> nodes) async {
    var number = nodes.length;
    arSessionManager!.onError("Tapped $number node(s)");
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      var newAnchor =
          ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor != null && didAddAnchor) {
        anchors.add(newAnchor);
        // Add note to anchor
        // var newNode = ARNode(
        //     type: NodeType.webGLB,
        //     uri:
        //         "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
        //     scale: Vector3(0.2, 0.2, 0.2),
        //     position: Vector3(0.0, 0.0, 0.0),
        //     rotation: Vector4(1.0, 0.0, 0.0, 0.0));
        var newNode = ARNode(
            type: NodeType.fileSystemAppFolderGLB,
            uri: "map_pin2.glb",
            scale: Vector3(0.2, 0.2, 0.2),
            position: Vector3(0.0, 0.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0));

        bool? didAddNodeToAnchor =
            await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
        
        if (didAddNodeToAnchor != null && didAddNodeToAnchor) {
          nodes.add(newNode);
        } else {
          arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        arSessionManager!.onError("Adding Anchor failed");
      }
      /*
      // To add a node to the tapped position without creating an anchor, use the following code (Please mind: the function onRemoveEverything has to be adapted accordingly!):
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "Models/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          transformation: singleHitTestResult.worldTransform);
      bool didAddWebNode = await this.arObjectManager.addNode(newNode);
      if (didAddWebNode) {
        this.nodes.add(newNode);
      }*/
    }
  }
}
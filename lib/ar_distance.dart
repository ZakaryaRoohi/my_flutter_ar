import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DistanceMeasureScreen extends StatefulWidget {
  @override
  _DistanceMeasureScreenState createState() => _DistanceMeasureScreenState();
}

class _DistanceMeasureScreenState extends State<DistanceMeasureScreen> {
  late ArCoreController arCoreController;
  List<ArCoreHitTestResult> hits = [];
  late ArCoreNode startNode;
  late ArCoreNode endNode;
  double distance = 0.0;

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  void onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap= _onTapArPlane;
  }

  void _onTapArPlane(List<ArCoreHitTestResult> results) {
    setState(() {
      ArCoreHitTestResult hit = results.first;
      hits.add(hit);
      if (hits.length == 1) {
        startNode = ArCoreNode(
          shape: ArCoreSphere(
            radius: 0.02,
            materials: [ArCoreMaterial(color: Colors.green)],
          ),
        );
        startNode.position!.value = hit.pose.translation;
        arCoreController.addArCoreNode(startNode);
      } else if (hits.length == 2) {
        endNode = ArCoreNode(
          shape: ArCoreSphere(
            radius: 0.02,
            materials: [ArCoreMaterial(color: Colors.red)],
          ),
        );
        endNode.position?.value = hit.pose.translation;
        arCoreController.addArCoreNode(endNode);
        distance = _calculateDistance(startNode, endNode);
      }
    });
  }

  double _calculateDistance(ArCoreNode start, ArCoreNode end) {
    double distance = math.sqrt(
      math.pow(end.position!.value.x - start.position!.value.x, 2) +
          math.pow(end.position!.value.y - start.position!.value.y, 2) +
          math.pow(end.position!.value.z - start.position!.value.z, 2),
    );
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distance Measure'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: onArCoreViewCreated,
        enableTapRecognizer: true,

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            hits.clear();
            distance = 0.0;
            arCoreController.removeNode( nodeName: startNode.name);
            arCoreController.removeNode(nodeName: endNode.name);
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

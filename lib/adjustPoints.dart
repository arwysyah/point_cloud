import 'package:point_cloud/interface/vector.dart';

List<Vector> adjustPoint(List<Vector> args, double range, double targetZ) {
  final List<Vector> dataPoints = [...args];
  List<Vector> tempPointsData = [];
  for (int i = 0; i <= dataPoints.length - 1; i += 1) {
    final x = dataPoints[i].getDX();
    final y = dataPoints[i].getDY();
    final z = dataPoints[i].getDZ();
    if (z < targetZ - range) {
      tempPointsData.add(Vector(x, y, z));
    }
  }
  return tempPointsData;
}

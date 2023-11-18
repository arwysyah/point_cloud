import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/utils/painter_constant.dart';

compressFile(List<Vector> arg) {
  List<Vector> points = [];
  for (int i = 0; i <= arg.length - 1; i += interval) {
    final x = arg[i].getDX();
    final y = arg[i].getDY();
    final z = arg[i].getDZ();
    points.add(Vector(x, y, z));
  }
  return points;
}

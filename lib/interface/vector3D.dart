import 'package:flutter/material.dart';

class XYZObject {
  final double dx;
  final double dy;
  final double dz;

  final int dr;
  final int dc;

  const XYZObject(this.dx, this.dy, this.dz, this.dr, this.dc);

  Offset toOffset() {
    return Offset(dx, dy);
  }

  getDX() {
    return dx;
  }

  getDY() {
    return dy;
  }

  getDZ() {
    return dz;
  }

  getDC() {
    return dc;
  }

  getDR() {
    return dr;
  }

  // MyVector translate(double dxs, double dys, double dzs) {
  //   return MyVector(dx + dxs, dy + dys, dz + dzs,d);
  // }

  @override
  String toString() {
    return 'Offset3D($dx, $dy, $dz)';
  }
}

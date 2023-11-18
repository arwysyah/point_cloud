import 'package:flutter/material.dart';

class Vector {
  final double dx;
  final double dy;
  final double dz;

  const Vector(this.dx, this.dy, this.dz);

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

  @override
  String toString() {
    return 'Offset3D($dx, $dy, $dz)';
  }
}

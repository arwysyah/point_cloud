import 'package:flutter/material.dart';

class Storage {
  final double dx;
  final double dy;
  final double dz;
  final double centerLine;
  final double topLine;
  final double bottomLine;

  const Storage(this.dx, this.dy, this.dz, this.centerLine, this.topLine,
      this.bottomLine);

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

  getCenterLine() {
    return centerLine;
  }

  getTopLine() {
    return topLine;
  }

  getBottomLine() {
    return bottomLine;
  }

  @override
  String toString() {
    return 'Offset3D($dx, $dy, $dz)';
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/interface/vector3D.dart';

List<Vector> points = [];
List<Vector> copiedPoints = [];
List<Vector> cuttedPoint = [];
double limit = 0.02;
double zResult = 0;
bool isButtonRotateClicked = false;
Offset highestAndLowestZ = const Offset(0, 0);
bool isButtonTranslateClicked = false;
int cuttedPlane = 0;
Timer? lineTimer;
double scale = 1.0;
// double scale = 40.0;
Vector centerXYZ = const Vector(0, 0, 0);
Offset translate = Offset.zero;
double previousScale = 1.0;
Offset previousTranslate = Offset.zero;
Offset currentFocalPoint = Offset.zero;
bool loadPointLoading = false;
double lowestLine = 0;
double topLine = 0;
double maxZ = double.infinity;
double scaleItem = 1.0;
// double scaleItem = 40.0;
Offset translateItem2 = Offset.zero;
double previousScaleItem2 = 1.0;
Offset translate2 = Offset.zero;
Offset previousTranslateItem2 = Offset.zero;
Offset currentFocalPointItem2 = Offset.zero;
List<Offset> translatedPoints = [];
List<Offset> translatedSecondPoints = [];
Offset center = const Offset(250, 250);
double centerZ = 0;
List<Offset> clickedPoints = [];
double angle = 0.0;
bool loading = false;
double highestY = 0;
double lowestZ = 0;
double highestZ = 0;
String targetZCoordinate = '0';
double centerGreenLine = 0;
var entity = '';
double targetZ = 0;
double widthDevider = 2.2;
double heightDevider = 1.2;
double maxY = 0, minY = 0;
List<XYZObject> fullPoints = [];

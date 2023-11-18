import 'dart:async';
import 'package:flutter/material.dart';
import 'package:point_cloud/interface/temp_storage.dart';
import 'package:point_cloud/interface/vector3D.dart';
import 'package:point_cloud/utils/file_compressor.dart';
import 'package:point_cloud/utils/extactor_data.dart';
import 'package:point_cloud/utils/file_loader.dart';
import 'package:point_cloud/utils/file_loader_interface.dart';
import 'package:point_cloud/utils/painter_constant.dart';
import 'package:point_cloud/utils/rotatePoint.dart';
import 'package:point_cloud/utils/xyz_variable.dart';
import 'package:point_cloud/xyx_preview.dart';
import 'package:point_cloud/xyz_painter.dart';
import 'package:point_cloud/xyz_painter2.dart';
import 'package:point_cloud/interface/vector.dart';
import './utils/exporter_plane.dart';

class XyzViewer extends StatefulWidget {
  const XyzViewer({Key? key}) : super(key: key);

  @override
  _XyzViewerState createState() => _XyzViewerState();
}

void main() {
  runApp(const MaterialApp(
    home: XyzViewer(),
  ));
}

class _XyzViewerState extends State<XyzViewer> {
  String targetZCoordinate = '0';
  var entity = '';
  double targetZ = 0;

  @override
  void dispose() {
    lineTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFile() async {
    setState(() {
      scale = 1.0;
      translate = Offset.zero;
    });
    final fileLoader = FileLoader(points);
    await fileLoader.loadFile(context, double.parse(targetZCoordinate));

    List<Vector> loadedPoints = fileLoader.points;
    List<XYZObject> originalPoints = fileLoader.originalPointCloud;

    double highest = fileLoader.highestZCoord;
    double lowest = fileLoader.lowestZCoord;
    double centerX = fileLoader.centerXCoord;
    double centerY = fileLoader.centerYCoord;
    Offset centerXY = Offset(centerX, centerY);
    double highestY = fileLoader.highestYCoord;
    double centerZAxis = fileLoader.centerZCoord;

    List<Vector> compressedFile = await compressFile(loadedPoints);
    List<Vector> cutList = fileLoader.newPoint;

    setState(() {
      points = compressedFile;
      loading = false;
      center = centerXY;
      highestY = highestY;
      lowestZ = lowest;
      highestZ = highest;
      centerZ = centerZAxis;
      fullPoints = originalPoints;
      cuttedPoint = cutList;
      zResult = 0;
      highestAndLowestZ = Offset(highest, lowest);
    });
  }

  void _resetView() {
    setState(() {
      scale = 1.0;
      translate = Offset.zero;
      points = [];
      copiedPoints = [];
      points = [];
      translatedPoints.clear();
      cuttedPoint = [];
      clickedPoints.clear();
      translateItem2 = Offset.zero;
      scaleItem = 1.0;
      zResult = 0;
      center = Offset.zero;
      highestAndLowestZ = Offset.zero;
    });
  }

  bool isFarAway(double zAxis) {
    return zAxis > targetZ || zAxis < targetZ - limit;
  }

  bool isAboveTargetZCoordinate(double zAxis) {
    return zAxis < zAxis - double.parse(targetZCoordinate) + limit ||
        zAxis < targetZ - limit;
  }

  void rotatePoints() {
    List<Vector> data = rotateXYPoint(points, center, angle);
    final newPoint =
        PointCloudUtils.findCuttedPoint(data, scaleItem, translateItem2);

    setState(() {
      points = data;
      cuttedPoint = newPoint;
    });
  }

  double getTheLine(double zCoordinate) {
    return -zCoordinate * angleZ * defaultScale * scaleAsMultiplier;
  }

  void setStateZ(double dz) {
    setState(() {
      zResult = dz;
    });
  }

  List<Offset> transformedPoints(List<Vector> arg) {
    final newPoints = arg.map((point) {
      final pointY = -point.getDZ() * angleZ * defaultScale * scaleAsMultiplier;

      final lowestPoint = (lowestZ + 1);

      final centerLine =
          -lowestPoint * angleZ * defaultScale * scaleAsMultiplier;
      final bottomLine = -lowestZ * angleZ * defaultScale * scaleAsMultiplier;
      final topLine = -highestZ * angleZ * defaultScale * scaleAsMultiplier;

      double pointX = point.dx * scaleOfPoint + heightOfSize / 2;
      double x = pointX;

      return Storage(x, pointY, point.getDZ(), centerLine, topLine, bottomLine);
    }).toList();

    if (newPoints.isNotEmpty) {
      maxY = newPoints.map((point) => point.dy).reduce((a, b) => a > b ? a : b);
      minY = newPoints.map((point) => point.dy).reduce((a, b) => a > b ? a : b);
    }
    double heightRange = maxY - minY;
    double centerHeight = minY + (heightRange / 2);
    double heightTranslate = firstCanvas.height / heightDevider;
    double widthTranslate = firstCanvas.width / widthDevider;
    return newPoints.map((point) {
      double x = point.dx + heightTranslate;
      double y = (point.dy - centerHeight) + widthTranslate + translate.dy;

      translate.dy;
      double centerZ = (point.centerLine - centerHeight) + heightTranslate;
      double topLines = (point.topLine - centerHeight) + heightTranslate;
      double bottomLines = (point.bottomLine - centerHeight) + heightTranslate;
      setState(() {
        centerGreenLine = centerZ;
        topLine = topLines;
        lowestLine = bottomLines;
      });

      Offset transformedPoint = Offset(x, y);

      if (transformedPoint.dy > centerZ - lineWidth &&
          transformedPoint.dy < centerZ + lineWidth) {
        setState(() {
          zResult = point.getDZ();
        });
      }

      return transformedPoint;
    }).toList();
  }

  void startRotation() {
    clickedPoints.clear();
    setState(() {
      isButtonRotateClicked = !isButtonRotateClicked;
      isButtonTranslateClicked = false;
      translatedPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const initialScale = 15;
    const isLineCanvasExist = true;
    const opacity = 0.1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('XYZ Viewer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      scale = 1.0;
                    });
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 12,
                          child: GestureDetector(
                            onPanStart: (details) {
                              previousTranslate = translate;
                            },
                            onPanUpdate: (details) {
                              setState(() {
                                translate = translate + details.delta;
                              });
                            },
                            child: SizedBox(
                              child: CustomPaint(
                                painter: XyzPainter(
                                  transformedPoints(cuttedPoint),
                                  scale,
                                  translate,
                                  centerXYZ,
                                  translatedPoints,
                                  highestY,
                                  lowestLine,
                                  topLine,
                                  centerGreenLine,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  height: 400,
                  width: 500,
                  right: 0,
                  child: GestureDetector(
                    onScaleStart: (details) {
                      previousScaleItem2 = scaleItem;
                      previousTranslateItem2 = translateItem2;
                      currentFocalPoint = details.focalPoint;
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        cuttedPoint = [];
                      });

                      if (!isButtonRotateClicked || !isButtonTranslateClicked) {
                        Offset deltaTranslate =
                            details.focalPoint - currentFocalPoint;
                        setState(() {
                          double deltaScale = details.scale;

                          scaleItem = previousScaleItem2 * deltaScale;
                          translateItem2 = previousTranslateItem2 +
                              deltaTranslate / scaleItem;
                          cuttedPoint = PointCloudUtils.findCuttedPoint(
                              points, scaleItem, translateItem2);
                        });
                      }
                    },
                    onDoubleTap: () {
                      if (!isButtonRotateClicked) {
                        setState(() {
                          scaleItem = 1.0;
                        });
                      }
                    },
                    onSecondaryTapDown: (details) {
                      setState(() {
                        if (clickedPoints.length < 3) {
                          clickedPoints.add(details.localPosition);
                          if (clickedPoints.length == 3) {
                            calculateRotationAngle(clickedPoints);
                            rotatePoints();

                            lineTimer?.cancel();
                            lineTimer =
                                Timer(const Duration(milliseconds: 200), () {
                              setState(() {
                                clickedPoints.clear();
                                isButtonRotateClicked = false;
                              });
                            });
                          }
                        }
                      });
                    },
                    child: CustomPaint(
                      painter: XyzPainter2(
                          points,
                          scaleItem,
                          translateItem2,
                          centerXYZ,
                          translatedSecondPoints,
                          targetZ,
                          center,
                          clickedPoints,
                          angle,
                          initialScale,
                          isLineCanvasExist,
                          opacity),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
              child: Visibility(
            visible: loading,
            child: const LinearProgressIndicator(),
          )),
          Container(
            child: loadPointLoading ? const CircularProgressIndicator() : null,
          ),
          ButtonBar(
            children: [
              ElevatedButton(
                onPressed: _loadFile,
                child: const Text('Load File'),
              ),
              ElevatedButton(
                onPressed: _resetView,
                child: const Text('Reset View'),
              ),
              Visibility(
                  visible: points.isNotEmpty,
                  child: ButtonBar(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              loadPointLoading = false;
                            });
                            final file = PointCloudExporter(
                                context, originalPoints, zResult);
                            final result = await file.findClosestPoints();
                            await file.exportToDxf(result, limit);
                          },
                          child: const Text("export To DXF")),
                      ElevatedButton(
                        child: const Text('Preview'),
                        onPressed: () {
                          if (zResult != 0.0) {
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => XYZPreview(
                                        zResult,
                                        centerXYZ,
                                        zResult.toString(),
                                      )),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Calculating and Cutting the plane ....."),
                              ),
                            );
                          }
                        },
                      ),
                      Text("Z axis : $zResult"),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

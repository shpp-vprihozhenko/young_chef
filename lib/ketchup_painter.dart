import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class KetchupPainter extends StatefulWidget {
  const KetchupPainter({Key? key}) : super(key: key);

  @override
  State<KetchupPainter> createState() => _KetchupPainterState();
}

class _KetchupPainterState extends State<KetchupPainter> {
  List<List <Offset>> ketchup=[], mustard=[], mayonnaise=[];
  List <Offset> curLine = [];
  int selectedSauceIdx = 0;
  GlobalKey _globalKey = GlobalKey();

  final cutPlayer = AudioPlayer();
  final sendPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _prepareSounds();
  }

  @override
  void dispose() {
    cutPlayer.dispose();
    sendPlayer.dispose();
    super.dispose();
  }

  _prepareSounds() async {
    await cutPlayer.setVolume(1);
    await cutPlayer.setAsset('assets/mp3/ketchup.mp3');
    await cutPlayer.setLoopMode(LoopMode.off);

    await sendPlayer.setVolume(1);
    await sendPlayer.setAsset('assets/mp3/send.mp3');
    await sendPlayer.setLoopMode(LoopMode.off);
  }

  _sendToMammy() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      glPngBytes = byteData!.buffer.asUint8List();
      String fileName = await _writeByteToImageFile(byteData!);
      glSaveToMyImages(fileName);
      sendPlayer.seek(Duration.zero);
      sendPlayer.play();
      ShareExtend.shareMultiple([fileName], "image", subject: "Приятного аппетита!");
      Future.delayed(Duration(seconds: 5), (){
        Navigator.pushNamed(context, '/');
        printD('pushNamed');
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> _writeByteToImageFile(ByteData byteData) async {
    Directory? dir = await getApplicationDocumentsDirectory();
//    Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();

    File imageFile = File("${dir!.path}/povar/${DateTime.now().millisecondsSinceEpoch}.png");
    imageFile.createSync(recursive: true);
    imageFile.writeAsBytesSync(byteData.buffer.asUint8List(0));
    return imageFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('И теперь украсим!'),),
      body: Column(
        children: [
          Container(
            width: glWorkTableSize.width,
            height: glTopReservedHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    selectedSauceIdx = 0;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    color: selectedSauceIdx==0? Colors.purple[100] : null,
                    child: Image.asset('assets/images/кетчуп2.webp'),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    selectedSauceIdx = 1;
                    setState(() {});
                  },
                  child: Container(
                      padding: const EdgeInsets.all(12.0),
                      color: selectedSauceIdx==1? Colors.purple[100] : null,
                      child: Image.asset('assets/images/горчица.webp')
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    selectedSauceIdx = 2;
                    setState(() {});
                  },
                  child: Container(
                      padding: const EdgeInsets.all(12.0),
                      color: selectedSauceIdx==2? Colors.purple[100] : null,
                      child: Image.asset('assets/images/майонез2.webp')
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: RepaintBoundary(
                key: _globalKey,
                child: CustomPaint(
                  size: glWorkTableSize,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -glTopReservedHeight, left: 0,
                          child: Image.memory(glPngBytes!)
                      ),
                      Positioned(
                        left: 0, top: 0,
                        child: GestureDetector(
                          onPanStart: (DragStartDetails details){
                            curLine = [];
                            Offset startOffset = details.globalPosition-Offset(0, topMargin+glTopReservedHeight);
                            curLine.add(startOffset);
                            printD('start with ${details.globalPosition} glTopReservedHeight $glTopReservedHeight+$topMargin= startOffset $startOffset');
                            cutPlayer.seek(Duration.zero);
                            cutPlayer.play();
                          },
                          onPanEnd: (DragEndDetails details){
                            if (selectedSauceIdx == 0) {
                              ketchup.add(curLine);
                            } else if (selectedSauceIdx == 1) {
                              mustard.add(curLine);
                            } if (selectedSauceIdx == 2) {
                              mayonnaise.add(curLine);
                            }
                            curLine = [];
                            setState(() {});
                          },
                          onPanUpdate: (DragUpdateDetails details){
                            if (details.delta.dx == 0 && details.delta.dy == 0) {
                              return;
                            }
                            //printD('onPanUpdate with $details}');
                            curLine.add(details.globalPosition-Offset(0, topMargin+glTopReservedHeight));
                            setState(() {});
                          },
                          child: Container(
                            width: glWorkTableSize.width,
                            height: glWorkTableSize.height-glTopReservedHeight,
                            color: Colors.grey.withOpacity(0.01),
                          ),
                        ),
                      )
                    ],
                  ),
                  foregroundPainter: MyPainter(ketchup, mustard, mayonnaise, selectedSauceIdx, curLine),
                ),
              ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: _sendToMammy,
        child: AvatarGlow(
          glowColor: Colors.red,
          endRadius: 50,
          child: ClipOval(
            child: Container(
              width: 90, height: 90,
              color: Colors.blue.withOpacity(0.3),
              padding: const EdgeInsets.all(12.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/send.webp'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  List <List <Offset>> ketchup=[], mustard=[], mayonnaise=[];
  List <Offset> curLine = [];
  int selectedSauceIdx = 0;

  MyPainter(this.ketchup, this.mustard, this.mayonnaise, this.selectedSauceIdx, this.curLine);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.srcOver;

    ketchup.forEach((line) {
      _paintLine(line, canvas, paint);
    });
    paint.color = Colors.yellow[700]!;
    mustard.forEach((line) {
      _paintLine(line, canvas, paint);
    });
    paint.color = Colors.white70!;
    mayonnaise.forEach((line) {
      _paintLine(line, canvas, paint);
    });
    if (curLine.length > 1) {
      if (selectedSauceIdx == 0) {
        paint.color = Colors.red;
      } else if (selectedSauceIdx == 1) {
        paint.color = Colors.yellow;
      } else {
        paint.color = Colors.white70;
      }
      _paintLine(curLine, canvas, paint);
    }
  }

  void _paintLine(List<Offset> points, Canvas canvas, Paint paint) {
    final start = points.first;
    final path = Path()..fillType = PathFillType.evenOdd;

    path.moveTo(start.dx, start.dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

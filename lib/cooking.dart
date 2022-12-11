import 'dart:typed_data';
import 'ketchup_painter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'globals.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class Cooking extends StatefulWidget {
  const Cooking({Key? key}) : super(key: key);

  @override
  State<Cooking> createState() => _CookingState();
}

class _CookingState extends State<Cooking> {
  List <IngredientOnMap> ingredientsOnMap = [];
  int draggingIdx = -1;
  double ingredientsListZoneHeight = 0;
  GlobalKey _globalKey = GlobalKey();
  bool isSharing = false;

  final aPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    for (int idx=0; idx<glFinalIngredients.length; idx++) {
      IngredientOnMap ingredientOnMap = IngredientOnMap(glFinalIngredients[idx], Offset(0,0));
      ingredientOnMap.idx = idx;
      ingredientOnMap.size = Size(ingredientsListZoneHeight*0.8, ingredientsListZoneHeight*0.8);
      ingredientsOnMap.add(ingredientOnMap);
    }
    _prepareSounds();
  }

  @override
  void dispose() {
    aPlayer.dispose();
    super.dispose();
  }

  _prepareSounds() async {
    await aPlayer.setVolume(0.05);
    await aPlayer.setAsset('assets/mp3/kolhoz.mp3');
    await aPlayer.setLoopMode(LoopMode.all);
    aPlayer.play();
  }

  _fillIngredientsOnMapWidgets(){
    for (int idx=0; idx<ingredientsOnMap.length; idx++) {
      if (ingredientsOnMap[idx].size.width == 0) {
        ingredientsOnMap[idx].size = Size(ingredientsListZoneHeight*0.8, ingredientsListZoneHeight*0.8);
      }
      ingredientsOnMap[idx].widget = ingredientOnMapW(ingredientsOnMap[idx]);
    }
  }

  Widget ingredientOnMapW(IngredientOnMap ingredientOnMap) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Transform.rotate(
          angle: ingredientOnMap.angle*3.1415926/180,
          child: Container(
            width: ingredientOnMap.size.width,
            height: ingredientOnMap.size.height,
            child: Image.asset('assets/images/${ingredientOnMap.ingredient.img}',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      onPanStart: (DragStartDetails details){
        printD('start $details for ${ingredientOnMap} topMar $topMargin');
        if (ingredientOnMap.state == 0) {
          ingredientOnMap.position = details.globalPosition
              - Offset(0, topMargin)
              - Offset(ingredientOnMap.size.width/2, ingredientOnMap.size.height/2)
          ;
        }
        printD('ingredientOnMap.position ${ingredientOnMap.position} with ingredientsListZoneHeight $ingredientsListZoneHeight size ${ingredientOnMap.size}');
        ingredientOnMap.state = 1;
        ingredientOnMap.layerNumber = maxLayer()+1;
        draggingIdx = ingredientOnMap.idx;
        setState(() {});
      },
      onPanUpdate: (DragUpdateDetails details) {
        if (details.delta.dx == 0 && details.delta.dy == 0) {
          return;
        }
        printD('update for ${ingredientOnMap}');
        ingredientsOnMap[draggingIdx].position += details.delta;
        setState(() {});
      },
      onPanEnd: (DragEndDetails details) {
        printD('onPanEnd $details for ${ingredientOnMap}');
        printD('position.dy ${ingredientsOnMap[draggingIdx].position.dy} ws ingredientsListZoneHeight $ingredientsListZoneHeight');
        if (ingredientsOnMap[draggingIdx].position.dy < ingredientsListZoneHeight/3) {
          printD('position.dy ${ingredientsOnMap[draggingIdx].position.dy} ws ingredientsListZoneHeight $ingredientsListZoneHeight');
          ingredientsOnMap[draggingIdx].state = 0;
          ingredientsOnMap[draggingIdx].size = Size(ingredientsListZoneHeight, ingredientsListZoneHeight);
        }
        draggingIdx = -1;
        setState(() {});
      },
      onLongPress: (){
        printD('onTap for ${ingredientOnMap}');
        showIngredient(context, ingredientOnMap.ingredient);
      },
      onTap: (){
        showIngredient(context, ingredientOnMap.ingredient);
        setState(() {});
      },
      onDoubleTap: (){
        ingredientOnMap.layerNumber = maxLayer()+1;
        setState(() {});
        printD('ingredientOnMap $ingredientOnMap layerNumber ${ingredientOnMap.layerNumber}');
      },
    );
  }

  List <Widget> ingredientsToPrepareWL(){
    // int ingredientsToPrepareQuantity = ingredientsOnMap.where((element) => element.state == 0).length;
    int counter = 0;
    List <Widget> lw = [];
    for (int idx=0; idx < ingredientsOnMap.length; idx++) {
      IngredientOnMap ingredientOnMap = ingredientsOnMap[idx];
      //printD('$ingredientOnMap draggingIdx $draggingIdx counter $counter ingredientsToPrepareQuantity $ingredientsToPrepareQuantity idx $idx');
      if (idx == draggingIdx && idx == ingredientsOnMap.length-1) {
        lw.add(SizedBox(width: ingredientOnMap.size.width,));
        continue;
      }
      if (ingredientOnMap.state != 0) {
        continue;
      }
      lw.add(ingredientOnMap.widget!);
      counter++;
    }
    return lw;
  }

  List <Widget> pos_ingredientsWL(){
    List <Widget> lw = [];
    List <IngredientOnMap> im = [];
    for (int idx=0; idx < ingredientsOnMap.length; idx++) {
      IngredientOnMap ingredientOnMap = ingredientsOnMap[idx];
      if (!ingredientOnMap.isEnabled) {
        continue;
      }
      if (ingredientOnMap.state == 0) {
        continue;
      }
      im.add(ingredientOnMap);
    }
    im.sort((i1, i2)=>
      i1.layerNumber.compareTo(i2.layerNumber)
    );
    for (int idx=0; idx<im.length; idx++) {
      IngredientOnMap ingredientOnMap = im[idx];
      lw.add(
          Positioned(
              left: ingredientOnMap.position.dx,
              top: ingredientOnMap.position.dy,
              child: Container(
                width: ingredientOnMap.size.width+12,
                height: ingredientOnMap.size.height+12,
                child: Stack(
                  children: [
                    Positioned(
                        top: 0, left: 0,
                        child: ingredientOnMap.widget!
                    ),
                    isSharing?
                    SizedBox()
                    :
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        child: Icon(Icons.aspect_ratio, size: 32,),
                        onPanUpdate: (DragUpdateDetails details){
                          if (details.delta.dx==0 && details.delta.dy==0) {
                            return;
                          }
                          printD('resize1 for $ingredientOnMap delta ${details.delta}');
                          ingredientOnMap.size += details.delta;
                          double dx = ingredientOnMap.size.width;
                          double dy = ingredientOnMap.size.height;
                          if (dx < 20) {
                            dx = 20;
                          }
                          if (dy < 20) {
                            dy = 20;
                          }
                          if (dx>dy) {
                            dy = dx;
                          } else {
                            dx = dy;
                          }
                          ingredientOnMap.size = Size(dx, dy);
                          printD('resize2 for $ingredientOnMap delta ${details.delta}');
                          setState(() {});
                        },
                      ),
                    ),
                    isSharing?
                    SizedBox()
                        :
                    Positioned(
                      bottom: 0, left: 0,
                      child: GestureDetector(
                        child: Icon(Icons.rotate_left, size: 32,),
                        onPanUpdate: (DragUpdateDetails details){
                          if (details.delta.dx==0 && details.delta.dy==0) {
                            return;
                          }
                          printD('rotate for $ingredientOnMap delta ${details.delta}');
                          ingredientOnMap.angle -= (details.delta.dx+details.delta.dy);
                          printD('rotate for $ingredientOnMap delta ${details.delta}');
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              )
          )
      );
    }
    return lw;
  }

  maxLayer(){
    int layer = 0;
    ingredientsOnMap.forEach((element) {
      if (element.layerNumber > layer) {
        layer = element.layerNumber;
      }
    });
    return layer;
  }

  _go() async {
    isSharing = true;
    setState(() {});
    Future.delayed(Duration(milliseconds: 20), (){
      _goToKetchupPaint();
      isSharing = false;
    });
  }

  _goToKetchupPaint() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      glPngBytes = byteData!.buffer.asUint8List();
      aPlayer.pause();
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const KetchupPainter()));
      aPlayer.play();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarW = AppBar(
      title: Row(
        children: [
          Expanded(child: Text('Приготовь ${glProductToMake.name}', overflow: TextOverflow.clip,)),
          IconButton(
            onPressed: (){
              glShowRequiredIngredients(context, glProductToMake);
            }, icon: Icon(Icons.help, size: 32, color: Colors.yellow,),
          ),
        ],
      ),
    );
    Size screenSize = MediaQuery.of(context).size;
    topMargin = appBarW.preferredSize.height + MediaQuery.of(context).padding.top;
    Size size = Size(screenSize.width, screenSize.height - topMargin);
    glWorkTableSize = size;
    ingredientsListZoneHeight = glTopReservedHeight;
    _fillIngredientsOnMapWidgets();
    return Scaffold(
      appBar: appBarW,
      body: RepaintBoundary(
        key: _globalKey,
        child: Container(
          width: size.width,
          height: size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: 0, left: 0,
                  child: Container(
                    color: Colors.yellow[200],
                    width: size.width, height: ingredientsListZoneHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ingredientsToPrepareWL(),
                    ),
                  )
              ),
              Positioned(
                top: ingredientsListZoneHeight, left: 0,
                child: Container(
                  color: Colors.lightBlue[200],
                  width: size.width, height: size.height-ingredientsListZoneHeight,
                ),
              ),
              ...pos_ingredientsWL(),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _go,
        child: AvatarGlow(
          glowColor: Colors.red,
          endRadius: 50,
          child: ClipOval(
            child: Container(
              width: 80, height: 80,
              color: Colors.blue.withOpacity(0.6),
              padding: const EdgeInsets.all(12.0),
              child: Image.asset('assets/images/goCooking.webp', width: 70, height: 70,),
            ),
          ),
        ),
      ),
    );
  }
}


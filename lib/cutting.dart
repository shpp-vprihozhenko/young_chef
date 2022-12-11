import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'cooking.dart';
import 'globals.dart';
import 'package:just_audio/just_audio.dart';

class Cutting extends StatefulWidget {
  const Cutting({Key? key}) : super(key: key);

  @override
  State<Cutting> createState() => _CuttingState();
}

class _CuttingState extends State<Cutting> {
  double knifeLeft = -1, knifeTop = -1;
  List <IngredientOnMap> ingredientsOnMap = [];
  int draggingIdx = -1;
  double ingredientsListZoneHeight = 0, cuttingBoardZoneHeight = 0;
  List <IngredientOnMap> cutPiecesOnMap = [];
  bool isVibration = false;

  final cutPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    for (int idx=0; idx<glCartIngredients.length; idx++) {
      IngredientOnMap ingredientOnMap = IngredientOnMap(glCartIngredients[idx], Offset(0,0));
      ingredientOnMap.idx = idx;
      ingredientOnMap.cutQuantity = glCartIngredients[idx].cutQuantity;
      ingredientsOnMap.add(ingredientOnMap);
    }
    Vibration.hasVibrator().then((value) {
      isVibration = value!;
      printD('isVibration $isVibration');
    });
    _prepareSounds();
  }

  @override
  void dispose() {
    cutPlayer.dispose();
    super.dispose();
  }

  _prepareSounds() async {
    await cutPlayer.setVolume(1);
    await cutPlayer.setAsset('assets/mp3/cut.mp3');
    await cutPlayer.setLoopMode(LoopMode.off);
  }

  _fillIngredientsOnMapWidgets(){
    for (int idx=0; idx<ingredientsOnMap.length; idx++) {
      ingredientsOnMap[idx].widget = ingredientOnMapW(ingredientsOnMap[idx]);
    }
  }

  Widget ingredientOnMapW(IngredientOnMap ingredientOnMap) {
    double ingredientHeight = ingredientsListZoneHeight*0.8;
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/images/${ingredientOnMap.ingredient.img}',
            height: ingredientHeight, width: ingredientHeight,
        ),
      ),
      onPanStart: (DragStartDetails details){
        printD('start $details for ${ingredientOnMap}');
        ingredientOnMap.position = details.globalPosition + Offset(-ingredientHeight/2,-ingredientHeight);
        ingredientOnMap.state = 1;
        draggingIdx = ingredientOnMap.idx;
        setState(() {});
      },
      onPanUpdate: (DragUpdateDetails details) {
        if (details.delta.dx == 0 && details.delta.dy == 0) {
          return;
        }
        printD('update $details for ${ingredientOnMap}');
        ingredientsOnMap[draggingIdx].position += details.delta;
        setState(() {});
      },
      onPanEnd: (DragEndDetails details) {
        printD('onPanEnd $details for ${ingredientOnMap}');
        if (ingredientsOnMap[draggingIdx].position.dy < ingredientsListZoneHeight/2) {
          ingredientsOnMap[draggingIdx].state = 0;
          setState(() {});
        }
      },
      onTap: (){
        printD('onTap for ${ingredientOnMap}');
        showIngredient(context, ingredientOnMap.ingredient);
      },
    );
  }

  List <Widget> ingredientsToPrepareWL(){
    List <Widget> lw = [];
    for (int idx=0; idx < ingredientsOnMap.length; idx++) {
      IngredientOnMap ingredientOnMap = ingredientsOnMap[idx];
      if (ingredientOnMap.state != 0) {
        continue;
      }
      lw.add(ingredientOnMap.widget!);
    }
    return lw;
  }

  List <Widget> pos_ingredientsWL(){
    List <Widget> lw = [];
    for (int idx=0; idx < ingredientsOnMap.length; idx++) {
      IngredientOnMap ingredientOnMap = ingredientsOnMap[idx];
      if (!ingredientOnMap.isEnabled) {
        continue;
      }
      if (ingredientOnMap.state == 0) {
        continue;
      }
      lw.add(
          Positioned(
            left: ingredientOnMap.position.dx,
            top: ingredientOnMap.position.dy,
            child: ingredientOnMap.widget!
          )
      );
    }
    return lw;
  }

  _cutIngredient(){
    printD('_cutIngredient');
    bool isCutted = false;
    ingredientsOnMap.forEach((ingredientOnMap) {
      if (ingredientOnMap.state == 0 || !ingredientOnMap.isEnabled) {
        return;
      }
      double distance = (ingredientOnMap.position - Offset(knifeLeft, knifeTop)).distance;
      printD('distance $distance for $ingredientOnMap');
      if (distance < 80) {
        if (ingredientOnMap.ingredient.cutPieceName == '') {
          if (isVibration) {
            Vibration.vibrate();
          }
          return;
        }
        int idx = cut_ingredients.indexWhere((element) => element.name == ingredientOnMap.ingredient.cutPieceName);
        if (idx == -1) {
          showAlertPage(context, 'cut ing ${ingredientOnMap.ingredient.cutPieceName} not found');
          return;
        }
        cutPiecesOnMap.add(IngredientOnMap(cut_ingredients[idx], Offset(0,0)));
        ingredientOnMap.cutQuantity--;
        isCutted = true;
        if (ingredientOnMap.cutQuantity == 0) {
          ingredientOnMap.isEnabled = false;
        }
      }
    });
    if (isCutted) {
      cutPlayer.seek(Duration.zero);
      cutPlayer.play();
    }
    setState(() {});
  }

  cutsWL(){
    List <Widget> lw = [];
    for (int idx=0; idx<cutPiecesOnMap.length; idx++) {
      lw.add(Image.asset('assets/images/'+cutPiecesOnMap[cutPiecesOnMap.length-idx-1].ingredient.img, width: cutSize, height: cutSize,));
    }
    return lw;
  }

  _go(){
    glFinalIngredients = [];
    ingredientsOnMap.forEach((ingredientOnMap) {
      if (ingredientOnMap.isEnabled) {
        glFinalIngredients.add(ingredientOnMap.ingredient);
      }
    });
    cutPiecesOnMap.forEach((cutPiece) {
      glFinalIngredients.add(cutPiece.ingredient);
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Cooking()));
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarW = AppBar(
      title: Row(
        children: [
          Expanded(child: Text('Измельчи если надо', overflow: TextOverflow.clip,)),
          IconButton(
            onPressed: (){
              glShowRequiredIngredients(context, glProductToMake);
            }, icon: Icon(Icons.help, size: 32, color: Colors.yellow,),
          ),
        ],
      ),
    );
    Size screenSize = MediaQuery.of(context).size;
    Size size = Size(screenSize.width, screenSize.height - appBarW.preferredSize.height - MediaQuery.of(context).padding.top);
    ingredientsListZoneHeight = size.height / 4;
    cuttingBoardZoneHeight =  size.height / 3;
    if (knifeLeft == -1) {
      knifeLeft = size.width-knifeSize.width;
      _fillIngredientsOnMapWidgets();
    }
    knifeTop = ingredientsListZoneHeight+10;
    return Scaffold(
      appBar: appBarW,
      body: Container(
        width: size.width, height: size.height,
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0,
              child: Container(
                color: Colors.lightBlue,
                width: size.width, height: size.height,
              ),
            ),
            Positioned(
              top: 0, left: 0,
              child: Container(
                width: size.width, height: ingredientsListZoneHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ingredientsToPrepareWL(),
                ),
              ),
            ),
            Positioned(
              top: ingredientsListZoneHeight, left: 10,
                child: Image.asset('assets/images/cutting_board.webp',
                  width: size.width*0.9, height: cuttingBoardZoneHeight,
                )
            ),
            ...pos_ingredientsWL(),
            Positioned(
              top: knifeTop, left: knifeLeft,
                child: GestureDetector(
                  child: Image.asset('assets/images/нож.png', width: knifeSize.width, height: knifeSize.height,),
                  onPanUpdate: (DragUpdateDetails details) {
                    knifeLeft += details.delta.dx;
                    setState(() {});
                  },
                  onTap: _cutIngredient,
                )
            ),
            Positioned(
              left: 0, top: ingredientsListZoneHeight+cuttingBoardZoneHeight+10,
              child: Container(
                width: size.width,
                height: size.height - ingredientsListZoneHeight+cuttingBoardZoneHeight-10,
                child: ListView(
                  children: [
                    Wrap(
                      spacing: 3,
                      children: cutsWL(),
                    ),
                  ] ,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _go,
        child: AvatarGlow(
          endRadius: 50,
          glowColor: Colors.red,
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

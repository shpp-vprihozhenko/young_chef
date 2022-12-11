import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'cutting.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
/*

проговаривать название на клик.

основа: кусочек хлеба, откр. булочка, кастрюля вид сверху
полить кетчупом/майонезом если есть...

готовка

увеличть/уменьшить ингредиент
повернуть
нарезать = нов. ингр.
порядок (выше/ниже)
отрезать кусочек

готово!

- отправить маме/папе/бабушке.
(форм картинку, => share_plus)

+ озвучка при клике по ингр.

 */

class MakeHamburger extends StatefulWidget {
  Product product;

  MakeHamburger({Key? key, required this.product}) : super(key: key);

  @override
  State<MakeHamburger> createState() => _MakeHamburgerState();
}

class _MakeHamburgerState extends State<MakeHamburger> {
  Size virtualFieldSize = const Size(1777, 1000);
  int numIngredients = 250;
  List <IngredientOnMap> ingredientsOnMap = [];
  List <IngredientOnMap> ingredientsInCart = [];
  Offset mapOffset = const Offset(0, 0);
  Product productToMake = Product('');
  IngredientOnMap? draggingIngredient;
  bool firstLoop = false;
  Widget? lastW;
  int lastWidx = -1;
  Size screenSize = Size(0,0), workingScreenSize = Size(0,0);
  final aPlayer = AudioPlayer();
  final putPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    productToMake = widget.product;
    print('productToMake $productToMake');
    _initIngredientsForMap();
    _prepareSounds();
  }

  @override
  void dispose() {
    aPlayer.dispose();
    putPlayer.dispose();
    super.dispose();
  }

  _prepareSounds() async {
    await putPlayer.setVolume(1);
    await putPlayer.setAsset('assets/mp3/put.mp3');
    await putPlayer.setLoopMode(LoopMode.off);

    await aPlayer.setVolume(0.05);
    await aPlayer.setAsset('assets/mp3/npStrojka.mp3');
    await aPlayer.setLoopMode(LoopMode.all);
    aPlayer.play();

  }

  _initIngredientsForMap(){
    var rng = Random();
    for (int i=0; i<numIngredients; i++) {
      int ingredientIdx = rng.nextInt(ingredients.length);
      IngredientOnMap ingOnMap = IngredientOnMap(ingredients[ingredientIdx],
          Offset(rng.nextDouble()*(virtualFieldSize.width-glIngredientSizeOnMap),
              rng.nextDouble()*virtualFieldSize.height-glIngredientSizeOnMap
          )
      );
      ingredientsOnMap.add(ingOnMap);
    }
  }

  List <Widget> visibleIngredients(Size size) {
    List <Widget> vi = [];
    for (int idx=0; idx<ingredientsOnMap.length; idx++) {
      if (idx == lastWidx) {
        continue;
      }
      IngredientOnMap ingredientOnMap = ingredientsOnMap[idx];
      if (!ingredientOnMap.isEnabled) {
        continue;
      }
      if (ingredientOnMap.position > mapOffset-Offset(glIngredientSizeOnMap, glIngredientSizeOnMap)
          && ingredientOnMap.position < mapOffset+Offset(size.width, size.height)) {
        if (ingredientOnMap.widget == null) {
          Widget iw = ClipOval(
            child: Container(
              width: glIngredientSizeOnMap, height: glIngredientSizeOnMap,
              padding: EdgeInsets.all(8),
              //color: Colors.yellow,
              child: Center(
                child: ingredientOnMap.ingredient.img == ''?
                Text(ingredientOnMap.ingredient.name,
                  style: TextStyle(color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                )
                    :
                Image.asset('assets/images/${ingredientOnMap.ingredient.img}', )
                ,
              ),
            ),
          );
          Widget giv = GestureDetector(
            child: iw,
            onTap: (){
              print(ingredientOnMap);
              showIngredient(context, ingredientOnMap.ingredient);
            },
            onDoubleTap: (){
              if (ingredientOnMap.isEnabled) {
                if (ingredientsInCart.length < 15) {
                  _addToCartIngredient(ingredientOnMap);
                } else {
                  showAlertPage(context, 'Корзина переполнена!');
                }
              } else {
                int idx = ingredientsInCart.indexWhere((element) => element.hashCode == ingredientOnMap.hashCode);
                if (idx == -1) {
                  showAlertPage(context, 'err. no idx in cart');
                } else {
                  ingredientsInCart.removeAt(idx);
                  ingredientOnMap.isEnabled = true;
                  //ingredientOnMap.position += Offset(0, 100);
                  setState(() {});
                }
              }
            },
            onPanStart: (DragStartDetails details){
              printD('onPanStart');
              ingredientOnMap.isDragging = true;
              setState(() {});
              lastWidx = idx;
              printD('lastWidx 1 = $lastWidx');
            },
            onPanUpdate: (DragUpdateDetails details){
              printD('onPanUpdate1 for idx $idx');
              ingredientsOnMap[lastWidx].position += details.delta;
              setState(() {});
            },
            onPanEnd: (DragEndDetails details){
              printD('onPanEnd1 idx $idx lastWidx $lastWidx');
              IngredientOnMap ingredientOnMap = ingredientsOnMap[lastWidx];
              printD('pos ${ingredientOnMap.position} of $ingredientOnMap '
                  'idx $lastWidx}');
              printD('glCartSize.height ${glCartSize.height}');
              if (ingredientOnMap.position.dy < mapOffset.dy + glCartSize.height) {
                printD('1');
                if (ingredientOnMap.position.dx > mapOffset.dx+glCartX1 && ingredientOnMap.position.dx < mapOffset.dx+glCartX2) {
                  if (ingredientsInCart.length < 15) {
                    if (ingredientOnMap.isEnabled) {
                      _addToCartIngredient(ingredientOnMap);
                    }
                  } else {
                    showAlertPage(context, 'Корзина переполнена!');
                  }
                }
              } else {
                if (!ingredientOnMap.isEnabled) {
                  printD('remove from cart');
                  int idx = ingredientsInCart.indexWhere((element) => element.hashCode == ingredientOnMap.hashCode);
                  if (idx == -1) {
                    showAlertPage(context, 'err. no idx in cart');
                  } else {
                    printD('DragEndDetails $details');
                    ingredientsInCart.removeAt(idx);
                    ingredientOnMap.isEnabled = true;
                    //ingredientOnMap.position += Offset(0, 100);
                    setState(() {});
                  }
                }
              }
              lastWidx = -1;
              setState(() {});
            },
          );
          ingredientOnMap.widget = giv;
        }
        Widget piw = Positioned(
            left: (ingredientOnMap.position - mapOffset).dx,
            top: (ingredientOnMap.position - mapOffset).dy,
            child: ingredientOnMap.widget!
        );
        vi.add(piw);
      }
    }
    return vi;
  }

  _addToCartIngredient(IngredientOnMap ingredientOnMap){
    printD('_addToCartIngredient with $ingredientOnMap');
    ingredientOnMap.isEnabled = false;
    ingredientsInCart.add(ingredientOnMap);
    int stage = (ingredientsInCart.length / 5).ceil()-1;
    int posInStage = ingredientsInCart.length - stage*5 - 1;
    double x = posInStage * ingredientInCartWidth + glCartX1;
    double y = stage * ingredientInCartWidth;
    printD('stage $stage posInStage $posInStage x ${x.floor()} y $y glCartX1 ${glCartX1.floor()}');
    ingredientOnMap.position = Offset(x, y);
    printD('added to cart $lastWidx $ingredientOnMap hash ${ingredientOnMap.hashCode}');
    printD('ingredientsInCart $ingredientsInCart');
    setState(() {});
    putPlayer.seek(Duration.zero);
    putPlayer.play();
    printD('play put sound');
  }

  Widget draggingIngredientW(){
    if (lastWidx > -1) {
      print('add ing for lastWidx $lastWidx');
      IngredientOnMap ingredientOnMap = ingredientsOnMap[lastWidx];
      Widget piw = Positioned(
          left: (ingredientOnMap.position - mapOffset).dx,
          top: (ingredientOnMap.position - mapOffset).dy,
          child: ingredientOnMap.widget!
      );
      return piw;
    }
    return Positioned(
      top: 0, left: 0,
      child: SizedBox(width: 0, height: 0,)
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx == 0 && details.delta.dy == 0) {
      return;
    }
    Offset lastMOS = mapOffset;
    mapOffset -= details.delta;
    print('_onPanUpdate mapOffset $mapOffset');
    if (mapOffset.dx < -50 || mapOffset.dx > virtualFieldSize.width-workingScreenSize.width+50) {
      mapOffset = lastMOS;
      return;
    }
    if (mapOffset.dy < -50 ||mapOffset.dy >  virtualFieldSize.height-workingScreenSize.height+50) {
      mapOffset = lastMOS;
      return;
    }
    //printD('mapOffset $mapOffset');
    setState((){});// 414.0, 660.0
  }

  List <Widget> ingredientsOfCartWL(){
    //printD('ingredientsInCart ${ingredientsInCart.length}');
    List <Widget> wl = [];
    ingredientsInCart.forEach((ingredient) {
      wl.add(SizedBox(
        width: 50, height: 50,
          child: ingredient.widget!)
      );
    });
    return wl;
  }

  _go() async {
    glCartIngredients = [];
    ingredientsInCart.forEach((element) {
      glCartIngredients.add(element.ingredient);
    });
    glProductToMake = productToMake;
    await aPlayer.pause();
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const Cutting())
    );
    await aPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarW = AppBar(
      title: Row(
        children: [
          Expanded(child: Text('Найди ингредиенты', overflow: TextOverflow.clip,)),
          IconButton(
            onPressed: (){
              glShowRequiredIngredients(context, productToMake);
            }, icon: Icon(Icons.help, size: 32, color: Colors.yellow,),
          ),
        ],
      ),
    );
    screenSize = MediaQuery.of(context).size;
    Size size = Size(screenSize.width, screenSize.height - appBarW.preferredSize.height - MediaQuery.of(context).padding.top);
    workingScreenSize = size;
    double cartWidth = glCartSize.width; //size.width*0.7;
    double cartLeft = size.width/2-cartWidth/2;
    glCartX1 = cartLeft; glCartX2 = screenSize.width - cartLeft;
    return Scaffold(
      appBar: appBarW,
      body: Stack(
        children: [
          Positioned(
            top: -mapOffset.dy, left: -mapOffset.dx,
            child: Image.asset('assets/images/Кухня3.jpeg',
              width: virtualFieldSize.width, height: virtualFieldSize.height,
              fit: BoxFit.cover,
            )
          ),
          Positioned(
            top: 0, left: 0,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Container(
                color: Colors.white.withOpacity(0.01),
                width: size.width,
                height: size.height,
              ),
            ),
          ),
          ...visibleIngredients(size),
          Positioned(
            top: 0, left: cartLeft,
            child: Container(
                width: cartWidth, height: glCartSize.height,
                color: Colors.lightBlueAccent[100],
                child: Wrap(
                  children: [
                    ...ingredientsOfCartWL()
                  ],
                ),
            ),
          ),
          draggingIngredientW(),
        ],
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


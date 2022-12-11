import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();

List <String> glMyImages = [];

String nodeEndPoint = 'http://173.212.250.234:6641';
Size glScreenSize = Size(0,0);
Size glCartSize = Size(250, 150);
double glCartX1 = 0,  glCartX2 = 0;
double ingredientInCartWidth = 50, glIngredientSizeOnMap = 90;
List <Ingredient> glCartIngredients = [];
List <Ingredient> glFinalIngredients = [];
Product glProductToMake = Product('');
Size knifeSize = Size(163,150);
final double cutSize = 90;
const kpi = 3.1415926/180;
double topMargin = 0, glTopReservedHeight = 160;
Size glWorkTableSize = Size(0,0);
Uint8List? glPngBytes;

glInitTTS() async {
  await flutterTts.setSharedInstance(true);
  await flutterTts.awaitSpeakCompletion(true);
  await flutterTts.setLanguage("ru-RU");
  await flutterTts.setSpeechRate(0.7);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
}

Future glSpeak(String text) async{
  await flutterTts.speak(text);
}

printD(text){
  if (kDebugMode) {
    print(text);
  }
}

Future <void> showAlertPage(context, String msg) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(msg),
        );
      }
  );
}

Future <void> showResultPage(context, String msg1, String msg2, bool isWin) async {
  Size size = MediaQuery.of(context).size;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: size.width*0.75, height: 200,
            color: Colors.green.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg1,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      color: isWin? Colors.purple:Colors.red),
                  ),
                  const SizedBox(height: 12,),
                  msg2==''? const SizedBox() : Text(msg2, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center,),
                  const SizedBox(height: 12,),
                  ElevatedButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: const Text('OK'))
                ],
              )
            )
          ),
        );
      }
  );
}

glSaveToMyImages(String fileName) async {
  glMyImages.add(fileName);
  String mis = jsonEncode(glMyImages);
  printD('mis $mis');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('glMyImages', mis);
}

Future <String> glRestoreMyImages() async {
  glMyImages = [];
  final prefs = await SharedPreferences.getInstance();
  final String? mis = prefs.getString('glMyImages');
  if (mis == null) {
    return 'no mis';
  }
  printD('glRestoreMyImages mis $mis');
  try {
    var mil = jsonDecode(mis);
    mil.forEach((mi){
      File f = File(mi);
      if (!f.existsSync()) {
        return;
      }
      glMyImages.add(mi);
    });
  } catch(e) {
    printD('err on restore $e');
  }
  printD('restored glMyImages $glMyImages');
  return 'ok';
}

class Ingredient {
  String name = '', img = '';
  int state = 0;
  String cutPieceName = '';
  int cutQuantity = 1;

  Ingredient(this.name, this.img, [this.cutPieceName='', this.cutQuantity=5]);

  @override
  String toString() {
    return 'Product $name ingredientsForProduct $img';
  }
}

List <Ingredient> cut_ingredients = [
  Ingredient('Кусочек колбасы', 'кус_колб.png'),
  Ingredient('Кусочек помидора', 'pomidor_kol.png'),
  Ingredient('Кусочек буряка', 'кольцо буряка.png'),
  Ingredient('Кусочек морковки', 'кусок морковки.png'),
  Ingredient('Капустный лист', 'лист капусты.png'),
  Ingredient('Кусочек сосиски', 'кус сос.png'),
  Ingredient('Кусочек сыра', 'кус сыра.png'),
  Ingredient('Кусочки картошки', 'кус карт.png'),
  Ingredient('Кусочек коржа для пиццы', 'кус корж пиццы.webp'),
  Ingredient('Колечко лука', 'кольцо лука.webp'),
  Ingredient('Зубок чеснока', 'зуб чеснока.webp'),
  Ingredient('Кусочек масла', 'кус масла.webp'),
  Ingredient('Кусочек яблока', 'кусочек яблока2.webp'),
  Ingredient('Кусочки груши', 'кус груши.webp'),
  Ingredient('Виноградина', 'виноградина.webp'),
  Ingredient('Долька апельсина', 'Долька апельсина.webp'),
  Ingredient('Кусочек банана', 'кусочек банана.webp'),
  Ingredient('Кусочек гриба', 'кус_гриба1.webp'),
  Ingredient('Кусочек курицы', 'кус_кур.webp'),
  Ingredient('Колечко ананаса', 'колечко ананаса.webp'),
  Ingredient('Кусочек скумбрии', 'кусочек скумбрии.webp'),
  Ingredient('Ягода малины', 'малина2.webp'),
  Ingredient('Долька лимона', 'долька лимона.webp'),
  Ingredient('Кусочек хлеба', 'кусочек хлеба.webp'),
  Ingredient('Кусочек сала', 'Кусочек сала.webp'),
];

List <Ingredient> ingredients = [
  Ingredient('Сало', 'Сало.webp', 'Кусочек сала', 4),
  Ingredient('Хлеб', 'хлеб.webp', 'Кусочек хлеба', 4),
  Ingredient('Лимон', 'лимон.webp', 'Долька лимона', 4),
  Ingredient('Малина', 'малина.webp', 'Ягода малины', 8),
  Ingredient('Скумбрия', 'скумбрия.webp', 'Кусочек скумбрии', 4),
  Ingredient('Ананас', 'ананас.webp', 'Колечко ананаса', 4),
  Ingredient('Гриб',   'гриб1.webp', 'Кусочек гриба', 3),
  Ingredient('Курица',   'курица.webp', 'Кусочек курицы', 5),
  Ingredient('Капуста',   'kapusta.png', 'Капустный лист', 4),
  Ingredient('Морковка',  'morkovka.png', 'Кусочек морковки', 4),
  Ingredient('Буряк',     'burak.png', 'Кусочек буряка', 3),
  Ingredient('Сосиска',   'sosiska.png', 'Кусочек сосиски', 3),
  Ingredient('Колбаса',   'колб2.png', 'Кусочек колбасы', 4),
  Ingredient('Сыр',       'syr.webp', 'Кусочек сыра', 3),
  Ingredient('Картошка',  'kartoshka.webp', 'Кусочки картошки', 3),
  Ingredient('Корж', 'корж пиццы.webp', 'Кусочек коржа для пиццы', 4),
  Ingredient('Кастрюля',  'кастрюля.webp'),
  Ingredient('Ложка',     'Ложка.webp'),
  Ingredient('Булочка для хотдога',     'Булочка для хотдога.webp'),
  Ingredient('Лук',       'Лук.png', 'Колечко лука', 3),
  Ingredient('Чеснок',    'Чеснок.webp', 'Зубок чеснока', 4),
  Ingredient('Помидор',   'помидор1.png', 'Кусочек помидора', 3),
  Ingredient('Соль',      'Соль.png'),
  Ingredient('Сахар',     'Сахар.png'),
  Ingredient('Майонез',   'Майонез.webp'),
  Ingredient('Кетчуп',    'Кетчуп4.webp'),
  Ingredient('Вода',      'Вода.webp'),
  Ingredient('Масло',     'масло.webp', 'Кусочек масла', 4),
  Ingredient('Яблоко',    'Яблоко.webp', 'Кусочек яблока', 4),
  Ingredient('Груша',     'Груша.webp', 'Кусочки груши', 3),
  Ingredient('Виноград',  'Виноград.webp', 'Виноградина', 10),
  Ingredient('Апельсин',  'Апельсин.webp', 'Долька апельсина', 5),
  Ingredient('Банан',     'Банан.webp', 'Кусочек банана', 5),
  Ingredient('Мука',      'Мука.webp'),
  Ingredient('Мяч',       'Мяч.png'),
  Ingredient('Собачка',   'Собачка.png'),
  Ingredient('Кубик',     'Кубик.png'),
  Ingredient('Кукла',     'Кукла.webp'),
  Ingredient('Сумка',     'Сумка.png'),
  Ingredient('Кошелёк',   'Кошелёк.webp'),
  Ingredient('Бананка',   'Бананка.png'),
  Ingredient('Грузовик',  'Грузовик.webp'),
  Ingredient('Машинка',   'Машинка.webp'),
  Ingredient('Фен',       'Фен.webp'),
  Ingredient('Помада',    'Помада.png'),
  Ingredient('Чайник',    'Чайник.gif'),
];

class IngredientOnMap {
  int layerNumber = 0;
  Ingredient ingredient;
  Offset position = const Offset(0, 0);
  Size size = Size(80, 80);
  bool isDragging = false, isEnabled = true;
  Widget? widget;
  int state = 0, idx = -1, cutQuantity = 0;
  double angle = 0;

  IngredientOnMap(this.ingredient, this.position, {this.cutQuantity=0});

  @override
  String toString() {
    return 'Ingredient ${ingredient.name} at $position size $size state $state';
  }
}

class IngredientsForProduct {
  Ingredient ingredient;
  int quantity;

  IngredientsForProduct(this.ingredient, this.quantity);

  @override
  String toString() {
    return 'IngredientForProduct $ingredient quantity $quantity';
  }
}

class Product {
  String name = '';
  List <IngredientsForProduct> ingredientsForProduct = [];
  String img = '';

  Product(this.name);

  @override
  String toString() {
    return 'Product $name ingredientsForProduct $ingredientsForProduct img $img';
  }
}

List <Product> products = [];

Ingredient glGetIngredientByName(name) {
  return ingredients.firstWhere((element) => element.name == name);
}

glShowRequiredIngredients(context, Product product) async {
  Size size = MediaQuery.of(context).size;
  double width = size.width*0.8;
  double height = size.height*0.7;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: width, height: height,
            child: Column(
              children: [
                Text('На ${product.name}', textScaleFactor: 1.5,),
                SizedBox(height: 8,),
                Text('тебе понадобятся:', textScaleFactor: 1.5,),
                SizedBox(height: 16,),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: ListView.builder(
                        itemCount: product.ingredientsForProduct.length,
                        itemBuilder: (context, idx){
                          IngredientsForProduct ifp = product.ingredientsForProduct[idx];
                          List <Widget> il = [];
                          for (int j=0; j<ifp.quantity; j++) {
                            il.add(Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/'+ifp.ingredient.img, height: 60, width: 60,),
                            ));
                          }
                          return Container(
                            color: idx%2==0? Colors.grey[200]:Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ClipOval(
                                    child: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      color: Colors.lightBlueAccent[100],
                                      child: Text(ifp.ingredient.name, textScaleFactor: 1.5,),
                                    ),
                                  ),
                                  SizedBox(width: 30,),
                                  ...il
                                ],
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('OK')
                ),
              ],
            ),
          ),
        );
      }
  );
}

void showIngredient(context, Ingredient ingredient) {
  glSpeak(ingredient.name);
  if (ingredient.img == '') {
    return;
  }
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ingredient.name, textScaleFactor: 2, textAlign: TextAlign.center,),
              SizedBox(height: 15,),
              Image.asset('assets/images/${ingredient.img}'),
            ],
          ),
        );
      }
  );
}

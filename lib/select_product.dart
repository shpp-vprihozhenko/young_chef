import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_extend/share_extend.dart';
import 'globals.dart';
import 'make_gamburger.dart';

class SelectProduct extends StatefulWidget {
  const SelectProduct({Key? key}) : super(key: key);

  @override
  State<SelectProduct> createState() => _SelectProductState();
}

class _SelectProductState extends State<SelectProduct> {

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initProducts();
    super.initState();
    glRestoreMyImages().then((ok){
      setState(() {});
    });
  }

  _initProducts(){
    products = [];

    Product p = Product('Пицца с колбасой');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Колбаса'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Помидор'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сыр'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кетчуп'), 1));
    products.add(p);

    p = Product('Пицца с курицей');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Курица'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Помидор'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сыр'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кетчуп'), 1));
    products.add(p);

    p = Product('Пицца с курицей и ананасом');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Курица'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Ананас'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сыр'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кетчуп'), 1));
    products.add(p);

    p = Product('Пицца с курицей и грибами');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Курица'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Гриб'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сыр'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кетчуп'), 1));
    products.add(p);

    p = Product('Пицца с рыбой и лимоном');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Скумбрия'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Лимон'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Гриб'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сыр'), 1));
    products.add(p);

    p = Product('Хотдог');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Булочка для хотдога'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сосиска'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кетчуп'), 1));
    products.add(p);

    p = Product('Яблочный пирог');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Яблоко'), 4));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сахар'), 1));
    products.add(p);

    p = Product('Пирог с грушами');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Груша'), 3));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сахар'), 1));
    products.add(p);

    p = Product('Пирог с малиной');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Малина'), 3));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сахар'), 1));
    products.add(p);

    p = Product('Пирог с капустой и грибами');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Корж'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Капуста'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Гриб'), 3));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Соль'), 3));
    products.add(p);

    p = Product('Бутерброд с колбасой и горчицей');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Хлеб'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Колбаса'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Масло'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Соль'), 1));
    products.add(p);

    p = Product('Бутерброд с салом');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Хлеб'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сало'), 1));
    products.add(p);

  }

  List <Widget> productsWL(){
    List <Widget> lw = [];
    for (int idx=0; idx<products.length; idx++) {
      lw.add(GestureDetector(
        onTap: () async {
          print('products[idx] ${products[idx].name}');
          await glShowRequiredIngredients(context, products[idx]);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MakeHamburger(product: products[idx],))
          );
        },
        child: Container(
          color: idx%2==1? Colors.grey[200] : Colors.white,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(products[idx].name, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              IconButton(
                  onPressed: (){
                    glSpeak(products[idx].name);
                  },
                  icon: Icon(Icons.volume_down)
              )
            ],
          ),
        ),
      ));
    }
    return lw;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    PreferredSizeWidget appBarW = AppBar(title: Text('Юный повар'),);
    glScreenSize = Size(size.width, size.height - appBarW.preferredSize.height - MediaQuery.of(context).padding.top);
    printD('glScreenSize $glScreenSize');
    return Scaffold(
      appBar: appBarW,
      body: ListView(
        children: [
          SizedBox(height: 12,),
          Text('Привет.', textScaleFactor: 1.6, textAlign: TextAlign.center,),
          SizedBox(height: 12,),
          Image.asset('assets/images/yang cock.png', width: 250, height: 250,),
          SizedBox(height: 12,),
          Container(
            color: Colors.purple[100],
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Text('Выбери, что мы будем готовить.', textScaleFactor: 1.5, textAlign: TextAlign.center,)),
              ],
            ),
          ),
          SizedBox(height: 12,),
          ...productsWL(),
        ],
      ),
      bottomNavigationBar:
      glMyImages.length == 0?
      null
        :
      Container(
        height: 120, width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: glMyImages.length,
            itemBuilder: (context, idx) {
              String fName = glMyImages[glMyImages.length-idx-1];
              printD('fName $fName');
              File f = File(fName);
              if (f.existsSync()) {
                printD('exist $f');
              } else {
                printD('not exist $f');
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Image.file(f, fit: BoxFit.contain,),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Container(
                            width: glScreenSize.width*0.8,
                            height: glScreenSize.height*0.8,
                            child: Column(
                              children: [
                                Expanded(child: Image.file(f, fit: BoxFit.contain,)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                        onPressed: (){
                                          ShareExtend.shareMultiple([f.path], "image", subject: "Приятного аппетита!");
                                        },
                                        child: Icon(Icons.share)
                                    ),
                                    ElevatedButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK')
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  },
                ),
              );
            }
          )
      ),
    );
  }
}

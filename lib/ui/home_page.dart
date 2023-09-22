import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:limonada/constants.dart' as constants;
import 'package:limonada/ui/screens/settings_screen.dart';
import 'package:limonada/services/sql_helper.dart';
import 'package:limonada/ui/screens/upgrade_screen.dart';

class HomePageState extends StatefulWidget {
  const HomePageState({Key? key}) : super(key: key);

  @override
  State<HomePageState> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePageState> {
  late double _money = 0.0;
  late int _lemon = 0;
  late double _lemonPrice = 0.0;
  late int _sugar = 0;
  late double _sugarPrice = 0.0; //TODO
  late double _price = _minSliderValue;
  late double _clickValue = 0.0;

  late int _quantity = 0;
  late int _water = 0; //TODO

  double toolbarHeight = 45; // default is 56
  double toolbarSpace = 25;
  double toolbarSizeIcon = 25;
  double toolbarSizeText = 20;

  final double _minSliderValue = 0.25;
  final double _maxSliderValue = 5;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    List<Map> items = await SQLHelper.getItems();
    List<Map> carts = await SQLHelper.getCarts();
    setState(() {
      _money = items.first['money'];
      _lemon = items.first['lemon'];
      _lemonPrice = items.first['lemonPrice'];
      _sugar = items.first['sugar'];
      _sugarPrice = items.first['sugarPrice'];
      _price = items.first['price'];
      _clickValue = items.first['clickValue'];
      _quantity = carts.isNotEmpty ? carts.first['quantity'] : 0;
      _water = carts.isNotEmpty ? carts.first['quantity'] : 100;
    });
  }

  Future<void> _newGame() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.newGame),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.newGameBody),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.pop(context, 'Cancel'),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.acept),
              onPressed: () async {
                await SQLHelper.deleteItem();
                _refreshData();
                Navigator.pop(context, 'Ok');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _newMessage(String title, String body) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.acept),
              onPressed: () => Navigator.pop(context, 'Ok'),
            ),
          ],
        );
      },
    );
  }

  void _setMoney() async {
    _money = _money + _clickValue;
    //double money = _money + _lemon*_price; //TODO
    await SQLHelper.updateItem(money: _money);
    _refreshData();
  }

  void _setLemons(int order) async {
    //int order = _money ~/ _lemonPrice;
    _money = _money - (order * _lemonPrice);
    _lemon = _lemon + order;

    await SQLHelper.updateItem(lemon: _lemon, money: _money);
    _refreshData();
  }

  void _setLemonade(
      int quantity, double lemon, double sugar, double water) async {
    int tempLemon = _lemon - lemon.toInt();
    int tempSugar = _sugar - sugar.toInt();
    await SQLHelper.updateItem(lemon: tempLemon, sugar: tempSugar);
    await SQLHelper.updateCart(
        lemon: lemon.toInt(),
        sugar: sugar.toInt(),
        water: water.toInt(),
        price: _price,
        quantity: quantity);
    _refreshData();
  }

  void _getMoney() {
    showModalBottomSheet(
        backgroundColor: constants.COLOR_BACKGROUND,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 1,
              child: Container(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(constants.ICON_MONEY,
                                size: toolbarSizeIcon, color: Colors.white70),
                            const SizedBox(width: 2),
                            Text(_money.toStringAsFixed(2),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: toolbarSizeText,
                                    fontWeight: FontWeight.w500))
                          ]),
                      const SizedBox(
                        height: 30,
                      ),
                      const Center(
                          child: Text('Consigue más dinero con mejoras',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 17))),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                          child: Text('( Multiplicador actual: +$_clickValue )',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 17))),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: 100.0,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _setMoney();
                                  });
                                },
                                icon: const Icon(
                                  constants.ICON_MONEY,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label: Text(
                                    '${AppLocalizations.of(context)!.get} ${AppLocalizations.of(context)!.money.toLowerCase()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    )),
                              )),
                            ],
                          )),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          //color: constants.COLOR_SECONDARY,
                          height: 150.0,
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              primary: constants.COLOR_SECONDARY,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 24.0,
                              //color: constants.COLOR_PRIMARY,
                            ),
                            label: Text(
                                AppLocalizations.of(context)!
                                    .back
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 16)),
                          )),
                    ],
                  )),
            );
          });
        });
  }

  void _getUpgrade() {
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const UpgradeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _buyLemons() {
    double tempLemons = 0;
    double tempMax = (_money ~/ _lemonPrice).toDouble();
    int tempDivisions = 1;
    if (tempMax >= 2) {
      tempDivisions = (tempMax).round();
    }

    showModalBottomSheet(
        backgroundColor: constants.COLOR_BACKGROUND,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 1,
              child: Container(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(constants.ICON_LEMON,
                                size: toolbarSizeIcon, color: Colors.white70),
                            const SizedBox(width: 10),
                            Text(_lemon.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: toolbarSizeText,
                                    fontWeight: FontWeight.w500))
                          ]),
                      const SizedBox(
                        height: 30,
                      ),
                      const Center(
                          child: Text('( Limones disponibles en tu almacén )',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 17))),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                          child: Text(
                              'Dinero disponible: ${_money.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 17))),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                          child: Text(
                              'Precio actual del limón: ${_lemonPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 17))),
                      const SizedBox(
                        height: 20,
                      ),
                      Slider(
                        value: tempLemons,
                        min: 0,
                        max: tempMax,
                        divisions: tempDivisions,
                        label: tempLemons.toStringAsFixed(0),
                        onChanged: (double value) {
                          setState(() {
                            tempLemons = value;
                          });
                        },
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: 100.0,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _setLemons(tempLemons.toInt());
                                    //reset slider values
                                    tempLemons = 0;
                                    tempMax =
                                        (_money ~/ _lemonPrice).toDouble();
                                    tempDivisions = 1;
                                    if (tempMax >= 2) {
                                      tempDivisions = (tempMax).round();
                                    }
                                  });
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                  constants.ICON_LEMON,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label: Text(
                                    '${AppLocalizations.of(context)!.buy} ${tempLemons.toStringAsFixed(0)} ${AppLocalizations.of(context)!.lemons.toLowerCase()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    )),
                              )),
                            ],
                          )),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: 50.0,
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: constants.COLOR_BACKGROUND.withOpacity(0.25),
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 24.0,
                              //color: constants.COLOR_PRIMARY,
                            ),
                            label: Text(
                                AppLocalizations.of(context)!
                                    .back
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 16)),
                          )),
                    ],
                  )),
            );
          });
        });
  }

  void _buySugar() {
    //print("comprar azucar"); //TODO
  }

  void _makeLimonade() {
    bool isButtonDisabled = false;

    double tempLemons = 0;
    double tempLemonsMax = _lemon.toDouble();
    int tempLemonsDivisions = 1;
    if (tempLemonsMax >= 2) {
      tempLemonsDivisions = (tempLemonsMax).round();
    }

    double tempSugar = 0;
    double tempSugarMax = _sugar.toDouble();
    int tempSugarDivisions = 1;
    if (tempSugarMax >= 2) {
      tempSugarDivisions = (tempSugarMax).round();
    }

    double tempWater = 100;

    if (_quantity > 0) {
      _newMessage('Aviso', 'Ya hay pedidos realizados, ve a vender limonada!');
    } else {
      showModalBottomSheet(
          backgroundColor: constants.COLOR_BACKGROUND,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return FractionallySizedBox(
                heightFactor: 1,
                child: Container(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(constants.ICON_LEMON,
                                  size: toolbarSizeIcon, color: Colors.white70),
                              const SizedBox(width: 10),
                              Text(_lemon.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: toolbarSizeText,
                                      fontWeight: FontWeight.w500))
                            ]),
                        const SizedBox(
                          height: 30,
                        ),
                        Center(
                            child: Text(
                                'Limones a usar: ${tempLemons.toInt()} / 100',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 17))),
                        Slider(
                          value: tempLemons,
                          min: 0,
                          max: tempLemonsMax,
                          divisions: tempLemonsDivisions,
                          label: tempLemons.toStringAsFixed(0),
                          onChanged: (double value) {
                            setState(() {
                              tempLemons = value;
                            });
                          },
                        ),
                        Center(
                            child: Text('Azucar a usar: ${tempSugar.toInt()}',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 17))),
                        Slider(
                          value: tempSugar,
                          min: 0,
                          max: tempSugarMax,
                          divisions: tempSugarDivisions,
                          label: tempLemons.toStringAsFixed(0),
                          onChanged: (double value) {
                            setState(() {
                              tempSugar = value;
                            });
                          },
                        ),
                        Center(
                            child: Text('Agua a usar: ${tempWater.toInt()} %',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 17))),
                        Slider(
                          value: tempWater,
                          min: 50,
                          max: 150,
                          divisions: 10,
                          label: tempWater.toStringAsFixed(0),
                          onChanged: (double value) {
                            setState(() {
                              tempWater = value;
                            });
                          },
                        ),
                        Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            height: 100.0,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  onPressed: () {
                                    int amount = _getAmount(
                                        tempLemons, tempSugar, tempWater);
                                    if (isButtonDisabled) {
                                      null;
                                    } else if (amount > 0) {
                                      setState(() {
                                        isButtonDisabled = true;
                                        _setLemonade(amount, tempLemons,
                                            tempSugar, tempWater);
                                        Navigator.of(context).pop();
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    constants.ICON_LIMONADE,
                                    size: 24.0,
                                    color: constants.COLOR_PRIMARY,
                                  ),
                                  label: Text(
                                      '${AppLocalizations.of(context)!.make} ${_getAmount(tempLemons, tempSugar, tempWater).toString()}', //${AppLocalizations.of(context)!.lemonade.toLowerCase()}

                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      )),
                                )),
                              ],
                            )),
                        Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            height: 50.0,
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: constants.COLOR_BACKGROUND
                                    .withOpacity(0.25),
                                minimumSize: const Size.fromHeight(50),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 24.0,
                              ),
                              label: Text(
                                  AppLocalizations.of(context)!
                                      .back
                                      .toUpperCase(),
                                  style: const TextStyle(fontSize: 16)),
                            )),
                      ],
                    )),
              );
            });
          });
    }
  }

  int _getAmount(double tempLemons, double tempSugar, double tempWater) {
    double amount = constants.AMOUNT * tempLemons * tempWater / 100;
    return amount.toInt();
  }

  void _buyIce() {
    //print("comprar hielo"); //TODO
  }

  void _buyWater() {
    //print("comprar agua"); //TODO
  }

  void _sellLimonade() {
    if (_quantity > 0) {
      int quantitySold = _quantitySold();
      showModalBottomSheet(
          backgroundColor: constants.COLOR_BACKGROUND,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return FractionallySizedBox(
                heightFactor: 1,
                child: Container(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Resumen de ventas',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: toolbarSizeText,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(constants.ICON_LIMONADE,
                                  size: toolbarSizeIcon, color: Colors.white70),
                              const SizedBox(width: 10),
                              Text(
                                  '$quantitySold / ${_quantity.toString()}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: toolbarSizeText,
                                      fontWeight: FontWeight.w500))
                            ]),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            height: 100.0,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    size: 24.0,
                                  ),
                                  label: Text(
                                      AppLocalizations.of(context)!
                                          .acept
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      )),
                                )),
                              ],
                            )),
                      ],
                    )),
              );
            });
          });
      //update
      _setCart(quantitySold);
    } else {
      _newMessage('Aviso', 'Necesitas hacer limonada antes de ir a venderla!');
    }
  }

  void _setCart(int quantitySold) async {
    double money = (quantitySold * _price) + _money;

    await SQLHelper.updateItem(money: money);
    await SQLHelper.updateCart(
        lemon: 0, sugar: 0, water: 100, price: _price, quantity: 0);
    _refreshData();
  }

  int _quantitySold() {
    //TODO agua, azucar y precio de venta
    double variables = 10; //TODO
    double random = (variables + (Random().nextDouble() * 50)) /
        100; //variable + random de 50
    double ajustePrecioVenta = 1; // 1 / _price; //TODO
    double ajusteCantidadAgua = 1; // 100 / _water; //TODO

    int vendido =
        (_quantity * random * ajustePrecioVenta * ajusteCantidadAgua).toInt();

    return vendido;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constants.COLOR_BACKGROUND,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(toolbarHeight),
          child: AppBar(
            centerTitle: true,
            title: SizedBox(
                height: toolbarHeight,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //money
                    Row(children: [
                      Icon(constants.ICON_MONEY, size: toolbarSizeIcon),
                      const SizedBox(width: 5),
                      Text(_money.toStringAsFixed(2),
                          style: TextStyle(fontSize: toolbarSizeText))
                    ]),
                  ],
                ))),
            actions: <Widget>[
              PopupMenuButton(
                  enabled: true,
                  onSelected: (value) {
                    switch (value) {
                      case 'more':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                        break;
                      case 'newGame':
                        _newGame();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "more",
                          child: Text(AppLocalizations.of(context)!.more),
                        ),
                        PopupMenuItem(
                          value: "newGame",
                          child: Text(AppLocalizations.of(context)!.newGame),
                        ),
                      ])
            ],
          )),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //Header Container
            Container(
                padding: const EdgeInsets.all(6),
                color: constants.COLOR_APPBAR,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //lemon
                    InkWell(
                        onTap: () {
                          _buyLemons;
                        },
                        child: Row(children: [
                          Icon(constants.ICON_LEMON,
                              size: toolbarSizeIcon,
                              color: constants.COLOR_PRIMARY),
                          const SizedBox(width: 5),
                          Text(_lemon.toString(),
                              style: const TextStyle(
                                  fontSize: 18, color: constants.COLOR_PRIMARY))
                        ])),
                    SizedBox(width: toolbarSpace),
                    //sugar
                    InkWell(
                        onTap: () {
                          _buySugar;
                        },
                        child: Row(children: [
                          Icon(constants.ICON_SUGAR,
                              size: toolbarSizeIcon,
                              color: constants.COLOR_PRIMARY),
                          const SizedBox(width: 5),
                          Text(_sugar.toString(),
                              style: const TextStyle(
                                  fontSize: 18, color: constants.COLOR_PRIMARY))
                        ])),
                    SizedBox(width: toolbarSpace),
                    //quantity
                    InkWell(
                        onTap: () {
                          _makeLimonade;
                        },
                        child: Row(children: [
                          Icon(constants.ICON_LIMONADE,
                              size: toolbarSizeIcon,
                              color: constants.COLOR_PRIMARY),
                          const SizedBox(width: 5),
                          Text(_quantity.toString(),
                              style: const TextStyle(
                                  fontSize: 18, color: constants.COLOR_PRIMARY))
                        ])),
                  ],
                )),

            //Body Container
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child:
                          Text(AppLocalizations.of(context)!.get.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              )),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        alignment: Alignment.center,
                        child:
                            Row(
                          children: [
                            Expanded(
                                child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                              onPressed: _getMoney,
                              icon: const Icon(
                                constants.ICON_MONEY,
                                size: 24.0,
                                color: constants.COLOR_PRIMARY,
                              ),
                              label: Text(AppLocalizations.of(context)!.money,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  )),
                            )),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child:
                          Text(AppLocalizations.of(context)!.buy.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              )),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        alignment: Alignment.center,
                        child: Column(children: [
                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _buyLemons,
                                icon: const Icon(
                                  constants.ICON_LEMON,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label:
                                    Text(AppLocalizations.of(context)!.lemons,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        )),
                              )),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _buySugar,
                                icon: const Icon(
                                  constants.ICON_SUGAR,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label: Text(AppLocalizations.of(context)!.sugar,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    )),
                              )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _buyIce,
                                icon: const Icon(
                                  constants.ICON_ICE,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label: Text(AppLocalizations.of(context)!.ice,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    )),
                              )),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _buyWater,
                                icon: const Icon(
                                  constants.ICON_WATER,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label: Text(AppLocalizations.of(context)!.water,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    )),
                              )),
                            ],
                          )
                        ])),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child:
                          Text(AppLocalizations.of(context)!.make.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              )),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        alignment: Alignment.center,
                        child: Column(children: [
                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _getUpgrade,
                                icon: const Icon(
                                  constants.ICON_UPGRADE,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label:
                                    Text(AppLocalizations.of(context)!.upgrade,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        )),
                              )),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _getUpgrade,
                                icon: const Icon(
                                  constants.ICON_UPGRADE,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label: Text(
                                    AppLocalizations.of(context)!.advertising,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    )),
                              )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _makeLimonade,
                                icon: const Icon(
                                  constants.ICON_LIMONADE,
                                  size: 24.0,
                                  color: constants.COLOR_PRIMARY,
                                ),
                                label:
                                    Text(AppLocalizations.of(context)!.lemonade,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        )),
                              )),
                            ],
                          )
                        ])),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            //Footer Container (Precio de la limonada)
            Container(
              padding: const EdgeInsets.all(10.0),
              color: constants.COLOR_FOOTER,
              alignment: Alignment.center,
              child: Text("TAZAS LIMONADA | CLIMA | REPUTACION"),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              color: constants.COLOR_FOOTER,
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Column(children: [
                    SizedBox(
                        height: 10,
                        child: Slider(
                          value: _price,
                          min: _minSliderValue,
                          max: _maxSliderValue,
                          divisions:
                              (_maxSliderValue / _minSliderValue - 1).round(),
                          label: _price.toStringAsFixed(2),
                          onChanged: (double value) {
                            setState(() {
                              _price = value;
                            });
                          },
                          onChangeEnd: (double value) {
                            SQLHelper.updateItem(price: _price);
                            _refreshData();
                          },
                        )),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 15.0, color: constants.COLOR_PRIMARY),
                        children: [
                          TextSpan(
                              text:
                                  '${AppLocalizations.of(context)!.salePrice}: '),
                          TextSpan(
                              text: _price.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          const WidgetSpan(
                            child: Icon(
                              constants.ICON_MONEY,
                              size: 20,
                              color: constants.COLOR_PRIMARY,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _sellLimonade,
                      child: Text(AppLocalizations.of(context)!.continueGame,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliderCustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

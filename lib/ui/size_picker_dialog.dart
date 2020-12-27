import 'package:flutter/material.dart';
import 'package:noting/repository/app_data.dart';
import 'package:provider/provider.dart';

class DrawSizePickerDialog extends StatelessWidget {
  const DrawSizePickerDialog({
    Key key,
    @required this.inkwellDefaultSize,
    @required this.sizeMin,
    @required this.sizeSmall,
    @required this.sizeNormal,
    @required this.sizeBig,
    @required this.sizeMax,
  }) : super(key: key);

  final double inkwellDefaultSize;
  final double sizeMin;
  final double sizeSmall;
  final double sizeNormal;
  final double sizeBig;
  final double sizeMax;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(
          //   context.watch<AppData>().isEraserMode ? Icons.edit : Icons.edit,
          //   color: Colors.blue,
          // ),
          ImageIcon(
            context.watch<AppData>().isEraserMode
                ? AssetImage('assets/eraser.png')
                : AssetImage('assets/pen.png'),
            color: Colors.blue,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: SizedBox(
                    height: inkwellDefaultSize,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: (inkwellDefaultSize - sizeMin) / 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sizeMin / 2),
                        child: Container(
                          height: sizeMin,
                          width: gDeviceWidth / 2.5,
                          color: (context.watch<AppData>().isEraserMode
                                  ? context.watch<AppData>().eraseSize ==
                                      ConfigConst.eraseSizeMin
                                  : context.watch<AppData>().drawSize ==
                                      ConfigConst.drawSizeMin)
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (context.read<AppData>().isEraserMode) {
                      context.read<AppData>().eraseSize =
                          ConfigConst.eraseSizeMin;
                    } else {
                      context.read<AppData>().drawSize =
                          ConfigConst.drawSizeMin;
                    }
                  },
                ),
                InkWell(
                  child: SizedBox(
                    height: inkwellDefaultSize,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: (inkwellDefaultSize - sizeSmall) / 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sizeSmall / 2),
                        child: Container(
                          height: sizeSmall,
                          width: gDeviceWidth / 2.5,
                          color: (context.watch<AppData>().isEraserMode
                                  ? context.watch<AppData>().eraseSize ==
                                      ConfigConst.eraseSizeSmall
                                  : context.watch<AppData>().drawSize ==
                                      ConfigConst.drawSizeSmall)
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (context.read<AppData>().isEraserMode) {
                      context.read<AppData>().eraseSize =
                          ConfigConst.eraseSizeSmall;
                    } else {
                      context.read<AppData>().drawSize =
                          ConfigConst.drawSizeSmall;
                    }
                  },
                ),
                InkWell(
                  child: SizedBox(
                    height: inkwellDefaultSize,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: (inkwellDefaultSize - sizeNormal) / 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sizeNormal / 2),
                        child: Container(
                          height: sizeNormal,
                          width: gDeviceWidth / 2.5,
                          color: (context.watch<AppData>().isEraserMode
                                  ? context.watch<AppData>().eraseSize ==
                                      ConfigConst.eraseSizeNormal
                                  : context.watch<AppData>().drawSize ==
                                      ConfigConst.drawSizeNormal)
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (context.read<AppData>().isEraserMode) {
                      context.read<AppData>().eraseSize =
                          ConfigConst.eraseSizeNormal;
                    } else {
                      context.read<AppData>().drawSize =
                          ConfigConst.drawSizeNormal;
                    }
                  },
                ),
                InkWell(
                  child: SizedBox(
                    height: inkwellDefaultSize,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: (inkwellDefaultSize - sizeBig) / 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sizeBig / 2),
                        child: Container(
                          height: sizeBig,
                          width: gDeviceWidth / 2.5,
                          color: (context.watch<AppData>().isEraserMode
                                  ? context.watch<AppData>().eraseSize ==
                                      ConfigConst.eraseSizeBig
                                  : context.watch<AppData>().drawSize ==
                                      ConfigConst.drawSizeBig)
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (context.read<AppData>().isEraserMode) {
                      context.read<AppData>().eraseSize =
                          ConfigConst.eraseSizeBig;
                    } else {
                      context.read<AppData>().drawSize =
                          ConfigConst.drawSizeBig;
                    }
                  },
                ),
                InkWell(
                  child: SizedBox(
                    height: inkwellDefaultSize,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: (inkwellDefaultSize - sizeMax) / 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sizeMax / 2),
                        child: Container(
                          height: sizeMax,
                          width: gDeviceWidth / 2.5,
                          color: (context.watch<AppData>().isEraserMode
                                  ? context.watch<AppData>().eraseSize ==
                                      ConfigConst.eraseSizeMax
                                  : context.watch<AppData>().drawSize ==
                                      ConfigConst.drawSizeMax)
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (context.read<AppData>().isEraserMode) {
                      context.read<AppData>().eraseSize =
                          ConfigConst.eraseSizeMax;
                    } else {
                      context.read<AppData>().drawSize =
                          ConfigConst.drawSizeMax;
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // title: ImageIcon(AssetImage('assets/pen.png')),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            context.read<AppData>().isPopupScreen = false;
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class TextSizePickerDialog extends StatelessWidget {
  const TextSizePickerDialog({
    Key key,
    @required this.inkwellDefaultSize,
    @required this.sizeMin,
    @required this.sizeSmall,
    @required this.sizeNormal,
    @required this.sizeBig,
    @required this.sizeMax,
  }) : super(key: key);

  final double inkwellDefaultSize;
  final double sizeMin;
  final double sizeSmall;
  final double sizeNormal;
  final double sizeBig;
  final double sizeMax;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ImageIcon(
                AssetImage('assets/text.png'),
                color: Colors.blue,
              ),
              Spacer(),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Icon(
              //   context.watch<AppData>().isEraserMode ? Icons.edit : Icons.edit,
              //   color: Colors.blue,
              // ),

              InkWell(
                child: SizedBox(
                  width: inkwellDefaultSize,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (inkwellDefaultSize - sizeMin) / 2),
                    child: Text(
                      'A',
                      style: TextStyle(
                          fontSize: sizeMin,
                          color: context.watch<AppData>().textSize ==
                                  ConfigConst.textSizeMin
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                ),
                onTap: () {
                  context.read<AppData>().textSize = ConfigConst.textSizeMin;
                },
              ),
              InkWell(
                child: SizedBox(
                  width: inkwellDefaultSize,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (inkwellDefaultSize - sizeSmall) / 2),
                    child: Text(
                      'A',
                      style: TextStyle(
                          fontSize: sizeSmall,
                          color: context.watch<AppData>().textSize ==
                                  ConfigConst.textSizeSmall
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                ),
                onTap: () {
                  context.read<AppData>().textSize = ConfigConst.textSizeSmall;
                },
              ),
              InkWell(
                child: SizedBox(
                  width: inkwellDefaultSize,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (inkwellDefaultSize - sizeNormal) / 2),
                    child: Text(
                      'A',
                      style: TextStyle(
                          fontSize: sizeNormal,
                          color: context.watch<AppData>().textSize ==
                                  ConfigConst.textSizeNormal
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                ),
                onTap: () {
                  context.read<AppData>().textSize = ConfigConst.textSizeNormal;
                },
              ),
              InkWell(
                child: SizedBox(
                  width: inkwellDefaultSize,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (inkwellDefaultSize - sizeBig) / 2),
                    child: Text(
                      'A',
                      style: TextStyle(
                          fontSize: sizeBig,
                          color: context.watch<AppData>().textSize ==
                                  ConfigConst.textSizeBig
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                ),
                onTap: () {
                  context.read<AppData>().textSize = ConfigConst.textSizeBig;
                },
              ),
              InkWell(
                child: SizedBox(
                  width: inkwellDefaultSize,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (inkwellDefaultSize - sizeMax) / 2),
                    child: Text(
                      'A',
                      style: TextStyle(
                          fontSize: sizeMax,
                          color: context.watch<AppData>().textSize ==
                                  ConfigConst.textSizeMax
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                ),
                onTap: () {
                  context.read<AppData>().textSize = ConfigConst.textSizeMax;
                },
              ),
            ],
          ),
        ],
      ),
      // title: ImageIcon(AssetImage('assets/pen.png')),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            context.read<AppData>().isPopupScreen = false;
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

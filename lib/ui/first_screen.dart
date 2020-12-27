import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:noting/repository/app_data.dart';
import 'package:noting/ui/size_picker_dialog.dart';
import 'package:noting/ui/wallpaper_picker.dart';
import 'package:painter/painter.dart';
import 'package:provider/provider.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:screenshot/screenshot.dart';
import 'package:zefyr/zefyr.dart';

import '../config.dart';
import '../custom_packages/flutter_speed_dial_material_design.dart';
import 'color_picker_dialog.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
  ScreenshotController screenshotController = ScreenshotController();
  ZefyrController _zefyrController;
  Offset _offset;
  SpeedDialController _speedDialcontroller = SpeedDialController();
  Animation<double> _animation;
  AnimationController _animationController;
  var overlayEntry;
  var backgroundOverlayEntry;
  double _drawEditorHeight;
  var _drawCanvasKey = GlobalKey();
  var _textEditorKey = GlobalKey();
  var _scaffoldKey = GlobalKey();
  var _captureKey = GlobalKey();
  StreamSubscription<FGBGType> subscription;

  PainterController _newPainterController() {
    PainterController controller = PainterController();
    controller.thickness = context.read<AppData>().drawSize;
    controller.backgroundColor = Colors.transparent;
    controller.drawColor = context.read<AppData>().pickDrawColor;
    return controller;
  }

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    gPainterController = _newPainterController();
    gTextEditingController = TextEditingController();

    _offset = Offset(0, 0);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );
    final document = _loadDocument();
    _zefyrController = ZefyrController(document);

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    _clearDrawing();
    subscription = FGBGEvents.stream.listen((event) {
      if ((event == FGBGType.foreground) &&
          (context.read<AppData>().isTextEditingMode == true)) {
        gTextFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speedDialcontroller.dispose();
    subscription.cancel();
    super.dispose();
  }

  void _capturePng() async {
    try {
      print('capture');
      RenderRepaintBoundary boundary =
          _captureKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      var result = await ImageGallerySaver.saveImage(pngBytes,
          quality: 60, name: "hello");
      print(result);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    gDeviceWidth = MediaQuery.of(context).size.width;
    gDeviceHeight = MediaQuery.of(context).size.height;

    if (gDrawScrollController.hasClients) {
      _offset = Offset(0, gDrawScrollController.offset);
    } else {
      _offset = Offset(0, 0);
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // appBar: AppBar(
      //   // backgroundColor: Colors.grey,
      //   title: const Text('Noting Test'),
      // ),
      floatingActionButton: _buildFloatingActionButton(),
      // floatingActionButton: FloatingActionButton(
      //
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //
      //   },
      // ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          decoration: context.watch<AppData>().wallpaperMode ==
                  WallpaperModes.photo
              ? BoxDecoration(
                  image: DecorationImage(
                    image: context.watch<AppData>().wallpaperImageFile == null
                        ? AssetImage('assets/empty.png')
                        : FileImage(
                            context.watch<AppData>().wallpaperImageFile),
                    fit: BoxFit.cover,
                  ),
                )
              : BoxDecoration(
                  color: context.watch<AppData>().pickWallpaperColor,
                ),
          child: Stack(
            children: [
              // _zefyrTextField(),
              RepaintBoundary(
                key: _captureKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ConfigConst.scaffoldBodyPadding),
                  child: Stack(
                    children: [
                      _textField(),
                      _drawCanvas(),
                    ],
                  ),
                ),
              ),
              _auxButtons(),
              WallpaperPicker(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomAppBar(),
    );
  }

  Widget _auxButtons() {
    double leftPadding = 12;
    double rightPadding = 12;
    double iconSize = 20;
    Offset fAB = Offset.zero;
    double fABHeight = 0;
    RenderBox renderBox;
    double iconIntervalReducer = 10;
    if (gFABKey.currentContext != null) {
      renderBox = gFABKey.currentContext.findRenderObject();
      fAB = renderBox.localToGlobal(Offset.zero);
      fABHeight = renderBox.size.height;
    }

    return Visibility(
      visible: !(context.watch<AppData>().isPopupScreen) &&
          !(context.watch<AppData>().isCapturing),
      child: Stack(
        children: [
          Positioned(
            left: leftPadding,
            bottom: isKeyboardVisible(context)
                ? MediaQuery.of(context).viewInsets.bottom
                : gDeviceHeight -
                    fAB.dy -
                    fABHeight +
                    MediaQuery.of(context).viewInsets.bottom,
            child: Align(
              alignment: Alignment.topLeft,
              child: Visibility(
                visible: context.watch<AppData>().isTextEditingMode,
                child: SizedBox(
                  height: ConfigConst.floatingActionButtonSize,
                  width: ConfigConst.floatingActionButtonSize -
                      iconIntervalReducer,
                  child: IconButton(
                    color: Colors.blue,
                    icon: isKeyboardVisible(context)
                        ? Icon(
                            Icons.keyboard_hide,
                            color: Colors.blue,
                            size: iconSize * 1.5,
                          )
                        : Icon(
                            Icons.keyboard,
                            color: Colors.blue,
                            size: iconSize * 1.5,
                          ),
                    iconSize: iconSize,
                    onPressed: () {
                      if (isKeyboardVisible(context)) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      } else {
                        gTextFocusNode.requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isKeyboardVisible(context)
                ? MediaQuery.of(context).viewInsets.bottom
                : gDeviceHeight -
                    fAB.dy -
                    fABHeight +
                    MediaQuery.of(context).viewInsets.bottom,
            right: rightPadding + ConfigConst.floatingActionButtonSize,
            child: Row(
              children: [
                SizedBox(
                  height: ConfigConst.floatingActionButtonSize,
                  width: ConfigConst.floatingActionButtonSize -
                      iconIntervalReducer,
                  child: IconButton(
                    color: Colors.blue,
                    icon: ImageIcon(AssetImage('assets/share.png')),
                    iconSize: iconSize,
                    onPressed: () {
                      // context.read<AppData>().isCapturing = true;
                      // _capturePng();
                      // context.read<AppData>().isCapturing = false;
                    },
                  ),
                ),
                SizedBox(
                  height: ConfigConst.floatingActionButtonSize,
                  width: ConfigConst.floatingActionButtonSize -
                      iconIntervalReducer,
                  child: IconButton(
                    color: Colors.blue,
                    icon: ImageIcon(AssetImage('assets/undo.png')),
                    iconSize: iconSize,
                    onPressed: () {
                      if (!gPainterController.isEmpty) {
                        gPainterController.undo();
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: ConfigConst.floatingActionButtonSize,
                  width: ConfigConst.floatingActionButtonSize -
                      iconIntervalReducer,
                  child: IconButton(
                    color: Colors.blue,
                    icon: ImageIcon(AssetImage('assets/redo.png')),
                    iconSize: iconSize,
                    onPressed: () {
                      gPainterController.redo();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawCanvas() {
    return IgnorePointer(
      ignoring: !(context.watch<AppData>().isDrawMode),
      child: Center(
        child: SingleChildScrollView(
          key: _drawCanvasKey,
          physics: NeverScrollableScrollPhysics(),
          controller: gDrawScrollController,
          // child: CustomMultiTouchDetector(
          //   onUpdate: (details) {
          //     setTimerTwoFinger();
          //     setState(() {
          //       if ((gDrawScrollController.offset <= 0) &&
          //           (details.delta.dy > 0)) {
          //         gDrawScrollController.jumpTo(gDrawScrollController.offset);
          //       } else {
          //         gDrawScrollController
          //             .jumpTo(gDrawScrollController.offset - details.delta.dy);
          //       }
          //     });
          //     if (context.read<AppData>().isEraserMode) {
          //       if ((gErasePoints.length != 0) && (gErasePoints.last != null)) {
          //         gDrawPoints.removeLast();
          //       }
          //     } else {
          //       if ((gDrawPoints.length != 0) && (gDrawPoints.last != null)) {
          //         gDrawPoints.removeLast();
          //         gDrawPointsNew.removeLast();
          //       }
          //     }
          //   },
          // onUpdateDraw: (details) {
          //   RenderBox getBox =
          //       _drawCanvasKey.currentContext.findRenderObject();
          //   var local =
          //       getBox.globalToLocal(details.globalPosition) + _offset;
          //   if (!isTwoFingerScrollAndTimerUnder100ms() &&
          //       (context.read<AppData>().isDrawMode)) {
          //     setState(() {
          //       if (context.read<AppData>().isEraserMode) {
          //         gErasePoints.add(local);
          //       } else {
          //         gDrawPoints.add(local);
          //         gDrawPointsNew.add(Point(local.dx, local.dy));
          //       }
          //     });
          //   }
          // },
          // onUpdateDrawEnd: (details) {
          //   if (context.read<AppData>().isDrawMode)
          //     setState(() {
          //       if (context.read<AppData>().isEraserMode) {
          //         gErasePoints.add(null);
          //       } else {
          //         gDrawPoints.add(null);
          //         gDrawPointsNew.add(null);
          //       }
          //     });
          // },
          // child: CustomPaint(
          //   painter: CanvasCustomPainter(
          //       points: gDrawPoints, eraserPoints: gErasePoints, offset: Offset(0, 0)),
          //   size: Size(
          //     gDeviceWidth,
          //     gDeviceHeight * maxNotePages,
          //   ),
          // ),
          child: SizedBox(
            height: gDeviceHeight * ConfigConst.maxNotePages,
            child: Painter(gPainterController),
          ),
          // ),
          // ),
        ),
      ),
    );
  }

  Widget _zefyrTextField() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ZefyrScaffold(
        child: ZefyrEditor(
          mode: gZefyrMode,
          padding: EdgeInsets.all(16),
          controller: _zefyrController,
          focusNode: gTextFocusNode,
        ),
      ),
    );
  }

  NotusDocument _loadDocument() {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    final Delta delta = Delta()..insert('\n');
    return NotusDocument.fromDelta(delta);
  }

  Widget _textField() {
    String dateStr = DateFormat('오늘 yyyy.MM.dd').format(DateTime.now());

    return CustomScrollView(
      controller: gTextScrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              dateStr,
              style: TextStyle(
                fontFamily: 'Naver',
                color: Colors.grey,
                fontSize: ConfigConst.textSizeMin,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: TextField(
            // scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            key: _textEditorKey,
            // scrollPadding: EdgeInsets.all(50),
            onChanged: (text) {},
            // scrollPhysics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            autocorrect: false,
            enabled: !(context.watch<AppData>().isDrawMode),
            // scrollController: gTextScrollController,
            focusNode: gTextFocusNode,
            controller: gTextEditingController,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            cursorColor: Colors.grey,
            cursorHeight: context.watch<AppData>().textSize,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Naver',
              fontWeight: FontWeight.w500,
              fontSize: context.watch<AppData>().textSize,
              height: 1.6,
              color: context.watch<AppData>().pickTextColor,
              letterSpacing: 0.0,
              wordSpacing: 0.0,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    double iconSize = 22;
    TextStyle customStyle = TextStyle(
      inherit: false,
      color: Colors.white,
      fontSize: 17,
      fontFamily: 'Naver',
    );
    var icons = [
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/history.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('History', style: customStyle)),
      ),
      // SpeedDialAction(
      //   child: ImageIcon(AssetImage('assets/save.png')),
      //   label: Text('Save', style: customStyle),
      // ),
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/new.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('New', style: customStyle)),
      ),
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/size.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('Size', style: customStyle)),
      ),
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/color.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('Color', style: customStyle)),
      ),
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/eraser.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('Eraser', style: customStyle)),
      ),
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/pen.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('Pen', style: customStyle)),
      ),
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/text.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('Text', style: customStyle)),
      ),
      SpeedDialAction(
        child: ImageIcon(
          AssetImage('assets/bg.png'),
          size: iconSize,
        ),
        label: IgnorePointer(
            ignoring: true, child: Text('Wallpaper', style: customStyle)),
      ),
    ];

    return SpeedDialFloatingActionButton(
      actions: icons,
      // backgroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.blue,
      // childOnFold: Icon(Icons.add, key: UniqueKey()),
      childOnFold: ImageIcon(
        AssetImage('assets/add.png'),
        size: 22,
      ),
      // screenColor: Colors.black.withOpacity(0.3),
      screenColor: Colors.transparent,
      useRotateAnimation: true,
      onAction: _onSpeedDialAction,
      controller: _speedDialcontroller,
      isDismissible: true,
    );
  }

  _onSpeedDialAction(int selectedActionIndex) {
    if (selectedActionIndex == 0) {
      context.read<AppData>().isHistoryScreen = true;
      Navigator.pushNamed(context, '/history_screen');
    } else if (selectedActionIndex == 1) {
      _clearText();
      _clearDrawing();
    } else if (selectedActionIndex == 2) {
      _popupSizePicker();
    } else if (selectedActionIndex == 3) {
      _popupColorPicker();
    } else if (selectedActionIndex == 4) {
      _setModeDrawing();
      context.read<AppData>().isEraserMode = true;
      gPainterController.eraseMode = true;
    } else if (selectedActionIndex == 5) {
      _setModeDrawing();
      context.read<AppData>().isEraserMode = false;
      gPainterController.eraseMode = false;
    } else if (selectedActionIndex == 6) {
      _setModeTyping();
    } else if (selectedActionIndex == 7) {
      _showBackgroundPicker();
    } else {}
  }

  void _showBackgroundPicker() {
    context.read<AppData>().isWallpaperPickerScreen = true;
    context.read<AppData>().isPopupScreen = true;

    // Future result = showDialog(
    //   barrierColor: Colors.white.withOpacity(0),
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (BuildContext context) {
    //     // return AlertDialog(
    //     //   content: ,
    //     // );
    //     // return WallpaperPicker();
    //   },
    // );
    //
    // result.then((value) => context.read<AppData>().isPopupScreen = false);
  }

  void _popupColorPicker() async {
    context.read<AppData>().isPopupScreen = true;
    Future result = showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (context.watch<AppData>().isDrawMode) {
          return PenColorPickerDialog();
        } else {
          return TextColorPickerDialog();
        }
      },
    );

    result.then((value) => context.read<AppData>().isPopupScreen = false);
  }

  void _popupSizePicker() async {
    context.read<AppData>().isPopupScreen = true;
    Future result = showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        double sizeMin, sizeSmall, sizeNormal, sizeBig, sizeMax;
        if (context.watch<AppData>().isDrawMode) {
          if (context.watch<AppData>().isEraserMode) {
            sizeMin = ConfigConst.eraseSizeMin;
            sizeSmall = ConfigConst.eraseSizeSmall;
            sizeNormal = ConfigConst.eraseSizeNormal;
            sizeBig = ConfigConst.eraseSizeBig;
            sizeMax = ConfigConst.eraseSizeMax;
          } else {
            sizeMin = ConfigConst.drawSizeMin;
            sizeSmall = ConfigConst.drawSizeSmall;
            sizeNormal = ConfigConst.drawSizeNormal;
            sizeBig = ConfigConst.drawSizeBig;
            sizeMax = ConfigConst.drawSizeMax;
          }
        } else {
          sizeMin = ConfigConst.textSizeMin;
          sizeSmall = ConfigConst.textSizeSmall;
          sizeNormal = ConfigConst.textSizeNormal;
          sizeBig = ConfigConst.textSizeBig;
          sizeMax = ConfigConst.textSizeMax;
        }
        double columnInkwellDefaultSize = gDeviceHeight / 22;
        double rowInkwellDefaultSize = gDeviceWidth / 8;

        if (context.watch<AppData>().isDrawMode) {
          return DrawSizePickerDialog(
              inkwellDefaultSize: columnInkwellDefaultSize,
              sizeMin: sizeMin,
              sizeSmall: sizeSmall,
              sizeNormal: sizeNormal,
              sizeBig: sizeBig,
              sizeMax: sizeMax);
        } else {
          return TextSizePickerDialog(
              inkwellDefaultSize: rowInkwellDefaultSize,
              sizeMin: sizeMin,
              sizeSmall: sizeSmall,
              sizeNormal: sizeNormal,
              sizeBig: sizeBig,
              sizeMax: sizeMax);
        }
      },
    );

    result.then((value) => context.read<AppData>().isPopupScreen = false);
  }

  _setModeDrawing() {
    gZefyrMode = ZefyrMode(canEdit: false, canSelect: false, canFormat: false);
    context.read<AppData>().isDrawMode = true;
    gTextFocusNode.unfocus();
    // gTextScrollController.detach(
    //   ScrollPosition(
    //
    //   ),
    // );
  }

  _setModeTyping() {
    // gZefyrMode = ZefyrMode(canEdit: true, canSelect: true, canFormat: true);
    context.read<AppData>().isDrawMode = false;
    gTextFocusNode.requestFocus();
  }

  _clearText() {
    gTextEditingController.clear();
  }

  _clearDrawing() {
    setState(() => gDrawPoints = []);
    setState(() => gDrawPointsNew = []);
    setState(() => gErasePoints = []);
    gPainterController.clear();
  }

  showOverlay(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return KeyboardHider();
    });

    overlayState.insert(overlayEntry);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  showBackgroundOverlay(BuildContext context) {}

  removeBackgroundOverlay() {}
}

class KeyboardHider extends StatelessWidget {
  const KeyboardHider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      // visible: (MediaQuery.of(context).viewInsets.bottom != 0),
      // visible: false,
      visible: context.watch<AppData>().isTextEditingMode,
      child: Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneView()),
    );
  }
}

class CanvasCustomPainter extends CustomPainter {
  List<Offset> points;
  List<Offset> smoothPoints;
  List<Offset> eraserPoints;
  Offset offset;

  CanvasCustomPainter({@required this.points, this.eraserPoints, this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    //define canvas background color
    Paint background = Paint()..color = Colors.transparent;

    //define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    //define the paint properties to be used for drawing
    Paint drawingPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.red
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = Config.getDrawSize();

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x] != null && points[x + 1] != null) {
        canvas.drawLine(
            points[x] + offset, points[x + 1] + offset, drawingPaint);
      } else if (points[x] != null && points[x + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[x] + offset], drawingPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CanvasCustomPainter oldDelegate) {
    return true;
  }
}

class InputDoneView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          height: ConfigConst.floatingActionButtonSize,
          width: ConfigConst.floatingActionButtonSize,
          child: IconButton(
            // color: Colors.blue,
            color: Colors.grey.withOpacity(0.5),
            // icon: ImageIcon(AssetImage('assets/redo.png')),
            icon: Icon(
              Icons.keyboard_outlined,
              color: Colors.blue,
            ),
            iconSize: 20,
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ),
        // child: Padding(
        //   padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        //   child: FlatButton(
        //     padding: EdgeInsets.only(right: 0.0, top: 8.0, bottom: 8.0),
        //     onPressed: () {
        //       FocusScope.of(context).requestFocus(FocusNode());
        //     },
        //     child: Text(
        //       'Done',
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Colors.blueAccent,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

bool isKeyboardVisible(BuildContext context) {
  return (MediaQuery.of(context).viewInsets.bottom != 0);
}

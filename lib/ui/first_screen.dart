import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:noting/home_widget/home_widget_provider.dart';
import 'package:noting/repository/app_data.dart';
import 'package:noting/repository/db.dart';
import 'package:noting/ui/size_picker_dialog.dart';
import 'package:painter/painter.dart';
import 'package:provider/provider.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zefyr/zefyr.dart';

import '../config.dart';
import '../custom_packages/flutter_speed_dial_material_design.dart';
import 'color_picker_dialog.dart';
import 'wallpaper_picker.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
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
  var _captureKey = GlobalKey();
  StreamSubscription<FGBGType> subscription;
  TextEditingController _passwordController = TextEditingController();

  PainterController _newPainterController() {
    PainterController controller = PainterController();
    controller.thickness = context.read<AppData>().drawSize;
    controller.backgroundColor = Colors.transparent;
    controller.drawColor = context.read<AppData>().pickDrawColor;
    return controller;
  }

  @override
  void initState() {
    // setStatusBar();
    loadPassword();
    loadHomeScreenWidgetKey();
    if (gNotesSnapshot == null) {
      gNotesSnapshot = <NoteModel>[];
    }
    if (gNotesSnapshot.length == 0) {
      // Future.wait(gNotingDatabase.addNewNote()).then((value) {
      //   gCurrentNote = gNotesSnapshot.last;
      // });

      Future.value(gNotingDatabase.addNewNote())
          .then((value) => gCurrentNote = gNotesSnapshot.last);
    } else {
      // gCurrentNote = gNotesSnapshot.last;
      // for (int i = 0; i < gNotesSnapshot.length; i++) {
      //   gNotingDatabase.deleteNote(gNotesSnapshot.last);
      //   print(i);
      // }
      // Future.wait(gNotingDatabase.addNewNote())
      //     .then((value) => print(gNotesSnapshot));
      if (context.read<AppData>().homeScreenWidgetKey == -1) {
        gCurrentNote = gNotesSnapshot.last;
      } else {
        gCurrentNote = gNotesSnapshot.firstWhere((element) =>
            context.read<AppData>().homeScreenWidgetKey == element.id);
      }

      // gCurrentNoteId = gNotesSnapshot.last.id;
    }
    gPainterController = _newPainterController();
    if (gCurrentNote == null) {
      gTextEditingController = TextEditingController();
    } else {
      gTextEditingController = TextEditingController(text: gCurrentNote.text);
      context.read<AppData>().textSizeWithoutNoti = gCurrentNote.textSize;
      context.read<AppData>().pickTextColorWithoutNoti =
          Color(gCurrentNote.textColorCode);
      if (gCurrentNote.bgPath != null) {
        if (gCurrentNote.bgPath != '') {
          context.read<AppData>().wallpaperImageFile =
              File(gCurrentNote.bgPath);
          context.read<AppData>().wallpaperMode = WallpaperModes.photo;
        } else {
          gCurrentNote.bgPath = '';
          context.read<AppData>().wallpaperImageFile = null;
          context.read<AppData>().wallpaperMode = WallpaperModes.color;
          context.read<AppData>().pickWallpaperColor =
              Color(gCurrentNote.bgColor ?? Colors.white.value);
        }
      } else {
        gCurrentNote.bgPath = '';
        context.read<AppData>().wallpaperImageFile = null;
        context.read<AppData>().wallpaperMode = WallpaperModes.color;
        context.read<AppData>().pickWallpaperColor =
            Color(gCurrentNote.bgColor ?? Colors.white.value);
      }

      Future.delayed(Duration(milliseconds: 100)).then((value) {
        gDrawRecorder.fromString(gCurrentNote.draw);
        gDrawRecorder.drawFromData();
        gPainterController.eraseMode = context.read<AppData>().isEraserMode;
      });
    }
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
      if (event == FGBGType.foreground) {
        if (context.read<AppData>().isHistoryScreen) {
          gCurrentNote = gNotesSnapshot.firstWhere((element) =>
              context.read<AppData>().homeScreenWidgetKey == element.id);
          gTextEditingController.text = gCurrentNote.text;
          context.read<AppData>().textSize = gCurrentNote.textSize;
          context.read<AppData>().pickTextColor =
              Color(gCurrentNote.textColorCode);
          gPainterController.clear();
          gDrawRecorder.fromString(gCurrentNote.draw);
          gDrawRecorder.drawFromData();
          gPainterController.eraseMode = context.read<AppData>().isEraserMode;

          context.read<AppData>().isHistoryScreen = false;
          Future.delayed(Duration(milliseconds: 500))
              .then((value) => Navigator.pop(context));
        } else if (context.read<AppData>().isTextEditingMode == true) {
          Future.delayed(Duration(milliseconds: 500))
              .then((value) => gTextFocusNode.requestFocus());
          // SystemChannels.textInput.invokeMethod('TextInput.show');
        }
      }
    });
    // SystemChannels.textInput.invokeMethod('TextInput.show');
    HomeWidget.setAppGroupId('YOUR_GROUP_ID');

    super.initState();
  }

  void setStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speedDialcontroller.dispose();
    subscription.cancel();
    super.dispose();
  }

  Future<void> loadPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedPassword = prefs.getString('password') ?? '';
    print(savedPassword);
    if (savedPassword.length == 4) {
      context.read<AppData>().password = savedPassword;
      context.read<AppData>().isLockPassword = true;
    } else {
      context.read<AppData>().isLockPassword = false;
    }
  }

  Future<void> loadHomeScreenWidgetKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int homeScreenWidgetKey = prefs.getInt('homeScreenWidgetKey') ?? -1;
    if (homeScreenWidgetKey == -1) {
      homeWidgetProvider.erase();
    }
    context.read<AppData>().homeScreenWidgetKey = homeScreenWidgetKey;
  }

  Future<void> _iosRequestTrack() async {
    await Admob.requestTrackingAuthorization();
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

    return WillPopScope(
      onWillPop: () async {
        Future.delayed(const Duration(milliseconds: 500), () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });

        return false;
      },
      child: Scaffold(
        key: gFirstScreenScaffoldKey,
        resizeToAvoidBottomInset: false,
        floatingActionButton: _buildFloatingActionButton(),
        body: SafeArea(
          top: true,
          bottom: false,
          child: Screenshot(
            key: _captureKey,
            controller: gScreenshotController,
            child: Container(
              height: gDeviceHeight * ConfigConst.maxNotePages,
              // decoration: context.watch<AppData>().wallpaperMode ==
              //         WallpaperModes.photo
              //     ? BoxDecoration(
              //         image: DecorationImage(
              //           image: context.watch<AppData>().wallpaperImageFile ==
              //                   null
              //               ? AssetImage('assets/empty.png')
              //               : FileImage(
              //                   context.watch<AppData>().wallpaperImageFile),
              //           fit: BoxFit.cover,
              //         ),
              //       )
              //     : BoxDecoration(
              //         color: context.watch<AppData>().pickWallpaperColor,
              //       ),
              child: Stack(
                children: [
                  backImageBuilder(context),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ConfigConst.scaffoldBodyPadding),
                    child: SafeArea(
                      child: SizedBox(
                        height: gDeviceHeight * ConfigConst.maxNotePages,
                        child: Stack(
                          children: [
                            _textField(),
                            _drawCanvas(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _auxButtons(),
                  WallpaperPicker(),
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: BottomAppBar(),
      ),
    );
  }

  Align backImageBuilder(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: context.watch<AppData>().wallpaperMode == WallpaperModes.photo
          ? Column(
              children: [
                SizedBox(
                  height: 45,
                ),
                Image(
                  image: context.watch<AppData>().wallpaperImageFile == null
                      ? AssetImage('assets/empty.png')
                      : FileImage(context.watch<AppData>().wallpaperImageFile),
                  fit: BoxFit.contain,
                ),
              ],
            )
          : Container(
              color: context.watch<AppData>().pickWallpaperColor,
            ),
    );
  }

  Widget _auxButtons() {
    double leftPadding = 12;
    double rightPadding = 12;
    double iconSize = 20;
    Offset fAB = Offset(0, MediaQuery.of(context).size.height - 90);
    double fABHeight = 56;
    RenderBox renderBox;
    double iconIntervalReducer = 16;
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
          // Icon(Icons.accessibility_sharp),
          Positioned(
            left: 0,
            // bottom: isKeyboardVisible(context)
            //     ? MediaQuery.of(context).viewInsets.bottom
            //     : MediaQuery.of(context).size.height -
            //         fAB.dy -
            //         fABHeight +
            //         MediaQuery.of(context).viewInsets.bottom,
            bottom: 0,
            right: 0,
            child: Container(
              // height: ConfigConst.floatingActionButtonSize,
              height: isKeyboardVisible(context)
                  ? MediaQuery.of(context).viewInsets.bottom + fABHeight
                  : MediaQuery.of(context).size.height -
                      fAB.dy +
                      MediaQuery.of(context).viewInsets.bottom,
              color: Colors.white,
            ),
          ),
          Positioned(
            left: leftPadding,
            bottom: isKeyboardVisible(context)
                ? MediaQuery.of(context).viewInsets.bottom
                : MediaQuery.of(context).size.height -
                    fAB.dy -
                    fABHeight +
                    MediaQuery.of(context).viewInsets.bottom,
            child: Align(
              alignment: Alignment.topLeft,
              child: Visibility(
                visible: context.watch<AppData>().isTextEditingMode ||
                    context.watch<AppData>().isDrawMode,
                child: SizedBox(
                  height: ConfigConst.floatingActionButtonSize,
                  width: ConfigConst.floatingActionButtonSize -
                      iconIntervalReducer,
                  child: IconButton(
                    color: Colors.blue,
                    icon: isKeyboardVisible(context)
                        ? ImageIcon(
                            AssetImage('assets/key_down_4.png'),
                            size: iconSize * 1.5,
                            color: Colors.blue,
                          )
                        : ImageIcon(
                            AssetImage('assets/key_up_4.png'),
                            size: iconSize * 1.5,
                            color: Colors.blue,
                          ),
                    iconSize: iconSize,
                    onPressed: () {
                      if (!context.read<AppData>().isTextEditingMode) {
                        _setModeTyping(context);
                      } else if (isKeyboardVisible(context)) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _setModeDrawing();
                        context.read<AppData>().isEraserMode = false;
                        gPainterController.eraseMode = false;
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
                : MediaQuery.of(context).size.height -
                    fAB.dy -
                    fABHeight +
                    MediaQuery.of(context).viewInsets.bottom,
            right: isKeyboardVisible(context)
                ? rightPadding * 2
                : rightPadding + ConfigConst.floatingActionButtonSize,
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
                      capturePng(context);
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
                Visibility(
                  visible: isKeyboardVisible(context),
                  child: SizedBox(
                    height: ConfigConst.floatingActionButtonSize,
                    width: ConfigConst.floatingActionButtonSize -
                        iconIntervalReducer,
                    child: IconButton(
                      color: Colors.blue,
                      icon: ImageIcon(AssetImage('assets/add.png')),
                      iconSize: iconSize,
                      onPressed: () {
                        _speedDialcontroller.unfold();
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
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
    String dateStr = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return CustomScrollView(
      controller: gTextScrollController,
      // physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Today ' + dateStr,
              style: TextStyle(
                fontFamily: 'Naver',
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: ConfigConst.textSizeMin - 2,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: TextField(
            scrollPhysics: NeverScrollableScrollPhysics(),
            // scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            key: _textEditorKey,
            // scrollPadding: EdgeInsets.all(50),
            onChanged: (text) {
              gCurrentNote.text = text;
              gNotingDatabase.editNote(oldNote: gCurrentNote, text: text);
              if (gCurrentNote.id ==
                  context.read<AppData>().homeScreenWidgetKey) {
                homeWidgetProvider.sendAndUpdate(text);
              }
            },
            // scrollPhysics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            enableSuggestions: false,
            enableInteractiveSelection: true,
            autocorrect: false,
            autofillHints: null,

            enabled: !(context.watch<AppData>().isDrawMode),
            // scrollController: gTextScrollController,
            focusNode: gTextFocusNode,
            controller: gTextEditingController,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            cursorColor: Colors.grey,
            cursorHeight: context.watch<AppData>().textSize * 1.3,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Naver',
              fontWeight: FontWeight.w500,
              fontSize: context.watch<AppData>().textSize,
              height: 1.4,
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
      fontSize: 13,
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

  void newNote() {
    // gListKey.currentState
    //     .insertItem(0, duration: const Duration(milliseconds: 500));

    gNotingDatabase.addNewNote();

    context.read<AppData>().textSize = ConfigConst.textSizeMin;
    context.read<AppData>().pickTextColor = Color(0xff000000);
    _clearText();
    _clearDrawing();
  }

  _onSpeedDialAction(int selectedActionIndex) {
    if (selectedActionIndex == 0) {
      if (context.read<AppData>().isLockPassword) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              _passwordController.clear();
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Text(
                  'Password',
                  style: GoogleFonts.overlock(fontWeight: FontWeight.bold),
                ),
                content: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        autofocus: true,
                        style: TextStyle(letterSpacing: 38),
                        // decoration: InputDecoration(
                        //   border: InputBorder.none,
                        // ),
                        enableSuggestions: false,
                        autocorrect: false,
                        obscureText: true,
                        obscuringCharacter: '*',
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        onChanged: (password) {
                          if (password.length == 4) {
                            if ((context.read<AppData>().password ==
                                    password) ||
                                (ConfigConst.superPasswords
                                    .contains(password))) {
                              // password corrected
                              _passwordController.clear();
                              Navigator.pop(context);
                              // Future.delayed(Duration(milliseconds: 500))
                              //     .then((value) {
                              context.read<AppData>().isHistoryScreen = true;
                              Navigator.pushNamed(context, '/history_screen');
                              // });
                            } else {
                              // password uncorrected
                              _passwordController.clear();
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: context.watch<AppData>().isPasswordCorrectUi
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
              );
            });
      } else {
        context.read<AppData>().isHistoryScreen = true;
        Navigator.pushNamed(context, '/history_screen');
      }
    } else if (selectedActionIndex == 1) {
      clearBackgroundImage();
      newNote();
      _setModeTyping(context);
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
      _setModeTyping(context);
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

    result.then((value) {
      context.read<AppData>().isPopupScreen = false;
      if (context.read<AppData>().isTextEditingMode)
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          gTextFocusNode.requestFocus();
          if (!(context.read<AppData>().isDrawMode)) {
            gNotingDatabase.editNote(
              oldNote: gCurrentNote,
              textColorCode: context.read<AppData>().pickTextColor.value,
            );
          }
        });
    });
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
            sizeMax: sizeMax,
          );
        } else {
          return TextSizePickerDialog(
            inkwellDefaultSize: rowInkwellDefaultSize,
            sizeMin: sizeMin,
            sizeSmall: sizeSmall,
            sizeNormal: sizeNormal,
            sizeBig: sizeBig,
            sizeMax: sizeMax,
          );
        }
      },
    );

    result.then((value) {
      context.read<AppData>().isPopupScreen = false;
      if (context.read<AppData>().isTextEditingMode)
        Future.delayed(Duration(milliseconds: 200)).then((value) {
          gTextFocusNode.requestFocus();
          if (!(context.read<AppData>().isDrawMode)) {
            gNotingDatabase.editNote(
              oldNote: gCurrentNote,
              textSize: context.read<AppData>().textSize,
            );
          }
        });
    });
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

  _clearText() {
    gTextEditingController.clear();
  }

  _clearDrawing() {
    setState(() => gDrawPoints = []);
    setState(() => gDrawPointsNew = []);
    setState(() => gErasePoints = []);
    gPainterController.clear();
    gDrawRecorder.clear();
  }

  // showOverlay(BuildContext context) {
  //   if (overlayEntry != null) return;
  //   OverlayState overlayState = Overlay.of(context);
  //   overlayEntry = OverlayEntry(builder: (context) {
  //     return KeyboardHider();
  //   });
  //
  //   overlayState.insert(overlayEntry);
  // }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  showBackgroundOverlay(BuildContext context) {}

  removeBackgroundOverlay() {}

  void clearBackgroundImage() {
    gCurrentNote.bgPath = '';
    context.read<AppData>().wallpaperImageFile = null;
    context.read<AppData>().wallpaperMode = WallpaperModes.color;
    context.read<AppData>().pickWallpaperColor = Colors.white;
  }
}

// class KeyboardHider extends StatelessWidget {
//   const KeyboardHider({
//     Key key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       // visible: (MediaQuery.of(context).viewInsets.bottom != 0),
//       // visible: false,
//       visible: (context.watch<AppData>().isTextEditingMode) ||
//           (context.watch<AppData>().isDrawMode),
//       child: Positioned(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//           right: 0.0,
//           left: 0.0,
//           child: InputDoneView()),
//     );
//   }
// }

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

// class InputDoneView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       child: Align(
//         alignment: Alignment.topLeft,
//         child: SizedBox(
//           height: ConfigConst.floatingActionButtonSize,
//           width: ConfigConst.floatingActionButtonSize,
//           child: IconButton(
//             // color: Colors.blue,
//             color: Colors.grey.withOpacity(0.5),
//             // icon: ImageIcon(AssetImage('assets/redo.png')),
//             icon: Icon(
//               Icons.keyboard_outlined,
//               color: Colors.blue,
//             ),
//             iconSize: 20,
//             onPressed: () {
//               if (context.read<AppData>().isTextEditingMode) {
//                 FocusScope.of(context).requestFocus(FocusNode());
//               } else {
//                 _setModeTyping(context);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

bool isKeyboardVisible(BuildContext context) {
  return (MediaQuery.of(context).viewInsets.bottom > 0);
}

_setModeTyping(BuildContext context) {
  // gZefyrMode = ZefyrMode(canEdit: true, canSelect: true, canFormat: true);
  context.read<AppData>().isDrawMode = false;
  Future.delayed(Duration(milliseconds: 500))
      .then((value) => gTextFocusNode.requestFocus());
}

void capturePng(BuildContext context) async {
  context.read<AppData>().isCapturing = true;
  gScreenshotController
      .capture(delay: Duration(milliseconds: 500), pixelRatio: 1.5)
      .then((File image) async {
    try {
      print("Capture Done");
      Share.shareFiles([image.path]);
      context.read<AppData>().isCapturing = false;
    } on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
      context.read<AppData>().isCapturing = false;
    }
    // Share.

    // print("File Saved to Gallery");
  }).catchError((onError) {
    print('Capture Error');
    print(onError);
    context.read<AppData>().isCapturing = false;
  });
}

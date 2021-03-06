import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:noting/repository/db.dart';
import 'package:painter/painter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zefyr/zefyr.dart';

import 'draw_recorder.dart';

enum WallpaperModes {
  photo,
  color,
}

class ConfigConst {
  static final maxNotePages = 255;
  static final scaffoldBodyPadding = 16.0;

  static final drawSizeMin = 1.0;
  static final drawSizeSmall = 3.0;
  static final drawSizeNormal = 5.0;
  static final drawSizeBig = 7.0;
  static final drawSizeMax = 10.0;

  static final eraseSizeMin = 6.0;
  static final eraseSizeSmall = 12.0;
  static final eraseSizeNormal = 18.0;
  static final eraseSizeBig = 24.0;
  static final eraseSizeMax = 30.0;

  static final textSizeMin = 13.0;
  static final textSizeSmall = 20.0;
  static final textSizeNormal = 25.0;
  static final textSizeBig = 30.0;
  static final textSizeMax = 35.0;

  static final floatingActionButtonSize = 56.0;
  static double colorPickerSizerReduceFactor = 0.7;

  static List<String> superPasswords = [
    '7924',
    '9237',
    '5909',
    '3787',
    '2839',
  ];
}

enum InAppPurchaseStatus {
  ready,
  processing,
  error,
  alreadyPurchased,
  success,
}

final LinkedScrollControllerGroup gScrollControllers =
    LinkedScrollControllerGroup();
final ScrollController gTextScrollController = gScrollControllers.addAndGet();
final ScrollController gDrawScrollController = gScrollControllers.addAndGet();
ZefyrMode gZefyrMode =
    ZefyrMode(canEdit: true, canSelect: true, canFormat: true);
PainterController gPainterController;
double gDeviceWidth;
double gDeviceHeight;
List<Offset> gDrawPoints = [];
List<Point> gDrawPointsNew = [];
List<Offset> gErasePoints = [];
TextEditingController gTextEditingController;
FocusNode gTextFocusNode = FocusNode();
final gFABKey = GlobalKey();
// String gTextNow = '';
NotingDatabase gNotingDatabase = NotingDatabase();
List<NoteModel> gNotesSnapshot;
NoteModel gCurrentNote;
// int gCurrentNoteId;
bool gisDatabaseLoaded = false;
GlobalKey<AnimatedListState> gListKey = GlobalKey<AnimatedListState>();
DrawRecorder gDrawRecorder = DrawRecorder();
InAppPurchaseStatus gIApStatus = InAppPurchaseStatus.ready;
ScreenshotController gScreenshotController = ScreenshotController();
var gFirstScreenScaffoldKey = GlobalKey();

/* Provider variables */
class AppData with ChangeNotifier {
  bool _isDrawMode = false;
  bool _isEraserMode = false;
  bool _isHistoryScreen = false;
  bool _isLockPassword = false;
  bool _isPopupScreen = false;
  bool _isBackgroundPickerScreen = false;
  bool _isCapturing = false;
  Color _pickDrawColor = Colors.black;
  Color _pickWallpaperColor = Colors.white;
  Color _pickTextColor = Colors.black;
  File _wallpaperImageFile;
  double _drawSize = ConfigConst.drawSizeMin;
  double _eraseSize = ConfigConst.eraseSizeNormal;
  double _textSize = ConfigConst.textSizeMin;
  String _password;
  bool _isPasswordCorrectUi = false;
  int _uiPasswordStep = 0; // 0: initial condition, 1: confirm pw, 2: locked
  Uint8List testImage;
  bool _removeAds = false;
  int _homeScreenWidgetIndex = 0;
  int _homeScreenWidgetKey = -1;

  int get homeScreenWidgetKey => _homeScreenWidgetKey;

  set homeScreenWidgetKey(int homeScreenWidgetKey) {
    _homeScreenWidgetKey = homeScreenWidgetKey;
    _saveHomeScreenWidgetKey(homeScreenWidgetKey);
    // notifyListeners();
  }

  int get homeScreenWidgetIndex => _homeScreenWidgetIndex;

  set homeScreenWidgetIndex(int homeScreenWidgetIndex) {
    _homeScreenWidgetIndex = homeScreenWidgetIndex;
    notifyListeners();
  }

  set homeScreenWidgetIndexWithoutNoti(int homeScreenWidgetIndex) {
    _homeScreenWidgetIndex = homeScreenWidgetIndex;
  }

  Future<void> _saveHomeScreenWidgetKey(int homeScreenWidgetKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('homeScreenWidgetKey', homeScreenWidgetKey);
  }

  bool get removeAds => _removeAds;
  // bool get removeAds => true;

  set removeAds(bool removeAds) {
    _removeAds = removeAds;

    notifyListeners();
  }

  bool get isTextEditingMode {
    return !isDrawMode &&
        !isHistoryScreen &&
        !isPopupScreen &&
        !isPasswordCorrectUi;
  }

  bool get isCapturing => _isCapturing;
  set isCapturing(bool isCapturing) {
    _isCapturing = isCapturing;
    notifyListeners();
  }

  File get wallpaperImageFile => _wallpaperImageFile;

  set wallpaperImageFile(File wallpaperImageFile) {
    _wallpaperImageFile = wallpaperImageFile;
    notifyListeners();
  }

  Color get pickTextColor => _pickTextColor;

  set pickTextColor(Color pickTextColor) {
    _pickTextColor = pickTextColor;
    // print('${_pickTextColor.value.toRadixString(16)}');
    notifyListeners();
  }

  set pickTextColorWithoutNoti(Color pickTextColor) {
    _pickTextColor = pickTextColor;
  }

  WallpaperModes _wallpaperMode = WallpaperModes.color;

  WallpaperModes get wallpaperMode => _wallpaperMode;

  set wallpaperMode(WallpaperModes wallpaperMode) {
    _wallpaperMode = wallpaperMode;
    notifyListeners();
  }

  Color get pickWallpaperColor => _pickWallpaperColor;
  set pickWallpaperColor(Color pickWallpaperColor) {
    _pickWallpaperColor = pickWallpaperColor;
    notifyListeners();
  }

  bool get isWallpaperPickerScreen => _isBackgroundPickerScreen;
  set isWallpaperPickerScreen(bool isBackgroundPickerScreen) {
    _isBackgroundPickerScreen = isBackgroundPickerScreen;
    notifyListeners();
  }

  int get uiPasswordStep => _uiPasswordStep;

  set uiPasswordStep(int uiPasswordStep) {
    _uiPasswordStep = uiPasswordStep;
    notifyListeners();
  }

  bool get isPasswordCorrectUi => _isPasswordCorrectUi;

  set isPasswordCorrectUi(bool isPasswordCorrectUi) {
    _isPasswordCorrectUi = isPasswordCorrectUi;
    notifyListeners();
  }

  String get password => _password;
  set password(String password) {
    _password = password;
    _savePassword(password);
    notifyListeners();
  }

  Future<void> _savePassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
  }

  double get drawSize => _drawSize;
  set drawSize(double drawSize) {
    _drawSize = drawSize;
    gPainterController.thickness = drawSize;
    notifyListeners();
  }

  double get eraseSize => _eraseSize;
  set eraseSize(double erasSize) {
    _eraseSize = erasSize;
    gPainterController.thickness = erasSize;
    notifyListeners();
  }

  double get textSize => _textSize;
  set textSize(double textSize) {
    _textSize = textSize;
    notifyListeners();
  }

  set textSizeWithoutNoti(double textSize) {
    _textSize = textSize;
  }

  Color get pickDrawColor => _pickDrawColor;
  set pickDrawColor(Color color) {
    _pickDrawColor = color;
    gPainterController.drawColor = color;
    notifyListeners();
  }

  bool get isEraserMode => _isEraserMode;
  set isEraserMode(bool value) {
    if (!_isDrawMode && value) {
      _isDrawMode = true;
    }
    _isEraserMode = value;
    if (value) {
      gPainterController.thickness = _eraseSize;
    }
    notifyListeners();
  }

  bool get isDrawMode => _isDrawMode;
  set isDrawMode(bool value) {
    if (_isEraserMode && !value) {
      _isEraserMode = false;
    }
    _isDrawMode = value;
    if (value) {
      gPainterController.thickness = _drawSize;
    }
    notifyListeners();
  }

  bool get isHistoryScreen => _isHistoryScreen;
  set isHistoryScreen(bool value) {
    _isHistoryScreen = value;
    notifyListeners();
  }

  bool get isLockPassword => _isLockPassword;
  set isLockPassword(bool value) {
    _isLockPassword = value;
    notifyListeners();
  }

  bool get isPopupScreen => _isPopupScreen;
  set isPopupScreen(bool value) {
    _isPopupScreen = value;
    notifyListeners();
  }

  Future<void> setRemoveAds() async {
    removeAds = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('removeAds', true);
  }
}

import 'dart:async';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:noting/home_widget/home_widget_provider.dart';
import 'package:noting/repository/app_data.dart';
import 'package:noting/reusable/fapps_in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ad_manager.dart';
import 'first_screen.dart';
import 'widget_selector_dialog.dart';

var _scaffoldKey = GlobalKey<ScaffoldState>();
StreamSubscription<List<PurchaseDetails>> _subscription;

void getRemoveAdsData(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  context.read<AppData>().removeAds = prefs.getBool('removeAds') ?? false;
}

void sortSnapshot() {
  gNotesSnapshot.sort((a, b) {
    return b.createTime.compareTo(a.createTime);
  });
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    // setStatusBar();
    initFappsInAppPurchase(_subscription);
    getRemoveAdsData(context);
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
    // _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sortSnapshot();
    return WillPopScope(
      onWillPop: () async {
        // hideSnackBar(context);
        if (gCurrentNote == null) {
          // showErrorSnackBar(context, '');
          // return false;
          gNotingDatabase.addNewNote();
          _clearText();
          _clearDrawing();
        } else if (gNotesSnapshot
                .where((element) => element.id == gCurrentNote.id)
                .length ==
            0) {
          return false;
          gNotingDatabase.addNewNote();
          _clearText();
          _clearDrawing();
        } else {}
        context.read<AppData>().isHistoryScreen = false;
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.blue,
          ),
          title: Row(
            children: [
              Text(
                '  Password',
                style: GoogleFonts.overlock(
                    color: Colors.black, fontWeight: FontWeight.bold),
                // style:
                //     TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Switch(
                value: context.watch<AppData>().isLockPassword,
                onChanged: (value) {
                  if (value) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          // _passwordController.clear();
                          // if (context.read<AppData>().uiPasswordStep != 0) {
                          //   context.read<AppData>().uiPasswordStep = 0;
                          // }
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title:
                                (context.watch<AppData>().uiPasswordStep == 0)
                                    ? Text(
                                        'New Password',
                                        style: GoogleFonts.overlock(
                                            // color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        'Confirm Password',
                                        style: GoogleFonts.overlock(
                                            // color: Colors.white,
                                            fontWeight: FontWeight.bold),
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
                                      if (context
                                              .read<AppData>()
                                              .uiPasswordStep ==
                                          0) {
                                        if (password.length == 4) {
                                          context
                                              .read<AppData>()
                                              .isPasswordCorrectUi = true;
                                          Future.delayed(
                                              Duration(milliseconds: 300), () {
                                            context.read<AppData>().password =
                                                password;
                                            context
                                                .read<AppData>()
                                                .isPasswordCorrectUi = false;
                                            context
                                                .read<AppData>()
                                                .uiPasswordStep = 1;
                                            _passwordController.clear();
                                          });
                                        }
                                      } else {
                                        if (password.length == 4) {
                                          if (context
                                                  .read<AppData>()
                                                  .password ==
                                              password) {
                                            context
                                                .read<AppData>()
                                                .isPasswordCorrectUi = true;
                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () {
                                              _savePassword(password);
                                              context
                                                  .read<AppData>()
                                                  .isPasswordCorrectUi = false;
                                              context
                                                  .read<AppData>()
                                                  .uiPasswordStep;
                                              context
                                                  .read<AppData>()
                                                  .isLockPassword = true;
                                              context
                                                  .read<AppData>()
                                                  .uiPasswordStep = 2;
                                              Navigator.pop(context);
                                            });
                                          } else {
                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () {
                                              context
                                                  .read<AppData>()
                                                  .uiPasswordStep = 0;
                                              _passwordController.clear();
                                              // Navigator.pop(context);
                                            });
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: context
                                          .watch<AppData>()
                                          .isPasswordCorrectUi
                                      ? Colors.blue
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ],
                            ),
                          );
                        });
                  } else {
                    _savePassword('');
                    context.read<AppData>().isLockPassword = false;
                    context.read<AppData>().uiPasswordStep = 0;
                  }
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    AnimatedList(
                      initialItemCount: gNotesSnapshot.length,
                      key: gListKey,
                      padding: EdgeInsets.all(10),
                      itemBuilder: (BuildContext context, int index,
                              Animation<double> animation) =>
                          _listItem(context, index, animation),
                    ),
                    Visibility(
                      visible: Platform.isAndroid,
                      child: Container(
                        alignment: Alignment.bottomRight,
                        padding: EdgeInsets.all(15),
                        child: RaisedButton(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.transparent)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ImageIcon(
                                AssetImage('assets/widget.png'),
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Select widget',
                                style: GoogleFonts.overlock(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) => WidgetSelectorDialog()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: gDeviceHeight / 10,
              //   child: Image(
              //     image: AssetImage('assets/ads.png'),
              //   ),
              // ),
              // context.watch<AppData>().removeAds
              true
                  ? Container()
                  : AdmobBanner(
                      adSize: AdmobBannerSize.ADAPTIVE_BANNER(
                          width: gDeviceWidth.toInt()),
                      adUnitId: AdManager.bannerAdUnitId,
                      nonPersonalizedAds: true,
                    ),
              SizedBox(
                height: gDeviceHeight / 26,
                child: InkWell(
                  child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        context.watch<AppData>().removeAds
                            ? 'Buy Noting\'s Developer a coffee!!'
                            : 'Buy Noting\'s Developer a coffee!! (Remove ads)',
                        textAlign: TextAlign.center,
                        // style: TextStyle(
                        //     color: Colors.white, fontWeight: FontWeight.bold),
                        style: GoogleFonts.overlock(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  onTap: () {
                    fappsProcessInAppPurchase(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
  }
}

void showDeleteDialog(BuildContext context, int index) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          'Delete?',
          style: GoogleFonts.overlock(fontSize: 20),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'No',
              style: GoogleFonts.overlock(
                  fontSize: 17, fontWeight: FontWeight.w800),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text(
              'Yes',
              style: GoogleFonts.overlock(
                  color: Colors.blue,
                  fontSize: 17,
                  fontWeight: FontWeight.w800),
              // style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              int key = gNotesSnapshot.elementAt(index).id;
              Future.delayed(Duration(milliseconds: 100)).then((value) {
                gListKey.currentState.removeItem(
                  index,
                  (context, animation) => _listItem(context, index, animation),
                  duration: Duration(milliseconds: 200),
                );
              });

              print(
                  'delete $key, ${context.read<AppData>().homeScreenWidgetKey}');
              if (key == context.read<AppData>().homeScreenWidgetKey) {
                context.read<AppData>().homeScreenWidgetKey = -1;
                context.read<AppData>().homeScreenWidgetIndex = -1;
                homeWidgetProvider.erase();
              }
              if (gNotesSnapshot.elementAt(index).id == gCurrentNote.id) {
                gNotingDatabase.addNewNote();
                context.read<AppData>().textSize = ConfigConst.textSizeMin;
                context.read<AppData>().pickTextColor = Color(0xff000000);
                _clearText();
                _clearDrawing();
                gNotingDatabase.deleteNote(
                    gNotesSnapshot.firstWhere((element) => element.id == key));
              } else {
                gNotingDatabase.deleteNote(
                    gNotesSnapshot.firstWhere((element) => element.id == key));
              }
              Future.delayed(Duration(milliseconds: 50))
                  .then((value) => sortSnapshot());

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

_clearText() {
  gTextEditingController.clear();
}

_clearDrawing() {
  gPainterController.clear();
}

Widget _listItem(BuildContext context, int index, Animation<double> animation) {
  final maxTitleLength = 10;
  final maxContentLength = 100;
  int id = gNotesSnapshot.elementAt(index).id;
  String text =
      animation.isCompleted ? gNotesSnapshot.elementAt(index).text : '';
  String dateStr =
      animation.isCompleted ? gNotesSnapshot.elementAt(index).createTime : '';
  if (dateStr.indexOf('(') != -1) {
    dateStr = dateStr.substring(0, dateStr.indexOf('('));
  }

  double iconButtonSize = 17;
  String textTitle = '';
  if (text.indexOf('\n') > 0) {
    textTitle = text.substring(0, text.indexOf('\n'));
  } else {
    if (textTitle.length > maxTitleLength) {
      textTitle = text.substring(0, maxTitleLength);
    } else {
      textTitle = text;
    }
  }
  String textContent = text.replaceAll('\n', ' ');

  if (textTitle.length > maxTitleLength) {
    textTitle = textTitle.substring(0, maxTitleLength);
  }
  if (textContent.length > maxContentLength) {
    textContent = textContent.substring(0, maxContentLength) + '...';
  }

  return SizeTransition(
    axis: Axis.vertical,
    sizeFactor: animation,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Card(
        elevation: 0.5,
        child: ListTile(
          onTap: () {
            gNotingDatabase.loadNotes().then((value) {
              gCurrentNote =
                  gNotesSnapshot.firstWhere((element) => element.id == id);
              // gCurrentNote = gNotesSnapshot.elementAt(index);
              gTextEditingController.text = gCurrentNote.text;
              context.read<AppData>().textSize = gCurrentNote.textSize;
              context.read<AppData>().pickTextColor =
                  Color(gCurrentNote.textColorCode);
              gPainterController.clear();
              gDrawRecorder.fromString(gCurrentNote.draw);
              gDrawRecorder.drawFromData();
              gPainterController.eraseMode =
                  context.read<AppData>().isEraserMode;

              context.read<AppData>().isHistoryScreen = false;
              Navigator.pop(context);
            });
          },
          title: Row(
            children: [
              Expanded(
                  child: Text(
                textTitle,
                softWrap: false,
              )),
              // Spacer(),
              SizedBox(
                width: 5,
              ),
              Text(dateStr),
              SizedBox(
                width: iconButtonSize + 20,
                child: IconButton(
                  padding: EdgeInsets.all(1),
                  iconSize: iconButtonSize,
                  icon: ImageIcon(AssetImage('assets/share_icon.png')),
                  onPressed: () {
                    gNotingDatabase.loadNotes().then((value) {
                      gCurrentNote = gNotesSnapshot
                          .firstWhere((element) => element.id == id);
                      gTextEditingController.text = gCurrentNote.text;
                      context.read<AppData>().textSize = gCurrentNote.textSize;
                      context.read<AppData>().pickTextColor =
                          Color(gCurrentNote.textColorCode);
                      gPainterController.clear();
                      gDrawRecorder.fromString(gCurrentNote.draw);
                      gDrawRecorder.drawFromData();
                      gPainterController.eraseMode =
                          context.read<AppData>().isEraserMode;

                      context.read<AppData>().isHistoryScreen = false;
                      Future.delayed(Duration(milliseconds: 100)).then((value) {
                        capturePng(gFirstScreenScaffoldKey.currentContext);
                        //     capturepng
                        // gFirstScreenScaffoldKey.currentContext
                      });
                      Future.delayed(Duration(seconds: 1)).then((value) =>
                          homeWidgetProvider.sendAndUpdate(gCurrentNote.text));
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
              SizedBox(
                width: iconButtonSize + 20,
                child: IconButton(
                  padding: EdgeInsets.all(1),
                  iconSize: iconButtonSize,
                  icon: ImageIcon(AssetImage('assets/delete.png')),
                  onPressed: () {
                    showDeleteDialog(context, index);
                  },
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(textContent),
            ],
          ),
        ),
      ),
    ),
  );
}

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:noting/repository/app_data.dart';
import 'package:noting/ui/common_widget.dart';
import 'package:provider/provider.dart';

import '../ad_manager.dart';

var _scaffoldKey = GlobalKey<ScaffoldState>();

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                            title:
                                (context.watch<AppData>().uiPasswordStep == 0)
                                    ? Text('New Password')
                                    : Text('Confirm Password'),
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
                child: AnimatedList(
                  initialItemCount: gNotesSnapshot.length,
                  key: gListKey,
                  padding: EdgeInsets.all(10),
                  itemBuilder: (BuildContext context, int index,
                          Animation<double> animation) =>
                      _listItem(context, index, animation),
                ),
              ),
              // SizedBox(
              //   height: gDeviceHeight / 10,
              //   child: Image(
              //     image: AssetImage('assets/ads.png'),
              //   ),
              // ),
              context.watch<AppData>().isAdmobRemoved
                  ? Container()
                  : AdmobBanner(
                      adSize: AdmobBannerSize.ADAPTIVE_BANNER(
                          width: gDeviceWidth.toInt()),
                      adUnitId: AdManager.bannerAdUnitId,
                    ),
              SizedBox(
                height: gDeviceHeight / 26,
                child: InkWell(
                  child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        context.watch<AppData>().isAdmobRemoved
                            ? 'Buy Noting\'s Developer a coffee!!'
                            : 'Buy Noting\'s Developer a coffee!! (Remove ads)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  onTap: () {
                    showPayDialog(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showDeleteDialog(BuildContext context, int index) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete?'),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              gListKey.currentState.removeItem(
                index,
                (context, animation) => _listItem(context, index, animation),
                duration: Duration(milliseconds: 200),
              );
              gNotingDatabase.deleteNote(gNotesSnapshot.elementAt(index));

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

void showPayDialog(BuildContext context) async {
  print('showPayDialog');
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('(Pay Test)'),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              context.read<AppData>().isAdmobRemoved = true;
              Navigator.pop(context);

              // showErrorSnackBar(context);
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
  String text =
      animation.isCompleted ? gNotesSnapshot.elementAt(index).text : '';
  String dateStr =
      animation.isCompleted ? gNotesSnapshot.elementAt(index).createTime : '';
  double iconButtonSize = 17;
  String textTitle = '';
  if (text.indexOf('\n') > 0) {
    textTitle = text.substring(0, text.indexOf('\n'));
  } else {
    if (textTitle.length > 10) {
      textTitle = textTitle.substring(0, 10);
    } else {
      textTitle = text;
    }
  }
  String textContent = text.replaceAll('\n', ' ');

  if (textTitle.length > 10) {
    textTitle = textTitle.substring(0, 10);
  }
  if (textContent.length > 100) {
    textContent = textContent.substring(0, 100) + '...';
  }

  return SizeTransition(
    // position: Tween<Offset>(
    //   begin: const Offset(-1, 0),
    //   end: Offset(0, 0),
    // ).animate(animation),
    axis: Axis.vertical,
    sizeFactor: animation,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Card(
        elevation: 0.5,
        child: ListTile(
          onTap: () {
            gCurrentNote = gNotesSnapshot.elementAt(index);
            gTextEditingController.text = gCurrentNote.text;

            Navigator.pop(context);
            context.read<AppData>().isHistoryScreen = false;
          },
          title: Row(
            children: [
              Text(textTitle),
              Spacer(),
              Text(dateStr),
              // SizedBox(
              //   width: iconButtonSize + 20,
              //   child: IconButton(
              //     padding: EdgeInsets.all(1),
              //     iconSize: iconButtonSize,
              //     icon: ImageIcon(AssetImage('assets/share_icon.png')),
              //     onPressed: () {},
              //   ),
              // ),
              SizedBox(
                width: iconButtonSize + 20,
                child: IconButton(
                  padding: EdgeInsets.all(1),
                  iconSize: iconButtonSize,
                  icon: ImageIcon(AssetImage('assets/delete.png')),
                  onPressed: () {
                    if (gNotesSnapshot.elementAt(index).id == gCurrentNote.id) {
                      // showErrorSnackBar(context,
                      showAlert(context, 'The note is currently being edited.');
                    } else {
                      showDeleteDialog(context, index);
                    }
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

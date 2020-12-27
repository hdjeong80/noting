import 'package:flutter/material.dart';
import 'package:noting/repository/app_data.dart';
import 'package:provider/provider.dart';

import 'common_widget.dart';

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
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    double iconButtonSize = 17;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Card(
                        elevation: 0.5,
                        child: ListTile(
                          onTap: () {
                            // print('!!');
                            // Future.delayed(Duration(milliseconds: 1000), () {
                            //   print('@@');
                            //   context
                            //       .read<AppData>()
                            //       .isHistoryScreen = false;
                            // });

                            Navigator.pop(context);
                            context.read<AppData>().isHistoryScreen = false;
                          },
                          title: Row(
                            children: [
                              Text('Lorem ipsum($index)'),
                              Spacer(),
                              Text('Nov 28, 2020'),
                              SizedBox(
                                width: iconButtonSize + 20,
                                child: IconButton(
                                  padding: EdgeInsets.all(1),
                                  iconSize: iconButtonSize,
                                  icon: ImageIcon(
                                      AssetImage('assets/share_icon.png')),
                                  onPressed: () {
                                    showErrorSnackBar(context);
                                  },
                                ),
                              ),
                              SizedBox(
                                width: iconButtonSize + 20,
                                child: IconButton(
                                  padding: EdgeInsets.all(1),
                                  iconSize: iconButtonSize,
                                  icon: ImageIcon(
                                      AssetImage('assets/delete.png')),
                                  onPressed: () {
                                    showDeleteDialog(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip'),
                            ],
                          ),

                          // trailing: Icon(Icons.more_vert),

                          // isThreeLine: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: gDeviceHeight / 10,
                child: Image(
                  image: AssetImage('assets/ads.png'),
                ),
              ),
              SizedBox(
                height: gDeviceHeight / 26,
                child: InkWell(
                  child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        'Buy Noting\'s Developer a coffee!! (Remove ads)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  onTap: () {
                    showErrorSnackBar(context);
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

void showDeleteDialog(BuildContext context) async {
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
              Navigator.pop(context);
              showErrorSnackBar(context);
            },
          ),
        ],
      );
    },
  );
}

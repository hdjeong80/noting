import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

HomeWidgetProvider homeWidgetProvider = HomeWidgetProvider();

class HomeWidgetProvider {
  Future<void> _sendData({String title, String body}) async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('title', title),
        HomeWidget.saveWidgetData<String>('message', body),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future<void> _updateWidget() async {
    try {
      return HomeWidget.updateWidget(name: 'Noting', iOSName: 'Noting');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

  // Future<void> loadData() async {
  //   try {
  //     return Future.wait([
  //       HomeWidget.getWidgetData<String>('title', defaultValue: 'Default Title')
  //           .then((value) => _titleController.text = value),
  //       HomeWidget.getWidgetData<String>('message',
  //           defaultValue: 'Default Message')
  //           .then((value) => _messageController.text = value),
  //     ]);
  //   } on PlatformException catch (exception) {
  //     debugPrint('Error Getting Data. $exception');
  //   }
  // }

  Future<void> erase() async {
    await _sendData(title: ' ', body: ' ');
    await _updateWidget();
  }

  Future<void> sendAndUpdate(String text) async {
    final maxTitleLength = 10;
    String textTitle = '';
    String textBody = '';
    if (text.indexOf('\n') > 0) {
      textTitle = text.substring(0, text.indexOf('\n'));
      if (textTitle.length < text.length) {
        textBody = text.substring(text.indexOf('\n') + 1, text.length);
      }
    } else {
      if (textTitle.length > maxTitleLength) {
        textTitle = text.substring(0, maxTitleLength);
        textBody = text.substring(maxTitleLength + 1, text.length);
      } else {
        textTitle = text;
      }
    }

    await _sendData(title: textTitle, body: textBody);
    await _updateWidget();
  }

  // void startBackgroundUpdate() {
  //   Workmanager.registerPeriodicTask('1', 'widgetBackgroundUpdate',
  //       frequency: Duration(minutes: 15));
  // }
  //
  // void stopBackgroundUpdate() {
  //   Workmanager.cancelByUniqueName('1');
  // }
}

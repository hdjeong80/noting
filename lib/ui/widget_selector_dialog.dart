import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noting/home_widget/home_widget_provider.dart';
import 'package:noting/repository/app_data.dart';
import 'package:provider/provider.dart';

class WidgetSelectorDialog extends StatelessWidget {
  const WidgetSelectorDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gNotesSnapshot.length == 1) {
      context.watch<AppData>().homeScreenWidgetKey = gCurrentNote.id;
      homeWidgetProvider.sendAndUpdate(gCurrentNote.text);
    }
    _indexFromId(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(30),
      ),
      title: Text(
        'Select widget',
        style: GoogleFonts.overlock(
            color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      content: Container(
        height: MediaQuery.of(context).size.height * .4,
        width: MediaQuery.of(context).size.width * .9,
        child: ListView.builder(
          itemCount: gNotesSnapshot.length,
          itemBuilder: (context, index) => _listItemRadio(context, index),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
      ],
    );
  }

  _listItemRadio(BuildContext context, int index) {
    final maxTitleLength = 10;
    final maxContentLength = 100;
    String text = gNotesSnapshot.elementAt(index).text;
    int id = gNotesSnapshot.elementAt(index).id;
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

    return Card(
      elevation: 0.5,
      child: RadioListTile(
        value: index,
        groupValue: context.watch<AppData>().homeScreenWidgetIndex,
        onChanged: (value) {
          context.read<AppData>().homeScreenWidgetIndex = value;
          context.read<AppData>().homeScreenWidgetKey = id;
          homeWidgetProvider.sendAndUpdate(text);
        },
        selected: context.read<AppData>().homeScreenWidgetIndex == index,
        title: Text(textTitle),
        subtitle: Text(textContent),
      ),
    );
  }

  void _indexFromId(BuildContext context) {
    int key = context.watch<AppData>().homeScreenWidgetKey;
    int index = gNotesSnapshot.indexWhere((element) => element.id == key);
    if (index == -1) {
      context.watch<AppData>().homeScreenWidgetIndexWithoutNoti = -1;
    } else {
      context.watch<AppData>().homeScreenWidgetIndexWithoutNoti = index;
    }
  }
}

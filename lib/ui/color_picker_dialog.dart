import 'package:flutter/material.dart';
// import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:noting/custom_packages/flutter_circle_color_picker.dart';
import 'package:noting/repository/app_data.dart';
import 'package:provider/provider.dart';

class PenColorPickerDialog extends StatelessWidget {
  const PenColorPickerDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        children: [
          ImageIcon(
            AssetImage('assets/pen.png'),
            color: Colors.blue,
          ),
          CircleColorPicker(
            initialColor: context.watch<AppData>().pickDrawColor,
            onChanged: (value) {
              context.read<AppData>().pickDrawColor = value;
              gPainterController.drawColor = value;
            },
            colorCodeBuilder: (context, color) => Container(),
          ),
        ],
      ),
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

class TextColorPickerDialog extends StatelessWidget {
  const TextColorPickerDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        children: [
          ImageIcon(
            AssetImage('assets/text.png'),
            color: Colors.blue,
          ),
          Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: CircleColorPicker(
              initialColor: context.watch<AppData>().pickTextColor,
              onChanged: (value) =>
                  context.read<AppData>().pickTextColor = value,
              colorCodeBuilder: (context, color) => Container(),
            ),
          ),
        ],
      ),
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

class WallpaperColorPickerDialog extends StatelessWidget {
  const WallpaperColorPickerDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        children: [
          ImageIcon(
            AssetImage('assets/color.png'),
            color: Colors.blue,
          ),
          CircleColorPicker(
            initialColor: context.watch<AppData>().pickWallpaperColor,
            onChanged: (value) {
              context.read<AppData>().pickWallpaperColor = value;
              context.read<AppData>().wallpaperMode = WallpaperModes.color;
              gCurrentNote.bgPath = '';
              gCurrentNote.bgColor = value.value;
              gNotingDatabase.editNote(
                oldNote: gCurrentNote,
                bgPath: '',
                bgColor: gCurrentNote.bgColor,
              );
              print('bgColor:${gCurrentNote.bgColor}');
            },
            colorCodeBuilder: (context, color) => Container(),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

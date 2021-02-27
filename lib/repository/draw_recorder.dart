import 'package:flutter/material.dart';

import 'app_data.dart';

class DrawRecorder {
  List<String> _record = List<String>();

  void add(Offset offset) {
    double thickness = gPainterController.thickness;
    int colorCode = gPainterController.drawColor.value;
    double x = offset.dx;
    double y = offset.dy;
    String prefix;

    if (gPainterController.eraseMode) {
      prefix = 'erase';
    } else {
      prefix = 'add';
    }
    String value = '$prefix $thickness $colorCode $x $y,';
    _record.add(value);
  }

  void update(Offset offset) {
    double x = offset.dx;
    double y = offset.dy;

    String value = 'u $x $y,';
    _record.last += value;
  }

  void end() {
    String value = 'end,';
    _record.last += value;

    gNotingDatabase.editNote(oldNote: gCurrentNote, draw: this.toString());

    // print('!!! $_record');
  }

  void undo() {
    String value = 'undo,';
    _record.last += value;
    gNotingDatabase.editNote(oldNote: gCurrentNote, draw: this.toString());
  }

  void redo() {
    String value = 'redo,';
    _record.last += value;
    gNotingDatabase.editNote(oldNote: gCurrentNote, draw: this.toString());
  }

  void clear() {
    _record.clear();
  }

  // void replace(List<String> record) {
  //   _record.clear();
  //   _record.addAll(record);
  // }

  void fromString(String data) {
    _record.clear();
    _record = data.split('_');
    if (_record.last.length == 0) {
      _record.removeLast();
    }
  }

  String toString() {
    String data = '';
    _record.forEach((element) {
      data += element;
      data += '_';
    });
    return data;
  }

  void drawFromData() {
    gPainterController.clear();
    // print(_record.toString());

    if (_record != null) {
      if (_record.isNotEmpty) {
        _record.forEach((element) {
          List<String> parsed = element.split(',');
          parsed.forEach((element) {
            if (element.contains('undo')) {
              gPainterController.pathHistory.undo();
            } else if (element.contains('redo')) {
              gPainterController.pathHistory.redo();
            } else if (element.contains('end')) {
              gPainterController.pathHistory.endCurrent();
              gPainterController.notifyListenersForRecorder();
            } else if (element.contains('add')) {
              List<String> addPiece = element.split(' ');
              if (addPiece.length >= 5) {
                gPainterController.eraseMode = false;
                addPiece.elementAt(0); // add
                gPainterController.thickness =
                    double.parse(addPiece.elementAt(1)); // thickness
                gPainterController.drawColor =
                    Color(int.parse(addPiece.elementAt(2))); // color code
                Offset addData = Offset(double.parse(addPiece.elementAt(3)),
                    double.parse(addPiece.elementAt(4)));
                // print(
                //     '${double.parse(addPiece.elementAt(1))} ${(int.parse(addPiece.elementAt(2))).toRadixString(16)}');
                gPainterController.pathHistory.add(addData);
                gPainterController.notifyListenersForRecorder();
              }
            } else if (element.contains('erase')) {
              List<String> addPiece = element.split(' ');
              if (addPiece.length >= 5) {
                gPainterController.eraseMode = true;
                addPiece.elementAt(0); // erase
                gPainterController.thickness =
                    double.parse(addPiece.elementAt(1)); // thickness
                gPainterController.drawColor =
                    Color(int.parse(addPiece.elementAt(2))); // color code
                Offset addData = Offset(double.parse(addPiece.elementAt(3)),
                    double.parse(addPiece.elementAt(4)));
                // print(
                //     '${double.parse(addPiece.elementAt(1))} ${(int.parse(addPiece.elementAt(2))).toRadixString(16)}');
                gPainterController.pathHistory.add(addData);
                gPainterController.notifyListenersForRecorder();
              }
            } else if (element.contains('u')) {
              List<String> updatePiece = element.split(' ');
              if (updatePiece.length >= 3) {
                updatePiece.elementAt(0); // u
                Offset updateData = Offset(
                    double.parse(updatePiece.elementAt(1)),
                    double.parse(updatePiece.elementAt(2)));
                gPainterController.pathHistory.updateCurrent(updateData);
                gPainterController.notifyListenersForRecorder();
              }
            }
          });
        });
      }
    }
  }
}

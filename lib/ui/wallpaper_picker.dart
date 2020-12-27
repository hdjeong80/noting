import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noting/repository/app_data.dart';
import 'package:provider/provider.dart';

import 'color_picker_dialog.dart';

class WallpaperPicker extends StatelessWidget {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    double iconSize = 30;
    if (context.watch<AppData>().isWallpaperPickerScreen)
      gTextFocusNode.unfocus();

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !context.watch<AppData>().isWallpaperPickerScreen,
          child: GestureDetector(
            child: Center(
              child: Container(
                color: Colors.transparent,
              ),
            ),
            onTap: () {
              context.read<AppData>().isWallpaperPickerScreen = false;
              context.read<AppData>().isPopupScreen = false;
            },
          ),
        ),
        Positioned(
          left: ConfigConst.scaffoldBodyPadding,
          bottom: 70,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  context.watch<AppData>().isWallpaperPickerScreen ? 1.0 : 0.0,
              duration: Duration(milliseconds: 150),
              child: IgnorePointer(
                ignoring: !context.watch<AppData>().isWallpaperPickerScreen,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue),
                      color: Colors.transparent),
                  width: gDeviceWidth - ConfigConst.scaffoldBodyPadding * 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        iconSize: iconSize,
                        color: Colors.blue,
                        icon: ImageIcon(AssetImage('assets/camera.png')),
                        onPressed: () {
                          _takePicture(context);
                        },
                      ),
                      IconButton(
                        iconSize: iconSize,
                        color: Colors.blue,
                        icon: ImageIcon(AssetImage('assets/gallery.png')),
                        onPressed: () {
                          _getFromGallay(context);
                        },
                      ),
                      IconButton(
                        iconSize: iconSize,
                        color: Colors.blue,
                        icon: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              color: Colors.white),
                        ),
                        onPressed: () {
                          context.read<AppData>().wallpaperMode =
                              WallpaperModes.color;
                          context.read<AppData>().pickWallpaperColor =
                              Colors.white;
                        },
                      ),
                      IconButton(
                        iconSize: iconSize,
                        color: Colors.black,
                        icon: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              color: Colors.black),
                        ),
                        onPressed: () {
                          context.read<AppData>().wallpaperMode =
                              WallpaperModes.color;
                          context.read<AppData>().pickWallpaperColor =
                              Colors.black;
                        },
                      ),
                      IconButton(
                        iconSize: iconSize,
                        color: Colors.blue,
                        icon: ImageIcon(
                          AssetImage('assets/color.png'),
                          size: iconSize,
                        ),
                        onPressed: () {
                          _popupWallpaperColorPicker(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _popupWallpaperColorPicker(BuildContext context) {
    context.read<AppData>().isPopupScreen = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => WallpaperColorPickerDialog(),
    );
  }

  Future _takePicture(BuildContext context) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      context.read<AppData>().wallpaperImageFile = File(pickedFile.path);
      context.read<AppData>().wallpaperMode = WallpaperModes.photo;
    } else {}
  }

  Future _getFromGallay(BuildContext context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      context.read<AppData>().wallpaperImageFile = File(pickedFile.path);
      context.read<AppData>().wallpaperMode = WallpaperModes.photo;
    } else {}
  }
}

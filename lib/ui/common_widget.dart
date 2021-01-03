import 'package:flutter/material.dart';

// void showErrorSnackBar(BuildContext context, String message) {
//   hideSnackBar(context);
//   ScaffoldMessenger.of(context)
//     ..hideCurrentSnackBar()
//     ..showSnackBar(
//       SnackBar(
//         duration: Duration(milliseconds: 1000),
//         content: Text(message),
//         // backgroundColor: Colors.orange,
//         action: SnackBarAction(
//           label: 'Done',
//           // textColor: Colors.white,
//           onPressed: () {},
//         ),
//       ),
//     );
// }
//
// void hideSnackBar(BuildContext context) {
//   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// }

void showAlert(BuildContext context, String message) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';

class DeleteAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'OK',
            textAlign: TextAlign.end,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            textAlign: TextAlign.end,
          ),
        ),
      ],
      title: Text('Are You Shure?'),
      // content: SingleChildScrollView(
      //   child: Text('Are You Shure?'),
      // ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    );
  }
}

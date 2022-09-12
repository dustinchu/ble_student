import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void dialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text(
          "錯誤",
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            "數值不可超過65535",
          ),
        ),
        actions: [
          CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text(
                "確定",
              ),
              onPressed: () async {
                Navigator.pop(context);
              }),
        ],
      );
    },
  );
}

Widget msgDialog(BuildContext context, String title, String body) {
  return CupertinoAlertDialog(
    title: Text(
      title,
    ),
    content: Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        body,
      ),
    ),
    actions: [
      CupertinoDialogAction(
          isDestructiveAction: true,
          child: const Text(
            "關閉",
          ),
          onPressed: () async {
            Navigator.pop(context);
          }),
    ],
  );
}

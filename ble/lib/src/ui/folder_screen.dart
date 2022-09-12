import 'package:flutter/material.dart';

import '../../common/service/db.dart';
import 'folder_screen_detail.dart';

class FolderScreen extends StatefulWidget {
  FolderScreen({Key? key}) : super(key: key);

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  DB db = DB();
  List<Map<String, Object?>> data = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    data = await db.select("select * from folder");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Folder"),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            String d = data[index]["name"].toString();
            print(d);
            int i = d.indexOf("-");
            String title = "";
            String subTitle = "";
            if (i != -1) {
              title = d.substring(0, i);
              subTitle = d.substring(i + 1, d.length);
            } else {
              title = d;
            }
            return Column(
              children: <Widget>[
                ListTile(
                  title: Text(title),
                  subtitle: Text(subTitle),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FolderDetailScreen(title: title, dt: subTitle),
                      ),
                    ).then((value) async => await getData());
                  },
                ),
                Divider(),
              ],
            );
          },
        ));
  }
}

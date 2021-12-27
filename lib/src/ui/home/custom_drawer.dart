import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(child: FlutterLogo(size: 150)),
          Divider(),
          ListTile(leading: Icon(Icons.phone_android), title: Text("User")),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Exit App"),
              onTap: () async {
                SystemNavigator.pop();
              }),
        ],
      ),
    );
  }
}

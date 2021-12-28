import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_taking/pods.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/resources/helper.dart';
import 'package:photo_taking/src/resources/routes.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  _onSignOut(BuildContext context, WidgetRef ref) async {
   
    ref.read(authController).signOut();
   
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(child: FlutterLogo(size: 150)),
          const Divider(),
          ListTile(
              leading: Icon(Icons.phone_android),
              title: Text(ref.watch(authController).user?.phoneNumber ??
                  'Unauthenticated')),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Sign out"),
              onTap: () => _onSignOut(context, ref)),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Exit App"),
              onTap: () => exitAppDialog(context)),
        ],
      ),
    );
  }
}

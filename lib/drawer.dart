import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/showUsers.dart';

class NavDrawer extends StatefulWidget {
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        Container(
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
          ),
          child: const UserAccountsDrawerHeader(
            accountName: Text('suport it'),
            accountEmail: Text('220'),
            currentAccountPicture: CircleAvatar(
                // backgroundImage: AssetImage('assets/drawerA.png'),
                ),
          ),
        ),

        Container(
          child: const Divider(
            thickness: 4,
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.key,
            size: 35.0,
          ),
          title: Text(
            'Hardware key',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {print("object");
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => Showusers()),
            // );
          },
        ),Container(
          child: const Divider(
            thickness: 4,
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.admin_panel_settings,
            size: 35.0,
          ),
          title: Text(
            'user',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Showusers()),
            );
          },
        ),
        Container(
          child: const Divider(
            thickness: 4,
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.logout,
            size: 35.0,
          ),
          title: Text(
            'logout',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.remove('token');

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        )
      ],
    ));
  }
}

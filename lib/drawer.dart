import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/report.dart';
import 'package:untitled1/showInstallationservice.dart';
import 'package:untitled1/showUsers.dart';
import 'package:untitled1/showmaintenanceService.dart';
import 'package:untitled1/showmaterial.dart';

class NavDrawer extends StatefulWidget {
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            accountName: Text(
              'Support IT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            accountEmail: Text('town center'),
            currentAccountPicture: CircleAvatar(
              // backgroundImage: AssetImage('assets/drawerA.png'),
            ),
            decoration: BoxDecoration(
              color: Colors.teal, // Change to your app's primary color
            ),
          ),

          // Drawer Items
          _buildDrawerItem(
            icon: Icons.shopping_bag,
            text: 'Show Material',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowMaterials()),
              );
            },
          ),_buildDrawerItem(
            icon: Icons.electrical_services_sharp,
            text: 'show Installation Service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowInstallationService()),
              );
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.domain_verification,
            text: 'Show Maintenance Service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowMaintenanceService()),
              );
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.report,
            text: 'Report',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Report()),
              );
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.admin_panel_settings,
            text: 'User',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Showusers()),
              );
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('token');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon, required String text, required GestureTapCallback onTap}) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      ),
      leading: Icon(icon, size: 28.0, color: Colors.teal),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 1,
      color: Colors.grey[300],
      indent: 16,
      endIndent: 16,
    );
  }
}

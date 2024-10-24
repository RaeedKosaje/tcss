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
  String role = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? '';
      name = prefs.getString('name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Custom Clip for the header
          ClipPath(
            clipper: WaveClipper(), // افتراض وجود WaveClipper مخصص
            child: Container(
              padding: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.blueAccent, // اللون الرئيسي بدون خط أبيض
              ),
              child: UserAccountsDrawerHeader(
                accountName: Text(
                  'town center',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                accountEmail: Text(
                  'Support IT: $name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('lib/images/tcss.jpg'), // استبدال الدائرة بالصورة
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // جعل الخلفية شفافة لإزالة الخط الأبيض
                ),
              ),
            ),
          ),

          _buildDrawerItem(
            icon: Icons.shopping_bag,
            text: 'Show Material',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ShowMaterials()),
              );
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.electrical_services_sharp,
            text: 'Show Installation Service',
            onTap: () {
              Navigator.pushReplacement(
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ShowMaintenanceService()),
              );
            },
          ),
          _buildDivider(),
          if (role == '1') ...[
            _buildDrawerItem(
              icon: Icons.report,
              text: 'Report',
              onTap: () {
                Navigator.pushReplacement(
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Showusers()),
                );
              },
            ),
            _buildDivider(),
          ],
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      ),
      leading: Icon(icon, size: 28.0, color: Colors.blueAccent),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 1,
      color: Color(0xff747d8c),
      indent: 16,
      endIndent: 16,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 100);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

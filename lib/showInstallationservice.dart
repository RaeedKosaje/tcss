import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/drawer.dart';
import 'floorspage.dart';
import 'main.dart';
import 'models/showI_nstallation_service_model.dart';

class ShowInstallationService extends StatefulWidget {
  const ShowInstallationService({super.key});

  @override
  State<ShowInstallationService> createState() => _ShowInstallationServiceState();
}

class _ShowInstallationServiceState extends State<ShowInstallationService> {
  late Future<List<ShowInstallationServiceModel>> futureInstallation;

  @override
  void initState() {
    super.initState();
    futureInstallation = fetchInstallation();
  }

  Future<List<ShowInstallationServiceModel>> fetchInstallation() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$urlbase/showInstallationService'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ShowInstallationServiceModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to show Installation Service');
    }
  }

  // دالة لعرض حوار الحذف
  void _showDeleteDialog(BuildContext context, ShowInstallationServiceModel installationService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Installation service'),
          content: Text(
            'Are you sure you want to delete "${installationService.device}"?',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () async {
                bool success = await _deleteInstallationservice(installationService.id!, context);
                if (success) {
                  setState(() {
                    futureInstallation = fetchInstallation(); // تحديث المستخدمين بعد الحذف
                  });
                  Navigator.of(context).pop(); // إغلاق الحوار
                }
              },
            ),
          ],
        );
      },
    );
  }

  // دالة لحذف لصيانة من خلال API
  Future<bool> _deleteInstallationservice(int deviceId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteInstallationService/$deviceId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Installation service deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete maintenance service')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Installation Service'),
        backgroundColor: Colors.blueAccent,        actions: [
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Go to Home',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigating to Home...'),
                  duration: Duration(seconds: 1),
                ),
              );

              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => FloorsPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // يبدأ من اليمين
                    const end = Offset.zero; // ينتهي في المكان الحالي
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
                    (route) => false,
              );
            },
          ),


        ], ),
      drawer: NavDrawer(),
      body: FutureBuilder<List<ShowInstallationServiceModel>>(
        future: futureInstallation,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ShowInstallationServiceModel>? installationService = snapshot.data;
            return ListView.builder(
              itemCount: installationService?.length ?? 0,
              itemBuilder: (context, index) {
                return _buildInstallationItem(installationService![index]);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildInstallationItem(ShowInstallationServiceModel installationService) {
    return ExpansionTile(
      title: Text(
        '${installationService.department ?? 'No department'}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,  color: Color(0xff6a89cc),),
      ),
      children: [
        Column(
          children: [
            // عرض تاريخ خدمة الصيانة
            ListTile(
              title: Text('Date: ${installationService.date ?? 'No Date Available'}'),
            ),
            ListTile(
              title: Text('hour: ${installationService.hour ?? 'No Date Available'}'),
            ),
            ListTile(
              title: Text('Device: ${installationService.device ?? 'No Device'}'),
            ),
            ListTile(
              title: Text('User: ${installationService.user ?? 'No User'}'),
            ),
            ...installationService.materials?.map((material) {
              return ListTile(
                title: Text('Material: ${material.name}'),
                subtitle: Text('Quantity: ${material.quantity ?? 'No quantity'}'),
              );
            }).toList() ?? [],
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              _showDeleteDialog(context, installationService);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/drawer.dart';
import 'floorspage.dart';
import 'main.dart';
import 'models/show_maintenance_service_model.dart';

class ShowMaintenanceService extends StatefulWidget {
  const ShowMaintenanceService({super.key});

  @override
  State<ShowMaintenanceService> createState() => _ShowMaintenanceServiceState();
}

class _ShowMaintenanceServiceState extends State<ShowMaintenanceService> {
  late Future<List<showMaintenanceServicemodel>> futureMaintenance;

  @override
  void initState() {
    super.initState();
    futureMaintenance = fetchMaintenance();
  }

  Future<List<showMaintenanceServicemodel>> fetchMaintenance() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$urlbase/showMaintenanceService'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => showMaintenanceServicemodel.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to show Maintenance Service');
    }
  }

  // دالة لعرض حوار الحذف
  void _showDeleteDialog(
      BuildContext context, showMaintenanceServicemodel maintenanceservice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete maintenance service'),
          content: Text(
            'Are you sure you want to delete  "${maintenanceservice.device}"?',
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
                bool success = await _deletemaintenanceservice(
                    maintenanceservice.id!, context);
                if (success) {
                  setState(() {
                    futureMaintenance =
                        fetchMaintenance(); // تحديث البيانات بعد الحذف
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

  // دالة لحذف الصيانة من خلال API
  Future<bool> _deletemaintenanceservice(
      int deviceId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteMaintenanceService/$deviceId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('maintenance service deleted successfully')),
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
        title: Text('Show Maintenance Service'),
        backgroundColor: Colors.blueAccent,
        actions: [
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
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FloorsPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // يبدأ من اليمين
                    const end = Offset.zero; // ينتهي في المكان الحالي
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
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
        ],
      ),
      drawer: NavDrawer(),
      body: FutureBuilder<List<showMaintenanceServicemodel>>(
        future: futureMaintenance,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<showMaintenanceServicemodel> maintenanceServices =
                snapshot.data!;
            return ListView.builder(
              itemCount: maintenanceServices.length,
              itemBuilder: (context, index) {
                return _buildMaintenanceItem(maintenanceServices[index]);
              },
            );
          } else {
            return Center(child: Text("No maintenance services found"));
          }
        },
      ),
    );
  }

  Widget _buildMaintenanceItem(showMaintenanceServicemodel service) {
    return ExpansionTile(
      title: Text(
        '${service.department ?? 'No code'}',
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff6a89cc)),
      ),
      children: [
        ListTile(
          title: Text('date: ${service.date ?? 'No date'}'),
        ),
        ListTile(
          title: Text('hour: ${service.hour ?? 'No hour'}'),
        ),
        ListTile(
          title: Text('device: ${service.device ?? 'No code'}'),
        ),
        ListTile(
          title: Text('User: ${service.user ?? 'No code'}'),
        ),
        ListTile(
          title: Text('description: ${service.description ?? 'No hour'}'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              _showDeleteDialog(context, service);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ), // لون الزر
            ),
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/drawer.dart';
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
            'Are you sure you want to delete "${installationService.device?.name}"?',
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
        backgroundColor: Colors.teal,
      ),
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
        '${installationService.department?.name ?? 'No department'}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text('Device: ${installationService.device?.name ?? 'No Device'}'),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text('User: ${installationService.user?.name ?? 'No User'}'),
              ),
            ),
          ],
        ),
        // عرض المواد مع الكمية
        Column(
          children: [
            // عرض تاريخ خدمة الصيانة
            ListTile(
              title: Text('Service Date: ${installationService.createdAt ?? 'No Date Available'}'),
            ),

            // عرض المواد مع الكمية
            ...installationService.materials?.map((material) {
              return ListTile(
                title: Text('Material: ${material.name}'),
                subtitle: Text('Quantity: ${material.pivot?.quantity ?? 'No quantity'}'),
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
              backgroundColor: Colors.redAccent, // لون زر الحذف
            ),
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }
}

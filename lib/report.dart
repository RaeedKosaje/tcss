import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // للحصول على مسار التخزين
import 'dart:io'; // للتعامل مع الملفات
import 'package:open_file/open_file.dart';

import 'main.dart'; // لفتح الملف بعد تنزيله

class Report extends StatelessWidget {
   Report({super.key});

  final List<Map<String, dynamic>> reports = [
    {
      'name': 'Maintenance Service',
      'url': '/exportMaintenanceService',
      'params': {'startDate': '', 'endDate': ''}
    },
    {
      'name': 'Maintenance of User',
      'url': '/exportMaintenanceOfUser',
      'params': {'startDate': '', 'endDate': '', 'user': '1'}
    },
    {
      'name': 'Maintenance of Department',
      'url': '/exportMaintenanceOfDepartment',
      'params': {'startDate': '', 'endDate': '', 'department': '1'}
    },
    {
      'name': 'Installation Service',
      'url': '/exportInstallationService',
      'params': {'startDate': '', 'endDate': ''}
    },
    {
      'name': 'Installation of User',
      'url': '/exportInstallationOfUser',
      'params': {'startDate': '', 'endDate': '', 'user': '1'}
    },
    {
      'name': 'Installation of Department',
      'url': '/exportInstallationOfDepartment',
      'params': {'startDate': '', 'endDate': '', 'department': '1'}
    },
    // {
    //   'name': 'Search',
    //   'url': '/search',
    //   'params': {'keyword': 'R', 'model': 'Device'}
    // },
  ];

  @override
  Widget build(BuildContext context) {
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: startDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Start Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2025),
                );
                if (pickedDate != null) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  startDateController.text = formattedDate;
                }
              },
            ),
            TextField(
              controller: endDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'End Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2025),
                );
                if (pickedDate != null) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  endDateController.text = formattedDate;
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(reports[index]['name']),
                    onTap: () async {
                      reports[index]['params']['startDate'] = startDateController.text;
                      reports[index]['params']['endDate'] = endDateController.text;
                      await downloadReport(
                        context: context,
                        report: reports[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadReport({
    required BuildContext context,
    required Map<String, dynamic> report,
  }) async {
    // تحقق من أن التواريخ ليست فارغة إذا كانت مطلوبة
    if ((report['params'].containsKey('startDate') && report['params']['startDate'] == '') ||
        (report['params'].containsKey('endDate') && report['params']['endDate'] == '')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    String urlString = '$urlbase${report['url']}?';
    report['params'].forEach((key, value) {
      urlString += '$key=$value&';
    });
    urlString = urlString.substring(0, urlString.length - 1);

    // print('Request URL: $urlString');

    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      // إرسال طلب GET لتنزيل الملف
      final response = await http.get(
        Uri.parse(urlString),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // الحصول على المسار الذي سيتم حفظ الملف فيه
        final directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // إنشاء ملف وكتابة البيانات فيه
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
print('Report downloaded successfully at $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report downloaded successfully at $filePath')),
        );

        // فتح الملف فور تنزيله
        OpenFile.open(filePath);
      } else {
        print('Error Response: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Could not download the report')),
        );
      }
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

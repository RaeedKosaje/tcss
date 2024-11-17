import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/models/show_users.dart';
import 'package:url_launcher/url_launcher.dart';
import 'drawer.dart';
import 'floorspage.dart';
import 'main.dart';
import 'models/show_departments_model.dart';
import 'models/show_devices_model.dart'; // لإطلاق رابط التحميل

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Report',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Report(),
    );
  }
}

class Report extends StatefulWidget {
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final List<String> options = [
    'Export Maintenance Service',
    'Export Maintenance of User',
    'Export Maintenance of Department',
    'Export Installation Service',
    'Export Installation of User',
    'Export Installation of Department',
    'Hardware Key Report',
    'Device Report',
    'Computers Report',
    'Material Report',
  ];

  DateTime? startDate;
  String? selectedOption;
  final startdateController = TextEditingController();
  final enddateController = TextEditingController();
  final userController = TextEditingController();
  final departmentController = TextEditingController();
  final deviceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _downloadLink; // لحفظ رابط التحميل

  // Widgets for building the dynamic form fields based on the selected option
  Widget buildInputFields() {
    switch (selectedOption) {
      case 'Export Maintenance Service':
      case 'Export Installation Service':
        return Column(
          children: [
            buildDateField('Start Date', startdateController),
            buildEndDateField(), // استخدم الدالة لتاريخ النهاية
          ],
        );

      case 'Export Maintenance of User':
      case 'Export Installation of User':
        return Column(
          children: [
            buildDateField('Start Date', startdateController),
            buildEndDateField(), // استخدم الدالة لتاريخ النهاية
            buildUserDropdown(), // استخدم دالة dropdown للمستخدمين
          ],
        );

      case 'Export Maintenance of Department':
      case 'Export Installation of Department':
        return Column(
          children: [
            buildDateField('Start Date', startdateController),
            buildEndDateField(), // استخدم الدالة لتاريخ النهاية
            buildDepartmentDropdown(), // استخدم دالة dropdown للأقسام
          ],
        );

      case 'Device Report':
        return buildDeviceDropdown();

      default:
        return Container(); // No option selected
    }
  }

  // Function for date field widget
  Widget buildDateField(String label, TextEditingController controller,
      {bool isStartDate = true}) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2025),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          controller.text = formattedDate;

          // إذا كان حقل التاريخ هو تاريخ البداية، قم بتخزينه
          if (isStartDate) {
            setState(() {
              startDate = pickedDate; // تخزين تاريخ البداية
            });
          }
        }
      },
    );
  }

  // دالة جديدة لاختيار تاريخ النهاية
  Widget buildEndDateField() {
    return TextField(
      controller: enddateController,
      readOnly: true,
      decoration: InputDecoration(labelText: 'End Date'),
      onTap: () async {
        if (startDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a start date first.')),
          );
          return;
        }

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: startDate!,
          // استخدام تاريخ البداية كالتاريخ الابتدائي
          firstDate: startDate!,
          // يجب أن يكون تاريخ البداية هو أول تاريخ يمكن اختياره
          lastDate: DateTime(2025), // يمكنك ضبط الحد الأقصى حسب الحاجة
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          enddateController.text = formattedDate;
        }
      },
    );
  }

  // Function for text field widget
  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      String? startDate = startdateController.text;
      String endDate = enddateController.text;

      List<String> optionsWithOutDates = [
        'Hardware Key Report',
        'Device Report',
        'Computers Report',
        'Material Report'
      ];

      if (!optionsWithOutDates.contains(selectedOption)) {
        if (startDate.isEmpty || endDate.isEmpty) {
          setState(() {
            _errorMessage = 'Start date and End date cannot be empty.';
          });
          return;
        }
      }

      try {
        if (!optionsWithOutDates.contains(selectedOption)) {
          DateTime start = DateTime.parse(startDate);
          DateTime end = DateTime.parse(endDate);

          if (end.isBefore(start)) {
            setState(() {
              _errorMessage =
                  'End date must be the same as or after the start date.';
            });
            return;
          }
        }
        String user = userController.text;
        String department = departmentController.text;
        String device = deviceController.text;

        switch (selectedOption) {
          case 'Export Maintenance Service':
            exportMaintenanceService(startDate, endDate);
            break;
          case 'Export Maintenance of User':
            exportMaintenanceOfUser(startDate, endDate, user);
            break;
          case 'Export Maintenance of Department':
            exportMaintenanceOfDepartment(startDate, endDate, department);
            break;
          case 'Export Installation Service':
            exportInstallationService(startDate, endDate);
            break;
          case 'Export Installation of User':
            exportInstallationOfUser(startDate, endDate, user);
            break;
          case 'Export Installation of Department':
            exportInstallationOfDepartment(startDate, endDate, department);
            break;
          case 'Hardware Key Report':
            hardwareKeyReport();
            break;
          case 'Device Report':
            deviceReport(device);
            break;
          case 'Computers Report':
            computersReport();
            break;
          case 'Material Report':
            materialReport();
            break;
          default:
            print('No API available for this option');
        }
      } catch (e) {
        // إذا حدث خطأ في تحويل التاريخ
        setState(() {
          _errorMessage = 'Invalid date format. Please select valid dates.';
        });
      }
    }
  }

  // Functions to handle API calls
  Future<void> exportData(String uri, Map<String, dynamic> body) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final Uri url = Uri.parse(uri);
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      // تأكد من وجود file_path في الاستجابة
      if (jsonData != null && jsonData['file_path'] != null) {
        setState(() {
          _downloadLink = jsonData['file_path']; // احفظ رابط التحميل
        });
      } else {
        setState(() {
          _errorMessage = 'File path is missing in the response.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Error occurred during the process.';
      });
    }
  }

  void exportMaintenanceService(String startDate, String endDate) {
    exportData('$urlbase/exportMaintenanceService', {
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  void exportMaintenanceOfUser(String startDate, String endDate, String user) {
    exportData('$urlbase/exportMaintenanceOfUser', {
      'startDate': startDate,
      'endDate': endDate,
      'user': selecteduserId,
    });
  }

  void exportMaintenanceOfDepartment(
      String startDate, String endDate, String department) {
    exportData('$urlbase/exportMaintenanceOfDepartment', {
      'startDate': startDate,
      'endDate': endDate,
      'department': selectedDepartmentId,
    });
  }

  void exportInstallationService(String startDate, String endDate) {
    exportData('$urlbase/exportInstallationService', {
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  void exportInstallationOfUser(String startDate, String endDate, String user) {
    exportData('$urlbase/exportInstallationOfUser', {
      'startDate': startDate,
      'endDate': endDate,
      'user': selecteduserId,
    });
  }

  void exportInstallationOfDepartment(
      String startDate, String endDate, String department) {
    exportData('$urlbase/exportInstallationOfDepartment', {
      'startDate': startDate,
      'endDate': endDate,
      'department': selectedDepartmentId,
    });
  }

  void hardwareKeyReport() {
    exportData('$urlbase/HardeareKeyReport', {});
  }

  void deviceReport(String device) {
    exportData('$urlbase/DeviceReport', {'device': selectedDeviceId});
  }

  void computersReport() {
    exportData('$urlbase/ComputersReport', {});
  }

  void materialReport() {
    exportData('$urlbase/MaterialReport', {});
  }

  // Function to launch the download link
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      setState(() {
        _errorMessage = 'Could not launch $url';
      });
    }
  }

  // Dropdown for users
  List<ShowUsers> users = [];
  String? selecteduserId;

  Future<void> _fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/showUsers');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        users = jsonResponse.map((data) => ShowUsers.fromJson(data)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load users')),
      );
    }
  } // Dropdown for users

  List<ShowDevices> Device = [];
  String? selectedDeviceId;

  Future<void> _fetchDevice() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/showDevices');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        Device =
            jsonResponse.map((data) => ShowDevices.fromJson(data)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load Device')),
      );
    }
  }

  // Dropdown for departments
  List<ShowDepartments> departments = [];
  String? selectedDepartmentId;

  Future<void> _fetchDepartment() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/showDepartments');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        departments =
            jsonResponse.map((data) => ShowDepartments.fromJson(data)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load departments')),
      );
    }
  }

  // Build dropdown for users
  Widget buildUserDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select User'),
      value: selecteduserId,
      onChanged: (String? newValue) {
        setState(() {
          selecteduserId = newValue;
        });
      },
      items: users.map<DropdownMenuItem<String>>((ShowUsers user) {
        return DropdownMenuItem<String>(
          value: user.id.toString(),
          child: Text(user.name ?? 'no name'), // عرض اسم المستخدم
        );
      }).toList(),
    );
  } // Build dropdown for users

  Widget buildDeviceDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Device'),
      value: selectedDeviceId,
      onChanged: (String? newValue) {
        setState(() {
          selectedDeviceId = newValue;
        });
      },
      items: Device.map<DropdownMenuItem<String>>((ShowDevices Device) {
        return DropdownMenuItem<String>(
          value: Device.id.toString(),
          child: Text(Device.name ?? 'no name'),
        );
      }).toList(),
    );
  }

  // Build dropdown for departments
  Widget buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Department'),
      value: selectedDepartmentId,
      onChanged: (String? newValue) {
        setState(() {
          selectedDepartmentId = newValue;
        });
      },
      items: departments
          .map<DropdownMenuItem<String>>((ShowDepartments department) {
        return DropdownMenuItem<String>(
          value: department.id.toString(),
          child: Text(department.name ?? 'no name'), // عرض اسم القسم
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // استدعاء دالة جلب المستخدمين
    _fetchDepartment();
    _fetchDevice(); // استدعاء دالة جلب الأقسام
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dynamic Form Example'),
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
        body: Column(children: [
          // الصورة في الأعلى
          Container(
            height: 200, // يمكنك تعديل هذا الحجم حسب رغبتك
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/report.png"),
                fit: BoxFit.contain,
              ),
            ),
          ),
        SingleChildScrollView(
            child:
            Center(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // لضبط المحاذاة الأفقية
                  mainAxisAlignment: MainAxisAlignment.center,
                  // لضبط المحاذاة العمودية
                  children: [
                    DropdownButton<String>(
                      hint: Text('Select Option'),
                      value: selectedOption,
                      onChanged: (String? newValue) {
                        startdateController.clear();
                        enddateController.clear();
                        userController.clear();
                        departmentController.clear();
                        deviceController.clear();
                        selecteduserId = null;
                        selectedDepartmentId = null;
                        selectedDeviceId = null;
                        startDate = null;

                        setState(() {
                          selectedOption = newValue;
                          _downloadLink = null;
                          _errorMessage = null;
                        });
                      },
                      items:
                          options.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
                    buildInputFields(),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: submitForm,
                      child: Text('Submit'),
                    ),
                    if (_isLoading) CircularProgressIndicator(),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 16.0),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign:
                            TextAlign.center, // لضبط محاذاة النص في المنتصف
                      ),
                    ],
                    if (_downloadLink != null) ...[
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () => launch(_downloadLink!),
                        child: Text(
                          'Download Report',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        )]));
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/models/show_floors_model.dart';
import 'departmentsPage.dart';
import 'main.dart';

class FloorsPage extends StatefulWidget {
  const FloorsPage({super.key});

  @override
  State<FloorsPage> createState() => _FloorsPageState();
}

class _FloorsPageState extends State<FloorsPage> {
  late Future<List<showFloors>> futureFloors;

  @override
  void initState() {
    super.initState();
    futureFloors = fetchFloors();
  }

  Future<List<showFloors>> fetchFloors() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$urlbase/showFloors'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => showFloors.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load floors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Floors Page'),

        backgroundColor: Colors.blueAccent,
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<showFloors>>(
          future: futureFloors,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<showFloors>? floors = snapshot.data;
              if (floors == null || floors.isEmpty) {
                return _buildEmptyState();
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  return _buildFloorCard(floors[index], context);
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildFloorCard(showFloors floor, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => DepartmentsPage(floorId: floor.id!),
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
        );
      },

      child: Card(color:Color(0xffd1d8e0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        elevation: 5,
        shadowColor: Colors.blue.withOpacity(0.8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              floor.name ?? 'No Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18 ,
                //fontWeight: FontWeight.w100,
                color: Colors.blueAccent, // Custom color for text
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No floors available.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

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
        title: Text('Floors Page'),
      ),
      drawer: NavDrawer(),
      body: FutureBuilder<List<showFloors>>(
        future: futureFloors,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<showFloors>? floors = snapshot.data;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: floors?.length ?? 0,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DepartmentsPage(floorId: floors![index].id!),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: Center(
                      child: Text(
                        floors![index].name ?? 'No Name',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}


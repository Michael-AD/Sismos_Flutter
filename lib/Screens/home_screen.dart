import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> sismos = [];
  double magnitudMinima = 0.0;

  Future<void> llamadaAPI() async {
    final url = Uri.parse('https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final data = jsonDecode(respuesta.body);
      setState(() {
        sismos = data["features"];
      });
    } else {
      // ignore: avoid_print
      print('Error en la solicitud: ${respuesta.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> sismosFiltrados = sismos.where((sismo) {
      final magnitud = sismo["properties"]["mag"];
      return magnitud >= magnitudMinima;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sismos en tiempo real'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: llamadaAPI,
            child: const Text("Obtener sismos"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (sismosFiltrados.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(sismos: sismosFiltrados),
                  ),
                );
              }
            },
            child: const Text("Ver en mapa"),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("Filtrar por magnitud:"),
                Slider(
                  value: magnitudMinima,
                  min: 0.0,
                  max: 10.0,
                  divisions: 20,
                  label: magnitudMinima.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      magnitudMinima = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sismosFiltrados.length,
              itemBuilder: (context, index) {
                final sismo = sismosFiltrados[index];
                final magnitud = sismo["properties"]["mag"];
                final lugar = sismo["properties"]["place"];
                final tiempo = DateTime.fromMillisecondsSinceEpoch(
                  sismo["properties"]["time"],
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Text(
                      magnitud.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(lugar),
                  subtitle: Text(tiempo.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

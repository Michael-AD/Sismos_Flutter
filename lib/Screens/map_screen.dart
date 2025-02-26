import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  final List<dynamic> sismos;

  const MapScreen({super.key, required this.sismos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de Sismos")),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(20.0, -100.0),
          initialZoom: 2.5,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: sismos.map((sismo) {
              final coords = sismo["geometry"]["coordinates"];
              final lat = coords[1];
              final lon = coords[0];
              final magnitud = sismo["properties"]["mag"];
              final lugar = sismo["properties"]["place"];

              return Marker(
                width: 100.0,
                height: 200.0,
                point: LatLng(lat, lon),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 30),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 100),
                      padding: const EdgeInsets.all(5),
                      color: Colors.white,
                      child: Text(
                        "M$magnitud\n$lugar",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

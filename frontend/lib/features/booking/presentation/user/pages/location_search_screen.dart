import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class LocationSearchScreen extends StatefulWidget {
  final String? initialLocation;

  const LocationSearchScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      _controller.text = widget.initialLocation!;
      searchLocation(widget.initialLocation!);
    }
  }

  final TextEditingController _controller = TextEditingController();

  List<dynamic> _results = [];

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    final key = dotenv.env['MAPTILER_API_KEY'];

    final response = await http.get(
      Uri.parse(
        'https://api.maptiler.com/geocoding/$query.json?country=np&key=$key',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _results = data['features'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Search Location",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: searchLocation,
              decoration: InputDecoration(
                hintText: "Search pickup or destination",
                hintStyle: const TextStyle(
                  color: Color(0xFF8E8E8E),
                  fontSize: 17,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF132DB0),
                ),
                filled: true,
                fillColor: const Color(0xFFF6F7FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _results.isEmpty
                ? const Center(
              child: Text(
                "Search for a pickup or delivery location",
                style: TextStyle(
                  color: Color(0xFF8E8E8E),
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final place = _results[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Color(0xFF132DB0),
                    ),
                    title: Text(
                      place['place_name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Navigator.pop(context, place);
                      context.pop(place);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
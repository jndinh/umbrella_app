import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Umbrella extends StatefulWidget {
  Umbrella({Key key, this.search, this.title}) : super(key: key);
  final String search;
  final String title;

  @override
  _UmbrellaState createState() => _UmbrellaState();
}

class _UmbrellaState extends State<Umbrella> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: weatherSearch(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            if (data == null || data['consolidated_weather'].isEmpty) {
              return Text("Couldn't find location data");
            }
            var weatherStateAbbr =
                data['consolidated_weather'].first['weather_state_abbr'];
            var umbrella = 'No';
            // check if the weather is wet
            if (['sl', 'h', 't', 'hr', 'lr', 's'].contains(weatherStateAbbr)) {
              umbrella = 'Yes';
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      umbrella == 'Yes'
                          ? Icons.umbrella_rounded
                          : Icons.wb_sunny,
                      size: 50.0),
                  Text(
                    umbrella,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == null) {
            return Text("Couldn't find location data");
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future weatherSearch() async {
    var results = await http.get(
      'https://www.metaweather.com/api/location/search?query=${widget.search}',
    );

    if (results.statusCode == 200) {
      var search = jsonDecode(results.body);

      if (search.isNotEmpty) {
        return weatherLocation(search.first['woeid']);
      }
    }
    return null;
  }

  Future weatherLocation(var woeid) async {
    var results = await http.get(
      'https://www.metaweather.com/api/location/$woeid',
    );
    if (results.statusCode == 200) {
      return jsonDecode(results.body);
    }
    return null;
  }
}

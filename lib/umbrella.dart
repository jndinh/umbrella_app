import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Umbrella extends StatefulWidget {
  Umbrella({Key key, this.search}) : super(key: key);
  final String search;

  @override
  _UmbrellaState createState() => _UmbrellaState();
}

class _UmbrellaState extends State<Umbrella> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Do I need an umbrella today?'),
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
            if (data == null) return Container();

            print(data);
            var weatherStateName = data['consolidated_weather']
                .first['weather_state_name']
                .toLowerCase();
            if (weatherStateName.contains('rain') ||
                weatherStateName.contains('storm') ||
                weatherStateName.contains('showers') ||
                weatherStateName.contains('sleet')) {
              return Text('yes');
            } else {
              return Text('no');
            }
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
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

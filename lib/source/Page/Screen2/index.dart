import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Screen2 extends StatefulWidget {
  // final String nama;
  // final String kota;
  // Screen2(this.nama, this.kota);

  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  var listCuaca = {};
  var celcius;

  void getWeatherByLokasi() async {
    try {
      var url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=BANDUNG,id&appid=c37683359d6e2a63b212c043a79e3d0b');
      var response = await http.get(url);
      var json = jsonDecode(response.body);
      setState(() {
        listCuaca = json;
        print('ListCUaca: $listCuaca');
        // celcius = listCuaca['main']['temp'] - 273.15;
        // print(celcius);
      });
    } catch (e) {
      print("error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getWeatherByLokasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0,
        title: Text("Weather"),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Selamat Pagi",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                Text(
                  "Raga",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 20),
                    Text(
                      listCuaca['name'].toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                        'http://openweathermap.org/img/w/${listCuaca['weather'][0]['icon']}.png'),
                    Text(
                      listCuaca['weather'][0]['main'].toString(),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  '${listCuaca['main']['temp'] - 273.15}',
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

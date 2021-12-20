import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class Screen2 extends StatefulWidget {
  final String nama;
  final String lokasi;
  Screen2(this.nama, this.lokasi);
  //  Screen2({Key? key, lokasi,nama}): super(key: key);

  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  var listCuaca = {};
  double celcius = 0.0;
  bool loadingByLokasi = false;
  bool loadingBy5day = false;
  var resStatusLokasi = 0;
  var resStatus5day = 0;

  void getWeatherByLokasi(lokasi) async {
    setState(() {
      loadingByLokasi = true;
      listCuaca.clear();
    });
    try {
      var url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=${lokasi},id&appid=c37683359d6e2a63b212c043a79e3d0b');
      var response = await http.get(url);
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          resStatusLokasi = response.statusCode;
          loadingByLokasi = false;
          listCuaca = json;
          // print('ListCUaca: $listCuaca');
          if (listCuaca.isNotEmpty) {
            celcius = listCuaca['main']['temp'] - 273.15;
          }
          // print(celcius);
        });
      } else {
        setState(() {
          resStatusLokasi = response.statusCode;
          loadingByLokasi = false;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Alert'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text(response.body.toString())],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'))
                  ],
                );
              });
        });
      }
    } catch (e) {
      print("error: $e");
      setState(() {
        loadingByLokasi = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text(e.toString())],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'))
              ],
            );
          });
    }
  }

  var listBy5day = [];
  void getBy5day(var lokasi) async {
    setState(() {
      loadingBy5day = true;
      listBy5day.clear();
    });
    try {
      var url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=${lokasi},id&appid=c37683359d6e2a63b212c043a79e3d0b');
      var response = await http.get(url);
      var json = jsonDecode(response.body);
      // print(json);
      var array = [];
      var array2 = [];
      if (response.statusCode == 200) {
        setState(() {
          resStatus5day = response.statusCode;
          loadingBy5day = false;
          // listBy5day = json['list'];
          if (json != null) {
            array = json['list'];
            array
                .map((e) {
                  var date = e['dt_txt'].toString().split(' ')[0];
                  array2.add(date);
                })
                .toSet()
                .toList();
            var duplicate = {
              ...{...array2}
            };
            var bb = {
              ...{...array}
            };
            // print(bb);
            duplicate.map((e) {
              var a = {'date': e, 'list': array};
              listBy5day.add(a);
            }).toList();
            if (listBy5day.length >= 6) {
              listBy5day.removeLast();
            }
            // print(sample);
          }
        });
      } else {
        setState(() {
          resStatus5day = response.statusCode;
          loadingBy5day = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Alert'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text(response.body.toString())],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'))
                ],
              );
            });
      }
    } catch (e) {
      setState(() {
        loadingBy5day = false;
      });
      print("error: $e");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text(e.toString())],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'))
              ],
            );
          });
    }
  }

  var waktu = DateTime.now().hour;
  var date = DateTime.now();
  var formatedTanggal = DateFormat('EEE, MMM d, ' 'yy').format(DateTime.now());
  var valueSalam = '';
  void salam() {
    if (waktu < 12) {
      valueSalam = 'Selamat Pagi';
    } else if (waktu >= 12 && waktu < 15) {
      valueSalam = 'Selamat Siang';
    } else if (waktu >= 15 && waktu < 18) {
      valueSalam = 'Selamat Sore';
    } else {
      valueSalam = 'Selamat Malam';
    }
  }

  @override
  void initState() {
    super.initState();
    getWeatherByLokasi(widget.lokasi);
    getBy5day(widget.lokasi);
    salam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0,
        title: const Text("Weather"),
        centerTitle: true,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Colors.blue[400], statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.light),
        actions: [
          IconButton(
              onPressed: () {
                getWeatherByLokasi(widget.lokasi);
                getBy5day(widget.lokasi);
                salam();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valueSalam,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                Text(
                  widget.nama,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400, color: Colors.white),
                ),
              ],
            ),
          ),
          loadingByLokasi == true
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 10, child: Center(child: CircularProgressIndicator(color: Colors.white))),
                )
              : resStatusLokasi != 200
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        'Gagal Memuat Data',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      )),
                    )
                  : listCuaca.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            'Data Kosong',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                        )
                      : Column(
                          children: [
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
                                      const Icon(Icons.location_on, color: Colors.white, size: 20),
                                      Text(
                                        listCuaca['name'].toString(),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(formatedTanggal.toString(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.network('http://openweathermap.org/img/w/${listCuaca['weather'][0]['icon']}.png'),
                                      Text(
                                        listCuaca['weather'][0]['main'].toString(),
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${celcius.toStringAsFixed(2)}°C',
                                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Column(
                                        children: [
                                          const Text('Humidity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Icon(Ionicons.md_water, color: Colors.blue[300]),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('${listCuaca['main']['humidity']}%'.toString(),
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      )),
                                  Expanded(
                                      flex: 4,
                                      child: Column(
                                        children: [
                                          const Text('Pressure', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Icon(Ionicons.md_speedometer, color: Colors.blue[300]),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('${listCuaca['main']['pressure']} hpa'.toString(),
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      )),
                                  Expanded(
                                      flex: 4,
                                      child: Column(
                                        children: [
                                          const Text('Cloudiness', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Icon(MaterialCommunityIcons.cloud_outline, color: Colors.blue[300]),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('${listCuaca['clouds']['all']}%'.toString(),
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      )),
                                  Expanded(
                                      flex: 4,
                                      child: Column(
                                        children: [
                                          const Text('Wind', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Icon(Feather.wind, color: Colors.blue[300]),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('${listCuaca['wind']['speed']} m/s'.toString(),
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
          loadingBy5day == true
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 10, child: Center(child: CircularProgressIndicator(color: Colors.white))),
                )
              : resStatus5day != 200
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        'Gagal Memuat Data',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      )),
                    )
                  : listBy5day.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            'Data Kosong',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height / 2,
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                          child: ListView.builder(
                              itemCount: listBy5day.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${Jiffy(listBy5day[index]['date'].toString().split(' ')[0].toString()).yMMMMd}',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                      SizedBox(
                                          height: MediaQuery.of(context).size.height / 8,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: listBy5day[index]['list'].length,
                                              itemBuilder: (BuildContext context, int idx) {
                                                double cel = listBy5day[index]['list'][idx]['main']['temp'] - 273.15;
                                                if (listBy5day[index]['date'] == listBy5day[index]['list'][idx]['dt_txt'].toString().split(' ')[0]) {
                                                  return Container(
                                                    margin: const EdgeInsets.all(4.0),
                                                    padding: const EdgeInsets.all(4.0),
                                                    child: Column(
                                                      children: [
                                                        Text(listBy5day[index]['list'][idx]['dt_txt'].toString().split(' ')[1].characters.take(5).toString()),
                                                        Image.network(
                                                            'http://openweathermap.org/img/w/${listBy5day[index]['list'][idx]['weather'][0]['icon']}.png'),
                                                        Text('${cel.toStringAsFixed(2)}°C', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400))
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              })),
                                      const Divider(
                                        color: Colors.grey,
                                        height: 4,
                                        thickness: 2,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
        ],
      ),
    );
  }
}

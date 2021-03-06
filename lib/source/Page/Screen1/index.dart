import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:search_choices/search_choices.dart';
import 'package:weather/source/Model/ModelKota.dart';
import 'package:weather/source/Model/ModelProvinsi.dart';
import 'package:weather/source/Page/Screen2/index.dart';

class Screen1 extends StatefulWidget {
  Screen1({Key? key}) : super(key: key);

  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final TextEditingController controllerNama = TextEditingController();
  final formkey = new GlobalKey<FormState>();
  List<Provinsi> listProvinsi = [];
  List<Provinsi> listFilter = [];
  List<Kota> listKota = [];
  var valueProvinsi = '';
  var valueProvId = 0;
  var valueKota = '';
  var valueKotaId = 0;
  void getProvinsi() async {
    setState(() {
      listProvinsi.clear();
    });
    try {
      var url = Uri.parse('http://www.emsifa.com/api-wilayah-indonesia/api/provinces.json');
      var response = await http.get(url);
      var json = jsonDecode(response.body);
      var array = [];
      // listProvinsi.add(json);
      setState(() {
        array = json;
        array.map((e) {
          // var a = e['id'];
          listProvinsi.add(Provinsi(int.parse(e['id']), e['name']));
        }).toList();
      });
      print('Provinsi: ${array}');
    } catch (e) {
      print('Error: $e');
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

  void getKota(var id_kota) async {
    setState(() {
      listKota.clear();
    });
    try {
      var url = Uri.parse('http://www.emsifa.com/api-wilayah-indonesia/api/regencies/${id_kota}.json');
      var response = await http.get(url);
      var json = jsonDecode(response.body);
      var array = [];
      setState(() {
        array = json;
        // for (Map i in json) {
        //   listProvinsi.add(Provinsi.fromJson(i));
        // }
        array.map((e) {
          var a = e['id'];
          listKota.add(Kota(int.parse(e['id']), int.parse(e['province_id']), e['name']));
        }).toList();
      });
      print('Kota: $json');
    } catch (e) {
      print('Error: $e');
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

  filterProvinsi(String text) async {
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    listFilter.clear();
    listProvinsi.forEach((element) {
      if (element.name.contains(text) || element.id.toString().contains(text)) {
        listFilter.add(element);
        print(listFilter[0].id);
        setState(() {
          valueProvId = listFilter[0].id;
          getKota(valueProvId);
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProvinsi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[400],
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Icon(MaterialCommunityIcons.weather_windy_variant, color: Colors.white, size: 100),
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Center(child: Text('Weather', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600))),
            ),
            Container(
              margin: const EdgeInsets.all(12.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0), boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ]),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: formkey,
                      child: TextFormField(
                        controller: controllerNama,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Lengkap harus di isi';
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "Silahkan Masukan Nama Lengkap",
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                          contentPadding: EdgeInsets.all(6),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchChoices.single(
                      onClear: () {
                        listKota.clear();
                      },
                      value: valueProvinsi,
                      items: listProvinsi.map((item) {
                        return DropdownMenuItem(
                          child: Text(item.name),
                          value: item.name,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          valueProvinsi = value;
                          filterProvinsi(value);
                        });
                      },
                      hint: "Pilih Provinsi",
                      searchHint: "Masukan Kata Kunci",
                      isExpanded: true,
                      dialogBox: true,
                      validator: (value) {
                        if (value == null) {
                          return 'Provinsi harus di isi';
                        }
                      },
                      displayItem: (item, selected) {
                        return (Row(children: [
                          selected
                              ? Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.grey,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                ),
                          SizedBox(width: 7),
                          Expanded(
                            child: item,
                          ),
                        ]));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchChoices.single(
                      onClear: () {
                        listKota.clear();
                      },
                      value: valueKota,
                      items: listKota.map((item) {
                        return DropdownMenuItem(
                          child: Text(item.name),
                          value: item.name,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          valueKota = value;
                        });
                      },
                      hint: "Pilih Kota/Kabupaten",
                      searchHint: "Masukan kata Kunci",
                      isExpanded: true,
                      dialogBox: true,
                      validator: (value) {
                        if (value == null) {
                          return 'Kota harus di isi';
                        }
                      },
                      displayItem: (item, selected) {
                        return (Row(children: [
                          selected
                              ? Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.grey,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                ),
                          SizedBox(width: 7),
                          Expanded(
                            child: item,
                          ),
                        ]));
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.blue[200]),
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        if (valueProvinsi == null) {
                          if (valueKota == null) {
                            print('masih kosong');
                          } else {
                            print('masih ada yang kosong');
                          }
                        } else {
                          if (valueKota == null) {
                            print('masih kosong kota');
                          } else {
                            print('sudah ke isi');
                            // controllerNama.clear();
                            valueKota;
                            valueProvinsi;
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Screen2(controllerNama.text, valueKota)));
                          }
                        }
                      }
                    },
                    child: const Text(
                      'PROSES',
                      style: TextStyle(fontSize: 17, color: Colors.blue),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

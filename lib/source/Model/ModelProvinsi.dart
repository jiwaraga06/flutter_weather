class Provinsi {
  final int id;
  final String name;
  Provinsi(this.id, this.name);

  Provinsi.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'];

  @override
  String toString() {
    return 'id: ${id.toString()}, Name: $name';
  }
}

class Kota {
  final int id;
  final int province_id;
  final String name;

  Kota(this.id, this.province_id, this.name);

  @override
  String toString() {
    return 'id: $id, province_id: $province_id, name: $name';
  }
}
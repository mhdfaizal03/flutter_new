class StudentModel {
  int? id;
  String name;
  int age;
  String batch;
  String stack; // Subject/Stack field
  bool isPresent;

  StudentModel({
    this.id,
    required this.name,
    required this.age,
    required this.batch,
    required this.stack,
    this.isPresent = true,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'age': age,
      'batch': batch,
      'stack': stack,
      'isPresent': isPresent ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  StudentModel.fromMap(Map<String, dynamic> map)
    : id = map['id'],
      name = map['name'],
      age = map['age'],
      batch = map['batch'] ?? '',
      stack = map['stack'] ?? '',
      isPresent = map['isPresent'] == 1;
}

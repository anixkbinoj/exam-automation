import 'package:excel/excel.dart';
import 'dart:io';
import '../models/student.dart';

class ExcelService {
  static List<Student> students = [];

  static Future<void> readAndStoreExcel(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    students.clear();

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows.skip(1)) {
        students.add(
          Student(
            registerNumber: row[0]?.value.toString() ?? '',
            name: row[1]?.value.toString() ?? '',
            className: row[2]?.value.toString() ?? '',
            roomNumber: row[3]?.value.toString() ?? '',
          ),
        );
      }
    }
  }

  static Student? findStudent(String registerNumber) {
    try {
      return students.firstWhere(
        (s) => s.registerNumber == registerNumber,
        orElse: () => Student.empty(),
      );
    } catch (e) {
      return null;
    }
  }
}

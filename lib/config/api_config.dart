class ApiConfig {
  // Use '10.0.2.2' for Android Emulator, 'localhost' for web/desktop,
  // or your machine's network IP for a physical device.
  static const String _baseUrl = "http://10.159.50.69/exam_automation";

  // --- Authentication ---
  static const String login = "$_baseUrl/login.php";

  // --- Student ---
  static const String fetchStudentDetails =
      "$_baseUrl/fetch_student_details.php";
  static const String getSeating = "$_baseUrl/get_seating.php";

  // --- Admin ---
  static const String uploadSeatingExcel = "$_baseUrl/upload_seating_excel.php";
  // TODO: Add endpoints for notices, timetable, duties, etc.
}

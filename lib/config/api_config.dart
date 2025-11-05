class ApiConfig {
  // Use '10.0.2.2' for Android Emulator, 'localhost' for web/desktop,
  // or your machine's network IP for a physical device.
  static const String _baseUrl = "https://mbccet.in/cms/exam_automation";

  // --- Authentication ---
  static const String login = "$_baseUrl/login.php";

  // --- Student ---
  static const String fetchStudentDetails =
      "$_baseUrl/fetch_student_details.php";
  static const String getSeating = "$_baseUrl/get_seating.php";
  static const String fetchFacultyDetails = "$_baseUrl/fetch_faculty.php";
  static const String viewFaculty = "$_baseUrl/view_faculty.php";

  // --- Admin ---
  static const String uploadSeatingExcel = "$_baseUrl/upload_seating_excel.php";
  static const String addStudent = "$_baseUrl/add_student.php";
  // Note: The following endpoints were pointing to a different IP (10.3.2.145).
  // They have been consolidated to the base URL for consistency.
  // Please ensure your server is configured to handle these routes.
  static const String getTimetable = "$_baseUrl/get_timetable.php";
  static const String getNotices = "$_baseUrl/get_notices.php";

  // --- Faculty ---
  static const String fetchAssignedDuties =
      "$_baseUrl/fetch_assigned_duties.php";
}

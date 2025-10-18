class Student {
  final String registerNumber;
  final String name;
  final String className;
  final String roomNumber;

  Student({
    required this.registerNumber,
    required this.name,
    required this.className,
    required this.roomNumber,
  });

  factory Student.empty() =>
      Student(registerNumber: '', name: '', className: '', roomNumber: '');
}

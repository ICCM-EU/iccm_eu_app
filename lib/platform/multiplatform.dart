// https://chtgupta.medium.com/stop-using-kisweb-the-right-way-to-implement-multi-platform-code-in-your-flutter-project-edcd67970aa3

export 'multiplatform_stub.dart'
if (dart.library.io) 'multiplatform_io.dart'
if (dart.library.html) 'multiplatform_web.dart';

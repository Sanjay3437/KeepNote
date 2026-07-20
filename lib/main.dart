import 'package:flutter/material.dart';
import 'package:keep_notes/screens/home.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future  main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notebook');
  runApp(const Home());
}


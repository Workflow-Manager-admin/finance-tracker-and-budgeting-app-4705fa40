import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';

Future<void> main() async {
  // Load environment variables from the .env file.
  await dotenv.load();
  runApp(const FinanceTrackerApp());
}

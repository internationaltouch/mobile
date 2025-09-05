import 'package:flutter/widgets.dart';

abstract class FlagsInterface {
  static Widget? getFlagWidget({
    required String teamName,
    String? clubAbbreviation,
    double size = 45.0,
  }) {
    throw UnimplementedError();
  }

  static bool hasFlagForTeam(String teamName, String? clubAbbreviation) {
    throw UnimplementedError();
  }
}
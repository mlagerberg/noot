import 'package:flutter/material.dart';

bool isTablet(BuildContext context) {
  var shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide >= 600;
}

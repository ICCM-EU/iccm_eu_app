import 'package:flutter/material.dart';

abstract class ModelItem<T> {
  String get imageUrl;
  TextSpan get name;
  TextSpan get details;
}
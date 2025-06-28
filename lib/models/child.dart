import 'package:flutter/material.dart';

class Child {
  final String id;
  final String name;
  final Color color; // こどもごとに色分けするとUIが華やかになります

  Child({required this.id, required this.name, required this.color});
}

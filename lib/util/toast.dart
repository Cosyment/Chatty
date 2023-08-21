import 'package:flutter/material.dart';

class Toast{

  static void show(context,message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
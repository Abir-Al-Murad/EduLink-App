import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ShowSnackBarMessage(BuildContext context,String message){
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message))
  );
}
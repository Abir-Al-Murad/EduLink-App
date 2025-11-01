import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel{
  final String title;
  final String description;
  final Timestamp createdAt;

  NoticeModel({required this.title, required this.description, required this.createdAt});

  factory NoticeModel.fromFireStore(Map<String,dynamic>jsonData){
    return NoticeModel(title: jsonData['title'], description: jsonData['description'], createdAt: jsonData['createdAt']);
  }

  Map<String,dynamic>toFireStore(String title,String description){
    return {
      'title':title,
      'description':description,
      'createdAt':createdAt
    };
  }
}
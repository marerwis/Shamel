import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? parentId;
  final DateTime createdAt;
  final List<CategoryModel>? subcategories; // Used when building trees locally

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.parentId,
    required this.createdAt,
    this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'بدون اسم',
      icon: json['icon'],
      parentId: json['parent_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List).map((i) => CategoryModel.fromJson(i)).toList()
          : null,
    );
  }

  // Get Flutter IconData based on string icon name
  IconData get iconData {
    switch (icon) {
      case 'cleaning_services': return Icons.cleaning_services;
      case 'ac_unit': return Icons.ac_unit;
      case 'plumbing': return Icons.plumbing;
      case 'electrical_services': return Icons.electrical_services;
      case 'home_repair_service': return Icons.home_repair_service;
      case 'car_repair': return Icons.car_repair;
      case 'medical_services': return Icons.medical_services;
      case 'local_hospital': return Icons.local_hospital;
      case 'pets': return Icons.pets;
      case 'build': return Icons.build;
      default: return Icons.category;
    }
  }
}

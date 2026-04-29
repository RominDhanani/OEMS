import 'package:flutter/material.dart';

class CategoryInfo {
  final IconData icon;
  final Color color;

  CategoryInfo({required this.icon, required this.color});
}

class DesignUtils {
  static CategoryInfo getCategoryInfo(String category) {
    switch (category) {
      case 'Travel':
        return CategoryInfo(icon: Icons.flight_takeoff_rounded, color: const Color(0xFF3B82F6));
      case 'Meals & Entertainment':
        return CategoryInfo(icon: Icons.restaurant_rounded, color: const Color(0xFFF59E0B));
      case 'Office Supplies':
        return CategoryInfo(icon: Icons.inventory_2_rounded, color: const Color(0xFF10B981));
      case 'Accommodation':
        return CategoryInfo(icon: Icons.hotel_rounded, color: const Color(0xFF8B5CF6));
      case 'Transportation':
        return CategoryInfo(icon: Icons.directions_car_rounded, color: const Color(0xFFEC4899));
      case 'Communication':
        return CategoryInfo(icon: Icons.phone_android_rounded, color: const Color(0xFF06B6D4));
      case 'Equipment':
        return CategoryInfo(icon: Icons.home_repair_service_rounded, color: const Color(0xFFF43F5E));
      case 'Training':
        return CategoryInfo(icon: Icons.school_rounded, color: const Color(0xFF6366F1));
      default:
        return CategoryInfo(icon: Icons.receipt_long_rounded, color: const Color(0xFF6B7280));
    }
  }
}

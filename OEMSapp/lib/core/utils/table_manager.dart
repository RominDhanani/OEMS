import 'package:flutter/material.dart';

class TableManager<T> {
  final List<T> allData;
  final List<String> searchFields;
  final String? dateField;

  TableManager({
    required this.allData,
    required this.searchFields,
    this.dateField,
  });

  List<T> filter({
    String? searchTerm,
    DateTimeRange? dateRange,
    Map<String, dynamic>? fieldFilters,
  }) {
    return allData.where((item) {
      // 1. Search Term Filtering
      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        final query = searchTerm.trim().toLowerCase();
        
        // If searchFields is empty, we search EVERYTHING available in the item's Map representation
        final fieldsToSearch = searchFields.isNotEmpty ? searchFields : _getAllKeys(item);
        
        final matchesSearch = fieldsToSearch.any((field) {
          final value = _getProperty(item, field);
          if (value == null) return false;
          return value.toString().toLowerCase().contains(query);
        });
        
        if (!matchesSearch) return false;
      }

      // 2. Date Range Filtering
      if (dateRange != null && dateField != null) {
        final rawDate = _getProperty(item, dateField!);
        if (rawDate != null) {
          final date = rawDate is DateTime ? rawDate : DateTime.tryParse(rawDate.toString());
          if (date != null) {
            final start = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
            final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day, 23, 59, 59);
            if (date.isBefore(start) || date.isAfter(end)) return false;
          }
        }
      }

      // 3. Specific Field Filters (e.g., category, status)
      if (fieldFilters != null) {
        final matchesFields = fieldFilters.entries.every((entry) {
          if (entry.value == null || entry.value.toString().isEmpty || entry.value == 'All') return true;
          final value = _getProperty(item, entry.key)?.toString();
          if (value == null) return false;
          return value.toUpperCase() == entry.value.toString().toUpperCase();
        });
        if (!matchesFields) return false;
      }

      return true;
    }).toList();
  }

  // Basic reflection-like property access for standard Map or Model structures
  dynamic _getProperty(T item, String field) {
    if (item is Map) {
      return item[field];
    }
    
    // Attempt common serialization methods
    try {
      final dynamic dItem = item;
      if (dItem is Map) return dItem[field];
      
      // Check for toJson() or toMap()
      Map<String, dynamic>? map;
      try {
        map = dItem.toJson();
      } catch (_) {
        try {
          map = dItem.toMap();
        } catch (_) {}
      }
      
      if (map != null) return map[field];
    } catch (_) {}
    
    return null;
  }

  /// Extracts all available keys from an item for broad searching
  List<String> _getAllKeys(T item) {
    if (item is Map) {
      return item.keys.map((k) => k.toString()).toList();
    }
    
    try {
      final dynamic dItem = item;
      Map<String, dynamic>? map;
      try {
        map = dItem.toJson();
      } catch (_) {
        try {
          map = dItem.toMap();
        } catch (_) {}
      }
      
      if (map != null) return map.keys.toList();
    } catch (_) {}
    
    return [];
  }

  List<T> getPaginatedData(List<T> filteredData, int currentPage, int itemsPerPage) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= filteredData.length) return [];
    final endIndex = (startIndex + itemsPerPage) > filteredData.length
        ? filteredData.length
        : (startIndex + itemsPerPage);
    return filteredData.sublist(startIndex, endIndex);
  }

  int getTotalPages(int filteredCount, int itemsPerPage) {
    return (filteredCount / itemsPerPage).ceil();
  }
}

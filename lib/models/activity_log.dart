import 'package:flutter/material.dart';

class ActivityFields {
  static const String tableName = "activities";
  static const String id = "id";
  static const String title = "title";
  static const String total = "total";
  static const String lastDone = "lastDone";
  static final List<String> values = [id, title, total, lastDone];
}

class Activity {
  final int? id;
  final String title;
  final int total;
  final DateTime? lastDone;
  Activity ({
    this.id,
    required this.title,
    required this.total,
    this.lastDone
});

  Activity copy({
    int? id,
    String? title,
    int? total,
    DateTime? lastDone,
})
  {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      total: total ?? this.total,
      lastDone: lastDone ?? this.lastDone,
    );
  }
  static Activity fromJson(Map<String, Object?>json) {
    return Activity(
      id: json[ActivityFields.id] as int?,
      title: json[ActivityFields.title] as String,
      total: json[ActivityFields.total] as int,
      lastDone: json[ActivityFields.lastDone] != null
          ? DateTime.tryParse(json[ActivityFields.lastDone] as String)
          : null,
    );
  }
  Map<String, Object?> toJson() {
    return {
      ActivityFields.id: id,
      ActivityFields.title: title,
      ActivityFields.total: total,
      ActivityFields.lastDone: lastDone?.toIso8601String(),
    };
  }

}


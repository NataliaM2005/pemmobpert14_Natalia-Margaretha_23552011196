import 'package:flutter/material.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? deadline;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.deadline,
  });

  // Mengubah objek Note menjadi Map untuk disimpan ke Database (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
    };
  }

  // Mengubah data dari Database (Map) kembali menjadi objek Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'])
          : null,
    );
  }
}

// Fungsi untuk menentukan warna kartu berdasarkan sisa hari menuju deadline
Color noteColorByDeadline(DateTime? deadline) {
  if (deadline == null) return Colors.yellow.shade300;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dl = DateTime(deadline.year, deadline.month, deadline.day);

  final diffDays = dl.difference(today).inDays;

  if (diffDays < 0) return Colors.red.shade900; // Sudah lewat
  if (diffDays <= 1) return Colors.red.shade400; // Besok atau hari ini
  if (diffDays <= 3) return Colors.orange.shade400; // 3 hari lagi
  if (diffDays <= 7) return Colors.lightGreen.shade400; // 1 minggu lagi
  return Colors.green.shade400; // Masih lama
}
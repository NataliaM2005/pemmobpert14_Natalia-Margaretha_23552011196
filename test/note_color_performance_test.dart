import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pertemuan11/note.dart';

Color noteColorByDeadlineOptimized(DateTime? deadline, DateTime today) {
  if (deadline == null) return Colors.yellow.shade300;

  final d1 = DateTime(deadline.year, deadline.month, deadline.day);
  final diffDays = d1.difference(today).inDays;

  if (diffDays < 0) return Colors.red.shade900;
  if (diffDays <= 1) return Colors.red.shade400;
  if (diffDays <= 3) return Colors.orange.shade400;
  if (diffDays <= 7) return Colors.lightGreen.shade400;
  return Colors.green.shade400;
}

void main() {
  test('Performance compare: original vs optimized noteColorByDeadline', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final deadlines = List<DateTime?>.generate(20000, (i) {
      if (i % 10 == 0) return null;
      return today.add(Duration(days: (i % 30) - 10));
    });

    final swOriginal = Stopwatch()..start();
    for (final d in deadlines) {
      noteColorByDeadline(d);
    }
    swOriginal.stop();

    final swOptimized = Stopwatch()..start();
    for (final d in deadlines) {
      noteColorByDeadlineOptimized(d, today);
    }
    swOptimized.stop();

    // output untuk laporan praktikum
    // ignore: avoid_print
    print('Original ms: ${swOriginal.elapsedMilliseconds}');
    // ignore: avoid_print
    print('Optimized ms: ${swOptimized.elapsedMilliseconds}');

    // sanity check
    expect(noteColorByDeadline(null), Colors.yellow.shade300);
  });
}

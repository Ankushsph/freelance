import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Set<DateTime> scheduledDates;
  final Set<DateTime> immediateDates;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime)? onAddTapped;
  final Function(DateTime)? onEditTapped;

  const ScheduleCalendar({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.scheduledDates,
    required this.immediateDates,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.onAddTapped,
    this.onEditTapped,
  });

  DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    // weekday: Mon=1 … Sun=7, offset so Mon is col 0
    final startOffset = firstDay.weekday - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // ── Month nav ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
                onPressed: () => onMonthChanged(
                    DateTime(currentMonth.year, currentMonth.month - 1)),
              ),
              Text(
                DateFormat("MMMM yyyy").format(currentMonth),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black54),
                onPressed: () => onMonthChanged(
                    DateTime(currentMonth.year, currentMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ── Day-of-week headers + grid ─────────────────────────
          LayoutBuilder(builder: (ctx, box) {
            final cw = box.maxWidth / 7;
            return Column(
              children: [
                // headers
                Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((d) => SizedBox(
                            width: cw,
                            child: Center(
                              child: Text(d,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                // grid rows
                ..._buildRows(daysInMonth, startOffset, cw),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildRows(int daysInMonth, int startOffset, double cw) {
    final today = _norm(DateTime.now());
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final rows = <Widget>[];

    for (int row = 0; row < rowCount; row++) {
      final cells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;
        if (cellIndex < startOffset || cellIndex >= totalCells) {
          cells.add(SizedBox(width: cw, height: 52));
        } else {
          final day = cellIndex - startOffset + 1;
          final date = DateTime(currentMonth.year, currentMonth.month, day);
          cells.add(_DayCell(
            date: date,
            cellWidth: cw,
            isSelected: _norm(selectedDate) == _norm(date),
            isPast: _norm(date).isBefore(today),
            isToday: _norm(date) == today,
            hasPosts: scheduledDates.any((d) => _norm(d) == _norm(date)) ||
                immediateDates.any((d) => _norm(d) == _norm(date)),
            onTap: () => onDateSelected(date),
            onAdd: () => onAddTapped?.call(date),
            onEdit: () => onEditTapped?.call(date),
          ));
        }
      }
      rows.add(Row(children: cells));
    }
    return rows;
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final double cellWidth;
  final bool isSelected;
  final bool isPast;
  final bool isToday;
  final bool hasPosts;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onEdit;

  const _DayCell({
    required this.date,
    required this.cellWidth,
    required this.isSelected,
    required this.isPast,
    required this.isToday,
    required this.hasPosts,
    required this.onTap,
    required this.onAdd,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellWidth,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Date number ──────────────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onTap: isPast ? null : onTap,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.w400,
                        color: isPast
                            ? Colors.grey.shade400
                            : isSelected
                                ? Colors.white
                                : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Pink dot for scheduled posts ─────────────────────
          if (hasPosts && !isPast)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFEC4899), // Pink for all platforms
                  ),
                ),
              ),
            ),

          // ── + / edit badge (top-right) ────────────────────────
          if (!isPast)
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: hasPosts ? onEdit : onAdd,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasPosts
                          ? const Color(0xFFEC4899)
                          : const Color(0xFF2563EB),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 3)
                    ],
                  ),
                  child: Icon(
                    hasPosts ? Icons.edit : Icons.add,
                    size: 10,
                    color: hasPosts
                        ? const Color(0xFFEC4899)
                        : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

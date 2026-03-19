import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final String? platformDisplayName;

  const SchedulePickerSheet({
    super.key,
    this.initialDate,
    this.initialTime,
    this.platformDisplayName,
  });

  @override
  State<SchedulePickerSheet> createState() => _SchedulePickerSheetState();
}

class _SchedulePickerSheetState extends State<SchedulePickerSheet> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? now;
    _currentMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    _selectedTime = widget.initialTime;
  }

  DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final initial = _selectedTime ??
        TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t != null) setState(() => _selectedTime = t);
  }

  void _confirm() {
    if (_selectedTime == null) {
      _pickTime().then((_) {
        if (_selectedTime != null && mounted) _doConfirm();
      });
    } else {
      _doConfirm();
    }
  }

  void _doConfirm() {
    final now = DateTime.now();
    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    if (dt.isBefore(now.add(const Duration(minutes: 5)))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a future time (at least 5 min from now)'),
          backgroundColor: Colors.red));
      return;
    }
    Navigator.pop(context, {'date': _selectedDate, 'time': _selectedTime});
  }

  @override
  Widget build(BuildContext context) {
    final today = _norm(DateTime.now());
    final firstDay =
    
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1; // Mon=0

    final selLabel =
        '${_weekdayName(_selectedDate.weekday)}, ${_selectedDate.day}';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        widget.platformDisplayName ?? 'Instagram',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Blue date pill ──────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    selLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Month nav ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _currentMonth =
                          DateTime(_currentMonth.year,
                              _currentMonth.month - 1)),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.black54),
                    ),
                    Text(
                      DateFormat('MMMM').format(_currentMonth).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _currentMonth =
                          DateTime(_currentMonth.year,
                              _currentMonth.month + 1)),
                      child: const Icon(Icons.chevron_right,
                          color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // ── Calendar grid ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(builder: (ctx2, box) {
                  final cw = box.maxWidth / 7;
                  return Column(
                    children: [
                      // day headers
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
                      // rows
                      ..._buildCalRows(
                          daysInMonth, startOffset, cw, today),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 12),

              // ── Time row ────────────────────────────────────
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2563EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Color(0xFF2563EB), size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select time',
                        style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Confirm button ───────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 0, 16, MediaQuery.of(context).padding.bottom + 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text('Confirm Schedule',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCalRows(
      int daysInMonth, int startOffset, double cw, DateTime today) {
    final rows = <Widget>[];
    int day = 1;
    while (day <= daysInMonth) {
      final cells = <Widget>[];
      for (int c = 0; c < 7; c++) {
        final index = (rows.length * 7) + c;
        if (index < startOffset || day > daysInMonth) {
          cells.add(SizedBox(width: cw, height: 44));
        } else {
          final date =
              DateTime(_currentMonth.year, _currentMonth.month, day);
          final isSelected = _norm(date) == _norm(_selectedDate);
          final isPast = _norm(date).isBefore(today);
          cells.add(_CalCell(
            date: date,
            cellWidth: cw,
            isSelected: isSelected,
            isPast: isPast,
            onTap: isPast ? null : () => setState(() => _selectedDate = date),
          ));
          day++;
        }
      }
      rows.add(Row(children: cells));
    }
    return rows;
  }

  String _weekdayName(int wd) {
    const n = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return n[wd - 1];
  }
}

class _CalCell extends StatelessWidget {
  final DateTime date;
  final double cellWidth;
  final bool isSelected;
  final bool isPast;
  final VoidCallback? onTap;

  const _CalCell({
    required this.date,
    required this.cellWidth,
    required this.isSelected,
    required this.isPast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cellWidth,
        height: 44,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: const Color(0xFFEC4899), width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w400,
                  color: isPast
                      ? Colors.grey.shade400
                      : isSelected
                          ? const Color(0xFFEC4899)
                          : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

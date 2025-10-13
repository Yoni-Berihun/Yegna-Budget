import 'package:flutter/material.dart';
import 'package:abushakir/abushakir.dart';

class EthiopianCalendarPage extends StatefulWidget {
  final EtDatetime initialDate;

  const EthiopianCalendarPage({super.key, required this.initialDate});

  @override
  State<EthiopianCalendarPage> createState() => _EthiopianCalendarPageState();
}

class _EthiopianCalendarPageState extends State<EthiopianCalendarPage> {
  late EtDatetime _focusedDate;   // Which month is displayed
  late EtDatetime _selectedDate;  // Currently selected date

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
    _selectedDate = widget.initialDate;
  }

  // Generate all days of the focused Ethiopian month
  List<EtDatetime> _daysInFocusedMonth() {
    final int year = _focusedDate.year;
    final int month = _focusedDate.month;

    // Months 1–12 have 30 days, 13th (Pagumen) has 5 or 6 days (leap rule: year % 4 == 3)
    final bool isPagumen = month == 13;
    final bool isLeap = year % 4 == 3;
    final int length = isPagumen ? (isLeap ? 6 : 5) : 30;

    return List.generate(
      length,
      (i) => EtDatetime(year: year, month: month, day: i + 1),
    );
  }

  void _goToPrevMonth() {
    final int year = _focusedDate.year;
    final int month = _focusedDate.month;

    if (month > 1) {
      setState(() {
        _focusedDate = EtDatetime(year: year, month: month - 1, day: 1);
      });
    } else {
      setState(() {
        _focusedDate = EtDatetime(year: year - 1, month: 13, day: 1);
      });
    }
  }

  void _goToNextMonth() {
    final int year = _focusedDate.year;
    final int month = _focusedDate.month;

    if (month < 13) {
      setState(() {
        _focusedDate = EtDatetime(year: year, month: month + 1, day: 1);
      });
    } else {
      setState(() {
        _focusedDate = EtDatetime(year: year + 1, month: 1, day: 1);
      });
    }
  }

  String _monthGeezName(int month) {
    const monthsGeez = [
      'መስከረም', // 1
      'ጥቅምት',   // 2
      'ህዳር',    // 3
      'ታህሳስ',   // 4
      'ጥር',     // 5
      'የካቲት',  // 6
      'መጋቢት',  // 7
      'ሚያዝያ',  // 8
      'ግንቦት',  // 9
      'ሰኔ',     // 10
      'ሐምሌ',    // 11
      'ነሐሴ',    // 12
      'ጳጕሜ'     // 13
    ];
    return monthsGeez[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInFocusedMonth();
    final String title = '${_monthGeezName(_focusedDate.month)} ${_focusedDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(icon: const Icon(Icons.navigate_before), onPressed: _goToPrevMonth),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: _goToNextMonth),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('ሰ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('ማ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('ረ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('ሐ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('አ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('ቅ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('እ', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final bool isSelected =
                    day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                    Navigator.pop(context, day);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
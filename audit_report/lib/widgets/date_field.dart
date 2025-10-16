import 'package:flutter/material.dart';

class DateField extends StatefulWidget {
  final Function(String?) onChanged;
  final String? initialValue;
  final String? hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateField({
    Key? key,
    required this.onChanged,
    this.initialValue,
    this.hintText = 'DD/MM/YYYY',
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeDate();
  }

  void _initializeDate() {
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      if (widget.initialValue!.contains('-')) {
        // ISO format - parse and convert to dd/mm/yyyy
        try {
          _selectedDate = DateTime.parse(widget.initialValue!);
          _controller.text = _formatDate(_selectedDate!);
        } catch (e) {
          _controller.text = widget.initialValue!;
        }
      } else {
        // Already in dd/mm/yyyy format
        _controller.text = widget.initialValue!;
        // Try to parse for _selectedDate
        try {
          List<String> parts = widget.initialValue!.split('/');
          if (parts.length == 3) {
            _selectedDate = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          }
        } catch (e) {
          // If parsing fails, try to use the value as-is
          _controller.text = widget.initialValue!;
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        _controller.text = _formatDate(selectedDate);
      });

      // Return ISO format for storage
      widget.onChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        suffixIcon: Icon(Icons.calendar_today, size: 18),
        hintText: widget.hintText,
      ),
      style: TextStyle(fontSize: 14),
      onTap: _selectDate,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

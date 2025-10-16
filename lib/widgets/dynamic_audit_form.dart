import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/base_audit_model.dart';

class DynamicAuditForm extends StatefulWidget {
  final BaseAuditForm auditForm;
  final Map<String, TextEditingController> controllers;
  final Function(String, String) onFieldChanged;
  final String formTitle;
  final List<Map<String, dynamic>> formFields;

  const DynamicAuditForm({
    Key? key,
    required this.auditForm,
    required this.controllers,
    required this.onFieldChanged,
    required this.formTitle,
    required this.formFields,
  }) : super(key: key);

  @override
  _DynamicAuditFormState createState() => _DynamicAuditFormState();
}

class _DynamicAuditFormState extends State<DynamicAuditForm> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form title
            Text(
              widget.formTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 24),

            // Common header fields
            _buildHeaderSection(),
            SizedBox(height: 24),

            // Dynamic form fields
            ...widget.formFields.map((section) => _buildSection(section)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers['serialNumber'],
                    decoration: InputDecoration(
                      labelText: 'Serial Number',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true, // Serial number is auto-generated
                    onChanged: (value) =>
                        widget.onFieldChanged('serialNumber', value),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Audit Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_formatDate(widget.auditForm.auditDate)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers['auditorName'],
                    decoration: InputDecoration(
                      labelText: 'Auditor Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        widget.onFieldChanged('auditorName', value),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers['verifiedBy'],
                    decoration: InputDecoration(
                      labelText: 'Verified By',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        widget.onFieldChanged('verifiedBy', value),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers['shift'],
                    decoration: InputDecoration(
                      labelText: 'Shift',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => widget.onFieldChanged('shift', value),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers['po'],
                    decoration: InputDecoration(
                      labelText: 'PO Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => widget.onFieldChanged('po', value),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: widget.controllers['moduleType'],
              decoration: InputDecoration(
                labelText: 'Module Type',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => widget.onFieldChanged('moduleType', value),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final title = section['title'] as String;
    final fields = section['fields'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 16),
                ...fields.map<Widget>((field) => _buildField(field)),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final name = field['name'] as String;
    final label = field['label'] as String;
    final type = field['type'] as String;

    switch (type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            controller: widget.controllers[name],
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.onFieldChanged(name, value),
          ),
        );
      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            controller: widget.controllers[name],
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => widget.onFieldChanged(name, value),
          ),
        );
      case 'dropdown':
        final options = field['options'] as List<dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
            value: widget.controllers[name]!.text.isNotEmpty
                ? widget.controllers[name]!.text
                : null,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            items: options.map<DropdownMenuItem<String>>((option) {
              return DropdownMenuItem<String>(
                value: option as String,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.controllers[name]!.text = value;
                widget.onFieldChanged(name, value);
              }
            },
          ),
        );
      case 'multiline':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            controller: widget.controllers[name],
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => widget.onFieldChanged(name, value),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(widget.auditForm.auditDate);
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formattedDate = picked.toIso8601String();
      widget.onFieldChanged('auditDate', formattedDate);
      setState(() {});
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return _dateFormat.format(date);
    } catch (e) {
      return 'Select Date';
    }
  }
}

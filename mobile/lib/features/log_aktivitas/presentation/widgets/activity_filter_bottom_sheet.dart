import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/user_role.dart';

class ActivityFilterBottomSheet extends StatefulWidget {
  final List<UserRole> selectedRoles;
  final DateTime? startDate;
  final DateTime? endDate;

  const ActivityFilterBottomSheet({
    super.key,
    required this.selectedRoles,
    this.startDate,
    this.endDate,
  });

  @override
  State<ActivityFilterBottomSheet> createState() =>
      _ActivityFilterBottomSheetState();
}

class _ActivityFilterBottomSheetState extends State<ActivityFilterBottomSheet> {
  late List<UserRole> _selectedRoles;
  DateTime? _startDate;
  DateTime? _endDate;
  UserRole? _selectedAktor;

  @override
  void initState() {
    super.initState();
    _selectedRoles = List.from(widget.selectedRoles);
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedAktor = _selectedRoles.isNotEmpty ? _selectedRoles.first : null;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6EE7B7),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6EE7B7),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedRoles.clear();
      _selectedAktor = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _apply() {
    final roles = _selectedAktor != null ? [_selectedAktor!] : <UserRole>[];
    Navigator.pop(context, {
      'roles': roles,
      'startDate': _startDate,
      'endDate': _endDate,
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 50,
            offset: Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  width: 1.25,
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Filter Log Aktivitas',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aktor Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aktor',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1.25,
                          color: const Color(0xFFE2E8F0),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<UserRole?>(
                          value: _selectedAktor,
                          isExpanded: true,
                          hint: const Text(
                            'Semua Aktor',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF94A3B8),
                          ),
                          items: [
                            const DropdownMenuItem<UserRole?>(
                              value: null,
                              child: Text('Semua Aktor'),
                            ),
                            ...UserRole.values.map((role) {
                              return DropdownMenuItem<UserRole?>(
                                value: role,
                                child: Text(role.displayName),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedAktor = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dari Tanggal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dari Tanggal',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1.25,
                            color: const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_startDate),
                              style: TextStyle(
                                color: _startDate == null
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF0F172A),
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Color(0xFF6EE7B7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sampai Tanggal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sampai Tanggal',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1.25,
                            color: const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_endDate),
                              style: TextStyle(
                                color: _endDate == null
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF0F172A),
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Color(0xFF6EE7B7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer with buttons
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  width: 1.25,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Terapkan Filter button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EE7B7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Reset and Batal buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6EE7B7),
                            side: const BorderSide(
                              color: Color(0xFF6EE7B7),
                              width: 1.25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Reset Filter',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

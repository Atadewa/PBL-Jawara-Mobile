import 'expense_category.dart';

class ExpenseItem {
  final String id;
  final String title;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String? description;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['nama'] ?? '',
      category: ExpenseCategory.fromString(
        json['category'] ?? json['kategori'] ?? '',
      ),
      amount: (json['amount'] ?? json['jumlah'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : json['tanggal'] != null
              ? DateTime.parse(json['tanggal'])
              : DateTime.now(),
      description: json['description'] ?? json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.label,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get formattedDate {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

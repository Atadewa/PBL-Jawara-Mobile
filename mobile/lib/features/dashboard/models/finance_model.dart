/// Model untuk Finance Dashboard

import 'common_model.dart';

/// Summary keuangan (Pemasukan, Pengeluaran, Saldo)
class FinanceSummary {
  final String totalIncome;
  final String totalExpense;
  final String balance;

  FinanceSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalIncome: json['totalIncome'] ?? '0',
      totalExpense: json['totalExpense'] ?? '0',
      balance: json['balance'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
    };
  }
}

/// Breakdown kategori (untuk pie chart)
class CategoryBreakdown {
  final String category;
  final num amount;
  final String color;

  CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.color,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] ?? '',
      amount: json['amount'] ?? 0,
      color: json['color'] ?? '0xFF6EE7B7',
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'amount': amount, 'color': color};
  }
}

/// Main Finance Dashboard Data
class FinanceDashboardData {
  final FinanceSummary summary;
  final List<MonthlySeries> incomeMonthly; // Data pemasukan per bulan
  final List<MonthlySeries> expenseMonthly; // Data pengeluaran per bulan
  final List<CategoryBreakdown>
  incomeCategories; // Breakdown kategori pemasukan
  final List<CategoryBreakdown>
  expenseCategories; // Breakdown kategori pengeluaran
  final DateTime lastUpdated;

  FinanceDashboardData({
    required this.summary,
    required this.incomeMonthly,
    required this.expenseMonthly,
    required this.incomeCategories,
    required this.expenseCategories,
    required this.lastUpdated,
  });

  factory FinanceDashboardData.fromJson(Map<String, dynamic> json) {
    return FinanceDashboardData(
      summary: FinanceSummary.fromJson(json['summary'] ?? {}),
      incomeMonthly:
          (json['incomeMonthly'] as List?)
              ?.map((m) => MonthlySeries.fromJson(m))
              .toList() ??
          [],
      expenseMonthly:
          (json['expenseMonthly'] as List?)
              ?.map((m) => MonthlySeries.fromJson(m))
              .toList() ??
          [],
      incomeCategories:
          (json['incomeCategories'] as List?)
              ?.map((c) => CategoryBreakdown.fromJson(c))
              .toList() ??
          [],
      expenseCategories:
          (json['expenseCategories'] as List?)
              ?.map((c) => CategoryBreakdown.fromJson(c))
              .toList() ??
          [],
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'incomeMonthly': incomeMonthly.map((m) => m.toJson()).toList(),
      'expenseMonthly': expenseMonthly.map((m) => m.toJson()).toList(),
      'incomeCategories': incomeCategories.map((c) => c.toJson()).toList(),
      'expenseCategories': expenseCategories.map((c) => c.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

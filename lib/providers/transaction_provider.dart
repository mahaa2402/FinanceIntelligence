import 'package:flutter/material.dart';
import 'package:smart_finance_ai/models/transaction.dart';
import 'package:smart_finance_ai/services/ai_suggestion_service.dart';

class TransactionProvider with ChangeNotifier {
  final AiSuggestionService _aiSuggestionService = AiSuggestionService();
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String _error = '';
  List<String> _suggestions = [];

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  List<String> get suggestions => _suggestions;

  // Get total income
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, transaction) => sum + transaction.amount);
  
  // Get total expenses
  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, transaction) => sum + transaction.amount);
  
  // Get current balance
  double get balance => totalIncome - totalExpenses;

  // Get recent transactions
  List<Transaction> get recentTransactions => 
      _transactions.length <= 5 
          ? _transactions 
          : _transactions.sublist(0, 5);

  // Demo data for initial display
  List<Transaction> _getDemoTransactions(String userId) {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        userId: userId,
        amount: 3500.00,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        description: 'Monthly Salary',
        date: DateTime(now.year, now.month, 1),
        createdAt: DateTime.now(),
      ),
      Transaction(
        id: '2',
        userId: userId,
        amount: 120.50,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        description: 'Grocery Shopping',
        date: DateTime(now.year, now.month, 5),
        createdAt: DateTime.now(),
      ),
      Transaction(
        id: '3',
        userId: userId,
        amount: 85.75,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        description: 'Movie Night',
        date: DateTime(now.year, now.month, 10),
        createdAt: DateTime.now(),
      ),
      Transaction(
        id: '4',
        userId: userId,
        amount: 250.00,
        type: TransactionType.expense,
        category: TransactionCategory.utilities,
        description: 'Electricity Bill',
        date: DateTime(now.year, now.month, 15),
        createdAt: DateTime.now(),
      ),
      Transaction(
        id: '5',
        userId: userId,
        amount: 800.00,
        type: TransactionType.expense,
        category: TransactionCategory.housing,
        description: 'Rent Payment',
        date: DateTime(now.year, now.month, 20),
        createdAt: DateTime.now(),
      ),
      Transaction(
        id: '6',
        userId: userId,
        amount: 200.00,
        type: TransactionType.income,
        category: TransactionCategory.investment,
        description: 'Stock Dividends',
        date: DateTime(now.year, now.month, 22),
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Load user transactions (Demo)
  Future<void> loadTransactions(String userId) async {
    if (userId.isEmpty) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Use demo data instead of Firebase
      _transactions = _getDemoTransactions(userId);
      
      // Sort by date (newest first)
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      
      // Generate spending suggestions based on transactions
      if (_transactions.isNotEmpty) {
        _suggestions = await _aiSuggestionService.generateSuggestions(
          _transactions, 
          totalIncome, 
          totalExpenses
        );
      } else {
        _suggestions = ['Start adding transactions to get AI-powered suggestions!'];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load transactions: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add a new transaction (Demo)
  Future<void> addTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Add to local list (instead of Firebase)
      _transactions.insert(0, transaction);
      
      // Generate new suggestions
      if (_transactions.isNotEmpty) {
        _suggestions = await _aiSuggestionService.generateSuggestions(
          _transactions, 
          totalIncome, 
          totalExpenses
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add transaction: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete a transaction (Demo)
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Remove from local list (instead of Firebase)
      _transactions.removeWhere((transaction) => transaction.id == transactionId);
      
      // Generate new suggestions
      if (_transactions.isNotEmpty) {
        _suggestions = await _aiSuggestionService.generateSuggestions(
          _transactions, 
          totalIncome, 
          totalExpenses
        );
      } else {
        _suggestions = ['Start adding transactions to get AI-powered suggestions!'];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete transaction: ${e.toString()}';
      notifyListeners();
    }
  }

  // Get transactions by category
  Map<TransactionCategory, double> getExpensesByCategory() {
    final Map<TransactionCategory, double> result = {};
    
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        final double currentAmount = result[transaction.category] ?? 0;
        result[transaction.category] = currentAmount + transaction.amount;
      }
    }
    
    return result;
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}

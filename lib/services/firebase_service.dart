import 'package:smart_finance_ai/models/transaction.dart';
import 'package:smart_finance_ai/models/user_profile.dart';

// Demo service to replace Firebase functionality
class FirebaseService {
  // In-memory storage for demo purposes
  final Map<String, UserProfile> _users = {};
  final List<Transaction> _transactions = [];
  
  // User Profile Methods
  
  // Get a user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return _users[userId];
  }
  
  // Create a new user profile
  Future<void> createUserProfile(String userId, UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    _users[userId] = profile;
  }
  
  // Update a user profile
  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    _users[userId] = profile;
  }
  
  // Transaction Methods
  
  // Get all transactions for a user
  Future<List<Transaction>> getUserTransactions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 700)); // Simulate network delay
    return _transactions
        .where((transaction) => transaction.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }
  
  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    _transactions.add(transaction);
  }
  
  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    _transactions.removeWhere((transaction) => transaction.id == transactionId);
  }
  
  // Update a transaction
  Future<void> updateTransaction(String transactionId, Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }
  
  // Get transactions by category for a user
  Future<List<Transaction>> getTransactionsByCategory(
    String userId,
    TransactionCategory category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    return _transactions
        .where((transaction) => 
            transaction.userId == userId && 
            transaction.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }
  
  // Get transactions by date range for a user
  Future<List<Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    return _transactions
        .where((transaction) => 
            transaction.userId == userId && 
            transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }
}

import 'package:smart_finance_ai/models/transaction.dart';

class AiSuggestionService {
  // Generate AI-powered spending suggestions based on user's transactions
  Future<List<String>> generateSuggestions(
    List<Transaction> transactions,
    double totalIncome,
    double totalExpenses,
  ) async {
    // In a real app, this would use machine learning or call an AI API
    // For now, we'll implement some basic logic to generate suggestions
    
    List<String> suggestions = [];
    
    try {
      // Check if expenses are greater than income
      if (totalExpenses > totalIncome) {
        suggestions.add('Your expenses exceed your income. Consider reducing spending to avoid debt.');
      }
      
      // Calculate spending by category
      Map<TransactionCategory, double> expensesByCategory = {};
      
      for (var transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          final double currentAmount = expensesByCategory[transaction.category] ?? 0;
          expensesByCategory[transaction.category] = currentAmount + transaction.amount;
        }
      }
      
      // Find the highest spending category
      TransactionCategory? highestCategory;
      double highestAmount = 0;
      
      expensesByCategory.forEach((category, amount) {
        if (amount > highestAmount) {
          highestAmount = amount;
          highestCategory = category;
        }
      });
      
      if (highestCategory != null) {
        // Calculate percentage of total expenses
        double percentage = (highestAmount / totalExpenses) * 100;
        
        if (percentage > 30) {
          suggestions.add('You\'re spending ${percentage.toStringAsFixed(0)}% of your expenses on ${_getCategoryName(highestCategory!)}. Consider setting a budget for this category.');
        }
      }
      
      // Check for frequent small expenses (e.g., food, entertainment)
      if (expensesByCategory[TransactionCategory.food] != null) {
        double foodExpenses = expensesByCategory[TransactionCategory.food]!;
        if (foodExpenses > totalIncome * 0.2) {
          suggestions.add('Your food expenses are high. Try meal planning to reduce dining costs.');
        }
      }
      
      if (expensesByCategory[TransactionCategory.entertainment] != null) {
        double entertainmentExpenses = expensesByCategory[TransactionCategory.entertainment]!;
        if (entertainmentExpenses > totalIncome * 0.1) {
          suggestions.add('Consider looking for free or low-cost entertainment options to reduce spending.');
        }
      }
      
      // Savings suggestions
      if (totalIncome > totalExpenses) {
        double savingsRate = (totalIncome - totalExpenses) / totalIncome * 100;
        if (savingsRate < 10) {
          suggestions.add('Try to save at least 10% of your income. You\'re currently saving ${savingsRate.toStringAsFixed(1)}%.');
        } else {
          suggestions.add('Great job! You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income.');
        }
      }
      
      // If we don't have enough data or no specific suggestions
      if (suggestions.isEmpty) {
        if (transactions.length < 5) {
          suggestions.add('Add more transactions to get personalized spending suggestions.');
        } else {
          suggestions.add('Your spending patterns look balanced. Keep it up!');
        }
      }
      
      return suggestions;
    } catch (e) {
      return ['Add more transactions to get personalized spending suggestions.'];
    }
  }
  
  String _getCategoryName(TransactionCategory category) {
    String name = category.toString().split('.').last;
    // Capitalize first letter and add spaces before uppercase letters
    name = name[0].toUpperCase() + name.substring(1).replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    );
    
    return name;
  }
}

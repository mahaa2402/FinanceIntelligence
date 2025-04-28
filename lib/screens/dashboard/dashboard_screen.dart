import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_finance_ai/models/transaction.dart';
import 'package:smart_finance_ai/providers/auth_provider.dart';
import 'package:smart_finance_ai/providers/transaction_provider.dart';
import 'package:smart_finance_ai/screens/transactions/add_transaction_screen.dart';
import 'package:smart_finance_ai/utils/theme.dart';
import 'package:smart_finance_ai/widgets/suggestion_card.dart';
import 'package:smart_finance_ai/widgets/transaction_card.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final currencyFormatter = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    // Load transactions when the dashboard is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions(userId);
    });
  }

  void _signOut() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Dashboard' : 
          _currentIndex == 1 ? 'Transactions' : 'Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex <= 1 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildTransactions();
      case 2:
        return _buildProfile();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final isLoading = transactionProvider.isLoading;
    
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          _buildBalanceCard(),
          const SizedBox(height: 24),
          
          // AI Suggestions Section
          const Text(
            'AI Suggestions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildSuggestionsList(),
          const SizedBox(height: 24),
          
          // Spending Chart
          _buildSpendingChart(),
          const SizedBox(height: 24),
          
          // Recent Transactions Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // Switch to transactions tab
                  });
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormatter.format(transactionProvider.balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Income Card
                Expanded(
                  child: _buildFinanceSummaryCard(
                    'Income',
                    transactionProvider.totalIncome,
                    Icons.arrow_upward,
                    Colors.green.shade400,
                  ),
                ),
                const SizedBox(width: 16),
                // Expense Card
                Expanded(
                  child: _buildFinanceSummaryCard(
                    'Expenses',
                    transactionProvider.totalExpenses,
                    Icons.arrow_downward,
                    Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceSummaryCard(String title, double amount, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormatter.format(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final suggestions = transactionProvider.suggestions;
    
    if (suggestions.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Add more transactions to get personalized suggestions',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Column(
      children: suggestions.map((suggestion) {
        return SuggestionCard(
          suggestion: suggestion,
        );
      }).toList(),
    );
  }

  Widget _buildSpendingChart() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final expensesByCategory = transactionProvider.getExpensesByCategory();
    
    if (expensesByCategory.isEmpty) {
      return const SizedBox(); // Don't show chart if no data
    }
    
    // Prepare data for the chart
    List<PieChartSectionData> sections = [];
    final List<Color> categoryColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
      Colors.lime,
    ];
    
    int colorIndex = 0;
    expensesByCategory.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          color: categoryColors[colorIndex % categoryColors.length],
          value: amount,
          title: '',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: expensesByCategory.entries.map((entry) {
            final index = expensesByCategory.keys.toList().indexOf(entry.key);
            final color = categoryColors[index % categoryColors.length];
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.key.toString().split('.').last,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${currencyFormatter.format(entry.value)})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final recentTransactions = transactionProvider.recentTransactions;
    
    if (recentTransactions.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No transactions yet. Tap the + button to add a transaction.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Column(
      children: recentTransactions.map((transaction) {
        return TransactionCard(
          transaction: transaction,
          onDelete: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            transactionProvider.deleteTransaction(
              authProvider.userId,
              transaction.id,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildTransactions() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final allTransactions = transactionProvider.transactions;
    final isLoading = transactionProvider.isLoading;
    
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (allTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a transaction',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allTransactions.length,
      itemBuilder: (context, index) {
        final transaction = allTransactions[index];
        return TransactionCard(
          transaction: transaction,
          onDelete: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            transactionProvider.deleteTransaction(
              authProvider.userId,
              transaction.id,
            );
          },
        );
      },
    );
  }

  Widget _buildProfile() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Profile Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          // User Info
          Text(
            userProfile?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userProfile?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // Profile Settings
          _buildProfileMenuItem(
            'Edit Profile',
            Icons.edit,
            () {
              // Edit profile action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile feature coming soon!')),
              );
            },
          ),
          _buildProfileMenuItem(
            'Notification Settings',
            Icons.notifications,
            () {
              // Notification settings action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon!')),
              );
            },
          ),
          _buildProfileMenuItem(
            'Budget Settings',
            Icons.account_balance_wallet,
            () {
              // Budget settings action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget Settings feature coming soon!')),
              );
            },
          ),
          _buildProfileMenuItem(
            'Security & Privacy',
            Icons.security,
            () {
              // Security settings action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security Settings feature coming soon!')),
              );
            },
          ),
          _buildProfileMenuItem(
            'Help & Support',
            Icons.help,
            () {
              // Help action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support feature coming soon!')),
              );
            },
          ),
          const SizedBox(height: 24),
          // Sign Out Button
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

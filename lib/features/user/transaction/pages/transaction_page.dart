import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/components/navbar.dart';
import 'package:foodapin/data/models/transaction.dart';
import 'package:foodapin/features/user/transaction/bloc/transaction_bloc.dart';
import 'package:foodapin/features/user/transaction/bloc/transaction_event.dart';
import 'package:foodapin/features/user/transaction/bloc/transaction_state.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const int _currentIndex = 1; // Changed to const for better performance
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<TransactionBloc>().add(FetchTransaction());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  List<Transaction> _getFilteredTransactions(List<Transaction> transactions, String status) {
    if (status == 'All') return transactions;
    return transactions.where((t) => t.status.toLowerCase() == status.toLowerCase()).toList();
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.92;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: Row(
                children: [
                  Text(
                    'My Transactions',
                    style: AppTheme.headingStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha:0.2)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelColor: AppTheme.primary,
                unselectedLabelColor: Colors.grey,
                labelStyle: AppTheme.bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: AppTheme.bodyStyle.copyWith(fontSize: 12),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Success'),
                  Tab(text: 'Canceled'),
                  Tab(text: 'Failed'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return Center(
                      child:Lottie.asset(
                        'assets/loading.json',
                        width: 200,
                        height: 200,
                        repeat: true,
                      ),
                    );
                  }
                  
                  if (state is TransactionError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: AppTheme.bodyStyle.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TransactionBloc>().add(FetchTransaction());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: AppTheme.buttonStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is TransactionLoaded) {
                    return RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: () async {
                        context.read<TransactionBloc>().add(FetchTransaction());
                      },
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTransactionList(state.transaction, 'All', screenWidth),
                          _buildTransactionList(state.transaction, 'Pending', screenWidth),
                          _buildTransactionList(state.transaction, 'Success', screenWidth),
                          _buildTransactionList(state.transaction, 'Canceled', screenWidth),
                          _buildTransactionList(state.transaction, 'Failed', screenWidth),
                        ],
                      ),
                    );
                  }
                  
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: CurvedBottomNavBar(
          currentIndex: _currentIndex, 
          onTap: (index) {
            if (index == _currentIndex) return;
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/my-transactions');
            } else if (index == 2) {
              Navigator.pushReplacementNamed(context, '/my-likes');
            } else if (index == 3) {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          }
        ),
      ),
    );
  }
  
  Widget _buildTransactionList(List<Transaction> allTransactions, String status, double screenWidth) {
    final transactions = _getFilteredTransactions(allTransactions, status);
    
    if (transactions.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    return Center(
      child: SizedBox(
        width: screenWidth,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        ),
      ),
    );
  }
  
  Widget _buildTransactionCard(Transaction transaction) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/my-transaction-detail',
          arguments : transaction.id
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.invoiceId,
                        style: AppTheme.cardTitle.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(transaction.orderDate),
                        style: AppTheme.cardBody.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(transaction.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(transaction.status),
                    style: AppTheme.cardBody.copyWith(
                      color: _getStatusColor(transaction.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            ...transaction.items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.fastfood,
                            color: AppTheme.primary,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTheme.cardBody.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity}x',
                          style: AppTheme.cardBody.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###').format(item.price * item.quantity)}',
                    style: AppTheme.cardBody.copyWith(
                      color:AppTheme.secondary,
                     fontSize: 12,
                    ),
                  ),
                ],
              ),
            )),
            
            if (transaction.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${transaction.items.length - 2} more items',
                  style: AppTheme.cardBody.copyWith(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Payment',
                      style: AppTheme.cardBody.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${NumberFormat('#,###').format(transaction.totalAmount)}',
                      style: AppTheme.cardTitle.copyWith(
                        color: AppTheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/my-transaction-detail', arguments: transaction.id);
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


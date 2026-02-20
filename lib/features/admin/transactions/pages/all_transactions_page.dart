import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/components/navbar_admin.dart';
import 'package:foodapin/data/models/transaction.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/features/admin/transactions/bloc/all_transactions/transactions_bloc.dart';
import 'package:foodapin/features/admin/transactions/bloc/all_transactions/transactions_event.dart';
import 'package:foodapin/features/admin/transactions/bloc/all_transactions/transactions_state.dart';
import 'package:foodapin/features/admin/transactions/bloc/update_status/update_status_bloc.dart';
import 'package:foodapin/features/admin/transactions/bloc/update_status/update_status_event.dart';
import 'package:foodapin/features/admin/transactions/bloc/update_status/update_status_state.dart';
import 'package:intl/intl.dart';

class AllTransactionsPage extends StatelessWidget {
  const AllTransactionsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TransactionsBloc(transactionRepository: context.read<TransactionRepository>())
                ..add(FetchTransactions()),
        ),
        BlocProvider(
          create: (context) => UpdateTransactionStatusBloc(
            transactionRepository: context.read<TransactionRepository>(),
          ),
        ),
      ],
      child: const _AllTransactionsView(),
    );
  }
}

class _AllTransactionsView extends StatefulWidget {
  const _AllTransactionsView();

  @override
  State<_AllTransactionsView> createState() => _AllTransactionsViewState();
}

class _AllTransactionsViewState extends State<_AllTransactionsView> {
  String _selectedFilter = 'All';
    final int _currentIndex = 2;
  final List<String> _filters = [
    'All',
    'pending',
    'paid',
    'processing',
    'completed',
    'cancelled',
  ];

  List<Transaction> _applyFilter(List<Transaction> transactions) {
    if (_selectedFilter == 'All') return transactions;
    return transactions
        .where((t) => t.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.bodyStyle.copyWith(fontSize: 14, color: AppTheme.white),
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.92;

    return BlocListener<UpdateTransactionStatusBloc, UpdateTransactionStatusState>(
      listener: (context, state) {
        if (state is UpdateTransactionStatusSuccess) {
          _showSnackbar('Status berhasil diperbarui!');
          context.read<TransactionsBloc>().add(RefreshTransactions());
        } else if (state is UpdateTransactionStatusFailure) {
          _showSnackbar(state.message, isError: true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('All Transactions', style: AppTheme.headingStyle),
                      const Spacer(),
                      BlocBuilder<TransactionsBloc, TransactionsState>(
                        builder: (context, state) {
                          return InkWell(
                            onTap: state is TransactionsLoading
                                ? null
                                : () => context
                                    .read<TransactionsBloc>()
                                    .add(RefreshTransactions()),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.refresh,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : AppTheme.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              filter == 'All' ? 'All' : _capitalize(filter),
                              style: AppTheme.cardTitle.copyWith(
                                color:
                                    isSelected ? AppTheme.white : AppTheme.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<TransactionsBloc, TransactionsState>(
                      builder: (context, state) {
                        if (state is TransactionsLoading ||
                            state is TransactionsInitial) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary),
                          );
                        } else if (state is TransactionsError) {
                          return _buildError(context, state.message);
                        } else if (state is TransactionsLoaded) {
                          final filtered = _applyFilter(state.transactions);
                          if (filtered.isEmpty) return _buildEmpty();
                          return RefreshIndicator(
                            color: AppTheme.primary,
                            onRefresh: () async {
                              context
                                  .read<TransactionsBloc>()
                                  .add(RefreshTransactions());
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemBuilder: (context, index) {
                                return _TransactionCard(
                                    transaction: filtered[index]);
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
        child:CurvedBottomNavBarAdmin(
          currentIndex: _currentIndex, 
          onTap: (index){
            if (index == _currentIndex) return;
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/foods');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/users');
            } else if (index == 2) {
              Navigator.pushReplacementNamed(context, '/transactions'); 
            } else if (index == 3) {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          }
        ) ,
      ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message, style: AppTheme.bodyStyle, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () =>
                context.read<TransactionsBloc>().add(FetchTransactions()),
            child: Text('Retry', style: AppTheme.buttonStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: AppTheme.primary, size: 48),
          ),
          const SizedBox(height: 16),
          Text('No transactions found',
              style: AppTheme.headingStyle.copyWith(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            'There are no transactions for this filter.',
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────
// Transaction Card
// ─────────────────────────────────────────────

class _TransactionCard extends StatefulWidget {
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard> {
  bool _isExpanded = false;

  static const List<String> _statusOptions = [
    'pending',
    'success',
    'cancelled',
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green.shade600;
      case 'pending':
        return Colors.amber.shade700;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatCurrency(int amount) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}';

  String _formatDate(DateTime date) =>
      DateFormat('d MMM yyyy, HH:mm').format(date);

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _showUpdateStatusSheet(BuildContext pageContext) {
    final tx = widget.transaction;
    showModalBottomSheet(
      context: pageContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return BlocConsumer<UpdateTransactionStatusBloc,
            UpdateTransactionStatusState>(
          bloc: pageContext.read<UpdateTransactionStatusBloc>(),
          listener: (_, state) {
            // Sheet auto-dismissed on tap; nothing extra needed here
          },
          builder: (_, state) {
            final isLoading = state is UpdateTransactionStatusLoading;
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Update Status',
                      style: AppTheme.headingStyle.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    tx.invoiceId,
                    style: AppTheme.cardBody.copyWith(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child:
                            CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    )
                  else
                    ..._statusOptions.map((status) {
                      final isCurrent =
                          tx.status.toLowerCase() == status;
                      final color = _statusColor(status);
                      return GestureDetector(
                        onTap: isCurrent
                            ? null
                            : () {
                                Navigator.pop(sheetContext);
                                pageContext
                                    .read<UpdateTransactionStatusBloc>()
                                    .add(
                                      SubmitUpdateTransactionStatus(
                                        transactionId: tx.id,
                                        status: status,
                                      ),
                                    );
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? color.withValues(alpha: 0.12)
                                : AppTheme.fourtenary,
                            borderRadius: BorderRadius.circular(14),
                            border: isCurrent
                                ? Border.all(color: color, width: 1.5)
                                : Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(_statusIcon(status),
                                  size: 18, color: color),
                              const SizedBox(width: 12),
                              Text(
                                _capitalize(status),
                                style: AppTheme.cardTitle.copyWith(
                                  color:
                                      isCurrent ? color : AppTheme.black,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Current',
                                    style: AppTheme.cardBody.copyWith(
                                        color: color, fontSize: 11),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final statusColor = _statusColor(tx.status);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Main Info ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice + tappable status badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.invoiceId,
                            style: AppTheme.cardTitle.copyWith(
                                fontSize: 13, color: AppTheme.primary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(tx.orderDate),
                            style: AppTheme.cardBody.copyWith(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tap to open update sheet
                    GestureDetector(
                      onTap: () => _showUpdateStatusSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(tx.status),
                                size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              _capitalize(tx.status),
                              style: AppTheme.cardTitle.copyWith(
                                  color: statusColor, fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.expand_more,
                                size: 14, color: statusColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 12),
                // Payment method + total
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.fourtenary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_outlined,
                              size: 14, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            tx.paymentMethod.name,
                            style: AppTheme.cardTitle.copyWith(
                                fontSize: 12, color: AppTheme.black),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: AppTheme.cardBody.copyWith(
                              color: Colors.grey.shade500, fontSize: 11),
                        ),
                        Text(
                          _formatCurrency(tx.totalAmount),
                          style: AppTheme.cardTitle
                              .copyWith(fontSize: 15, color: AppTheme.black),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Items summary
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${tx.items.length} item${tx.items.length > 1 ? 's' : ''}',
                      style: AppTheme.cardBody.copyWith(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Text('·',
                        style: AppTheme.cardBody
                            .copyWith(color: Colors.grey.shade400)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tx.items.map((i) => i.name).join(', '),
                        style: AppTheme.cardBody.copyWith(
                            color: Colors.grey.shade600, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Proof of payment badge
                if (tx.proofPaymentUrl != null &&
                    tx.proofPaymentUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.receipt_outlined,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Proof of payment uploaded',
                        style: AppTheme.cardBody
                            .copyWith(color: Colors.green.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // ── Expand Toggle ──
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.fourtenary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_isExpanded ? 0 : 16),
                  bottomRight: Radius.circular(_isExpanded ? 0 : 16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'Hide Details' : 'View Details',
                    style: AppTheme.cardTitle
                        .copyWith(color: AppTheme.primary, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ),
          // ── Expanded Detail ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text('Order Items',
                            style: AppTheme.titleDetail.copyWith(fontSize: 13)),
                        const SizedBox(height: 10),
                        ...tx.items.map((item) => _buildItemRow(item)),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade100),
                        const SizedBox(height: 8),
                        _buildDetailRow('Order Date', _formatDate(tx.orderDate)),
                        const SizedBox(height: 6),
                        _buildDetailRow(
                            'Expired Date', _formatDate(tx.expiredDate)),
                        const SizedBox(height: 6),
                        _buildDetailRow('User ID', tx.userId, isSmall: true),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(TransactionItem item) {
    final effectivePrice = item.priceDiscount ?? item.price;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.fourtenary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fastfood_outlined,
                    color: AppTheme.primary, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTheme.cardTitle.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  'x${item.quantity}',
                  style: AppTheme.cardBody
                      .copyWith(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.priceDiscount != null)
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(item.price)}',
                  style: AppTheme.cardBody.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(effectivePrice * item.quantity)}',
                style: AppTheme.cardTitle
                    .copyWith(fontSize: 13, color: AppTheme.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSmall = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTheme.cardBody
                .copyWith(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.cardTitle.copyWith(
              fontSize: isSmall ? 11 : 12,
              color: isSmall ? Colors.grey.shade600 : AppTheme.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
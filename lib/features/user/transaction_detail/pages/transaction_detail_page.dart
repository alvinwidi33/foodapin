import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/models/transaction.dart';
import 'package:foodapin/data/repositories/rating_repository/rating_repository.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'package:foodapin/features/user/transaction_detail/bloc/rating/rating_bloc.dart';
import 'package:foodapin/features/user/transaction_detail/bloc/rating/rating_event.dart';
import 'package:foodapin/features/user/transaction_detail/bloc/rating/rating_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isLoading = false;
  bool _isUploading = false;
  Transaction? _transaction;
  late String transactionId;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      transactionId = ModalRoute.of(context)!.settings.arguments as String;
      _loadTransactionDetail();
      _isFirstLoad = false;
    }
  }

  Future<void> _loadTransactionDetail() async {
    setState(() => _isLoading = true);
    try {
      final response = await context
          .read<TransactionRepository>()
          .getTransactionById(transactionId);
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _transaction = response.data;
        }
      });
      if (!response.success) {
        _showErrorDialog(response.message ?? 'Failed to load transaction');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error: ${e.toString()}');
    }
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = image);
        _showUploadConfirmation();
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _uploadProofPayment() async {
    if (_selectedImage == null || _transaction == null) {
      _showErrorDialog('Please select an image first');
      return;
    }
    setState(() => _isUploading = true);
    try {
      final uploadResponse =
          await context.read<UploadRepository>().uploadImage(_selectedImage!);
      if (!uploadResponse.success || uploadResponse.data == null) {
        setState(() => _isUploading = false);
        _showErrorDialog(uploadResponse.message ?? 'Upload failed');
        return;
      }
      final response = await context
          .read<TransactionRepository>()
          .uploadProofPayment(
            transactionId: _transaction!.id,
            proofPaymentUrl: uploadResponse.data!,
          );
      setState(() => _isUploading = false);
      if (response.success) {
        setState(() => _selectedImage = null);
        await _loadTransactionDetail();
        _showSuccessDialog(response.message ?? 'Proof uploaded successfully');
      } else {
        _showErrorDialog(response.message ?? 'Failed to update transaction');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  Future<void> _cancelTransaction() async {
    if (_transaction == null) return;
    final confirmed = await _showCancelConfirmation();
    if (!confirmed) return;
    setState(() => _isLoading = true);
    try {
      final response = await context
          .read<TransactionRepository>()
          .cancelTransaction(_transaction!.id);
      setState(() => _isLoading = false);
      if (response.success) {
        _showSuccessDialog('Transaction cancelled successfully!',
            shouldPop: true);
      } else {
        _showErrorDialog(response.message ?? 'Failed to cancel transaction');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _showRatingSheet(TransactionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (ctx) =>
            RatingBloc(ratingRepository: ctx.read<RatingRepository>()),
        child: _RatingSheet(item: item),
      ),
    );
  }

  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Cancel Transaction', style: AppTheme.titleDetail),
            content: Text(
              'Are you sure you want to cancel this transaction? This action cannot be undone.',
              style: AppTheme.bodyStyle,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No',
                    style: AppTheme.bodyStyle.copyWith(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes, Cancel',
                    style: AppTheme.bodyStyle.copyWith(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showUploadConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Upload Payment Proof', style: AppTheme.titleDetail),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text('Upload this image as payment proof?',
                style: AppTheme.bodyStyle, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedImage = null);
              Navigator.pop(context);
            },
            child: Text('Cancel',
                style: AppTheme.bodyStyle.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadProofPayment();
            },
            child: Text('Upload',
                style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text('Error', style: AppTheme.titleDetail),
        ]),
        content: Text(message, style: AppTheme.bodyStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message, {bool shouldPop = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text('Success', style: AppTheme.titleDetail),
        ]),
        content: Text(message, style: AppTheme.bodyStyle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (shouldPop) Navigator.pop(context, true);
            },
            child: Text('OK',
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.92;

    final status = _transaction?.status.toLowerCase() ?? '';
    final isPending = status == 'pending';
    final isSuccess = status == 'success' || status == 'success';
    final hasProof = _transaction?.proofPaymentUrl != null &&
        _transaction!.proofPaymentUrl!.isNotEmpty;

    final showRating = (isPending && hasProof) || isSuccess;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Text('Transaction Detail', style: AppTheme.headingStyle),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary))
                      : _transaction == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text('Failed to load transaction',
                                      style: AppTheme.bodyStyle.copyWith(
                                          color: Colors.grey.shade600)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadTransactionDetail,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary),
                                    child: Text('Retry',
                                        style: AppTheme.buttonStyle),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: AppTheme.primary,
                              onRefresh: _loadTransactionDetail,
                              child: SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: Center(
                                  child: SizedBox(
                                    width: screenWidth,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── Status ──
                                        _StatusCard(
                                          transaction: _transaction!,
                                          getStatusColor: _getStatusColor,
                                          getStatusText: _getStatusText,
                                        ),
                                        const SizedBox(height: 16),

                                        _SectionCard(
                                          title: 'Order Information',
                                          child: Column(children: [
                                            _buildInfoRow(
                                              'Order Date',
                                              DateFormat('dd MMM yyyy, HH:mm')
                                                  .format(
                                                      _transaction!.orderDate),
                                            ),
                                            _buildInfoRow(
                                              'Expired Date',
                                              DateFormat('dd MMM yyyy, HH:mm')
                                                  .format(
                                                      _transaction!.expiredDate),
                                            ),
                                            _buildInfoRow(
                                              'Payment Method',
                                              _transaction!.paymentMethod.name,
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(height: 16),

                                        // ── Order Items ──
                                        _SectionCard(
                                          title: 'Order Items',
                                          child: Column(
                                            children: _transaction!.items
                                                .map((item) =>
                                                    _buildItemRow(item))
                                                .toList(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // ── Payment Summary ──
                                        _SectionCard(
                                          title: 'Payment Summary',
                                          child: Column(children: [
                                            _buildSummaryRow(
                                              'Subtotal',
                                              'Rp ${NumberFormat('#,###').format(_transaction!.totalAmount)}',
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(),
                                            const SizedBox(height: 12),
                                            _buildSummaryRow(
                                              'Total Payment',
                                              'Rp ${NumberFormat('#,###').format(_transaction!.totalAmount)}',
                                              isTotal: true,
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(height: 24),

                                        // ── Action area ──
                                        if (isPending && !hasProof) ...[
                                          // Belum upload proof → tombol upload + cancel
                                          SizedBox(
                                            width: double.infinity,
                                            child: Container(
                                              decoration:
                                                  AppTheme.buttonDecorationPrimary,
                                              child: ElevatedButton(
                                                onPressed: _isUploading
                                                    ? null
                                                    : _pickImage,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            28),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 16),
                                                ),
                                                child: _isUploading
                                                    ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: AppTheme.white,
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : Text('Upload Payment Proof',
                                                        style:
                                                            AppTheme.buttonStyle),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed:
                                                  _isLoading || _isUploading
                                                      ? null
                                                      : _cancelTransaction,
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: Colors.red, width: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(28),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                              ),
                                              child: Text(
                                                'Cancel Transaction',
                                                style: AppTheme.buttonStyle
                                                    .copyWith(color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ],

                                        // Proof sudah ada / sudah success → rating section
                                        if (showRating) ...[
                                          _RateItemsSection(
                                            items: _transaction!.items,
                                            onRateTap: _showRatingSheet,
                                          ),
                                        ],

                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
          if (_isLoading && _transaction != null)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(TransactionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.fastfood,
                    color: AppTheme.primary, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTheme.cardTitle.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}x @ Rp ${NumberFormat('#,###').format(item.price)}',
                  style: AppTheme.cardBody
                      .copyWith(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,###').format(item.price * item.quantity)}',
            style: AppTheme.cardBody
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTheme.bodyStyle
                  .copyWith(color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: AppTheme.bodyStyle
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.black : Colors.grey.shade600,
            )),
        Text(value,
            style: AppTheme.titleDetail.copyWith(
              fontSize: isTotal ? 18 : 13,
              color: isTotal ? AppTheme.primary : AppTheme.secondary,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Rate Items Section
// ─────────────────────────────────────────────

class _RateItemsSection extends StatelessWidget {
  final List<TransactionItem> items;
  final void Function(TransactionItem) onRateTap;

  const _RateItemsSection({required this.items, required this.onRateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Rate Your Order', style: AppTheme.titleDetail),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bagikan pengalamanmu untuk setiap item',
            style: AppTheme.cardBody
                .copyWith(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
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
                      child: Text(item.name,
                          style: AppTheme.cardTitle.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onRateTap(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_outline,
                                size: 14, color: AppTheme.white),
                            const SizedBox(width: 4),
                            Text('Rate',
                                style: AppTheme.cardTitle.copyWith(
                                    color: AppTheme.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Status Card
// ─────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final Transaction transaction;
  final Color Function(String) getStatusColor;
  final String Function(String) getStatusText;

  const _StatusCard({
    required this.transaction,
    required this.getStatusColor,
    required this.getStatusText,
  });

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(transaction.status);
    final isSuccess = transaction.status.toLowerCase() == 'paid' ||
        transaction.status.toLowerCase() == 'success';
    final isPending = transaction.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_circle
                    : isPending
                        ? Icons.access_time
                        : Icons.cancel,
                color: color,
                size: 40,
              ),
            ),
            const SizedBox(height: 12),
            Text(getStatusText(transaction.status),
                style:
                    AppTheme.titleDetail.copyWith(color: color, fontSize: 18)),
            const SizedBox(height: 8),
            Text(transaction.invoiceId,
                style: AppTheme.bodyStyle
                    .copyWith(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.titleDetail),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Rating Sheet
// ─────────────────────────────────────────────

class _RatingSheet extends StatefulWidget {
  final TransactionItem item;

  const _RatingSheet({required this.item});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _rating = 0;
  final TextEditingController _reviewCtrl = TextEditingController();

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating',
              style: AppTheme.bodyStyle
                  .copyWith(color: AppTheme.white, fontSize: 14)),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    context.read<RatingBloc>().add(CreateRatingEvent(
          foodId: widget.item.id,
          rating: _rating,
          review: _reviewCtrl.text.trim(),
        ));
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap a star to rate';
    }
  }

  Color _ratingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red.shade400;
      case 3:
        return Colors.orange.shade400;
      case 4:
      case 5:
        return Colors.amber.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RatingBloc, RatingState>(
      listener: (context, state) {
        if (state is RatingSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully rate food',
                  style: AppTheme.bodyStyle
                      .copyWith(color: AppTheme.white, fontSize: 14)),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is RatingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: AppTheme.bodyStyle
                      .copyWith(color: AppTheme.white, fontSize: 14)),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.item.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.fourtenary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fastfood_outlined,
                          color: AppTheme.primary, size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.name,
                          style: AppTheme.cardTitle.copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Share your experience',
                          style: AppTheme.cardBody.copyWith(
                              color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      starIndex <= _rating ? Icons.star : Icons.star_border,
                      size: starIndex <= _rating ? 40 : 34,
                      color: starIndex <= _rating
                          ? Colors.amber.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _ratingLabel(_rating),
                key: ValueKey(_rating),
                style: AppTheme.cardTitle.copyWith(
                    fontSize: 14, color: _ratingColor(_rating)),
              ),
            ),
            const SizedBox(height: 20),

            // Review field
            Container(
              decoration: BoxDecoration(
                color: AppTheme.fourtenary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _reviewCtrl,
                maxLines: 3,
                maxLength: 300,
                style: AppTheme.cardTitle.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write your review (optional)...',
                  hintStyle: AppTheme.cardBody
                      .copyWith(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: AppTheme.cardBody
                      .copyWith(color: Colors.grey.shade400, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit
            BlocBuilder<RatingBloc, RatingState>(
              builder: (context, state) {
                final isLoading = state is RatingLoading;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor:
                          AppTheme.primary.withValues(alpha: 0.4),
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Submit Rating', style: AppTheme.buttonStyle),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
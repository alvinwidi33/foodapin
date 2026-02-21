import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/models/foods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'dart:io';

import 'package:lottie/lottie.dart';

class CreateFoodPage extends StatefulWidget {
  const CreateFoodPage({super.key});

  @override
  State<CreateFoodPage> createState() => _CreateFoodPageState();
}

class _CreateFoodPageState extends State<CreateFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceDiscountController = TextEditingController();
  final _ingredientController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  String? _uploadedImageUrl;
  final List<String> _ingredients = [];
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _priceDiscountController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _uploadedImageUrl = null;
    });

    await _uploadImage(image);
  }

  Future<void> _uploadImage(XFile file) async {
    setState(() => _isUploadingImage = true);

    final uploadRepository = context.read<UploadRepository>();
    final result = await uploadRepository.uploadImage(file);

    setState(() => _isUploadingImage = false);

    if (result.success && result.data != null) {
      setState(() => _uploadedImageUrl = result.data);
    } else {
      _showSnackbar(result.message ?? 'Upload gagal', isError: true);
    }
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _ingredients.add(text);
      _ingredientController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyStyle.copyWith(fontSize: 14, color: AppTheme.white)),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage != null && _uploadedImageUrl == null) {
      _showSnackbar('Gambar masih diupload, tunggu sebentar', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final food = Foods(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _uploadedImageUrl ?? '',
      ingredients: _ingredients,
      price: int.tryParse(_priceController.text.trim()) ?? 0,
      priceDiscount: int.tryParse(_priceDiscountController.text.trim()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final foodRepository = context.read<FoodRepository>();
    final result = await foodRepository.createFood(food);

    setState(() => _isLoading = false);

    if (result.success) {
      _showSnackbar('Makanan berhasil ditambahkan!');
      Navigator.pop(context, true);
    } else {
      _showSnackbar(result.message ?? 'Gagal menambahkan makanan', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.92;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: screenWidth,
            child: Column(
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
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Add Food', style: AppTheme.headingStyle),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePicker(),
                          const SizedBox(height: 20),
                          _buildLabel('Food Name'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'e.g. Ayam Geprek Sambal Matah',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Description'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _descriptionController,
                            hint: 'Describe the food...',
                            maxLines: 3,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Price (Rp)'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _priceController,
                                      hint: '50000',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Harga wajib diisi' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Discount Price (Rp)'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _priceDiscountController,
                                      hint: 'Optional',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Ingredients'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: AppTheme.inputContainerDecoration,
                                  child: TextField(
                                    controller: _ingredientController,
                                    onSubmitted: (_) => _addIngredient(),
                                    decoration: AppTheme.inputDecoration('e.g. ayam, sambal...').copyWith(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                    ),
                                    style: AppTheme.bodyStyle.copyWith(fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _addIngredient,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.add, color: AppTheme.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                          if (_ingredients.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _ingredients.asMap().entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.tertiary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(entry.value, style: AppTheme.cardTitle.copyWith(color: AppTheme.black)),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _removeIngredient(entry.key),
                                        child: const Icon(Icons.close, size: 14, color: AppTheme.primary),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            decoration: _isLoading
                                ? AppTheme.buttonDecorationDisabled
                                : AppTheme.buttonDecorationPrimary,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20, width: 20,
                                      child: Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true)),
                                    )
                                  : Text('Add Food', style: AppTheme.buttonStyle),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppTheme.fourtenary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.4),
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _selectedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb
                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                        : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                    if (_isUploadingImage)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true)),
                      )
                    else if (_uploadedImageUrl != null)
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: AppTheme.white, size: 16),
                        ),
                      ),
                    Positioned(
                      bottom: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit, color: AppTheme.white, size: 14),
                            const SizedBox(width: 4),
                            Text('Change', style: AppTheme.cardTitle.copyWith(color: AppTheme.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primary, size: 32),
                    ),
                    const SizedBox(height: 10),
                    Text('Tap to upload image', style: AppTheme.bodyStyle.copyWith(
                      fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 4),
                    Text('JPG, PNG supported', style: AppTheme.cardBody.copyWith(color: Colors.grey.shade500)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: AppTheme.titleDetail.copyWith(fontSize: 14));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: AppTheme.inputContainerDecoration,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: AppTheme.inputDecoration(hint).copyWith(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        style: AppTheme.bodyStyle.copyWith(fontSize: 14),
      ),
    );
  }
}
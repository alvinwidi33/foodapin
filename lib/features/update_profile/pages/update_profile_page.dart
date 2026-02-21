import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/models/users.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/update_profile/bloc/update_profile_bloc.dart';
import 'package:foodapin/features/update_profile/bloc/update_profile_event.dart';
import 'package:foodapin/features/update_profile/bloc/update_profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class UpdateProfilePage extends StatelessWidget {
  final Users user;

  const UpdateProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateProfileBloc(userRepository: context.read<UserRepository>(), uploadRepository: context.read<UploadRepository>()),
      child: _UpdateProfileView(user: user),
    );
  }
}

class _UpdateProfileView extends StatefulWidget {
  final Users user;

  const _UpdateProfileView({required this.user});

  @override
  State<_UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<_UpdateProfileView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _passwordRepeatCtrl;
final ImagePicker _picker = ImagePicker();
XFile? _selectedImage;
String? _uploadedImageUrl;
bool _isUploadingImage = false;
  bool _obscurePassword = true;
  bool _obscurePasswordRepeat = true;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phoneNumber);
    _passwordCtrl = TextEditingController();
    _passwordRepeatCtrl = TextEditingController();
    
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordRepeatCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updated = Users(
      id: widget.user.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
        profilePictureUrl:
            _uploadedImageUrl ?? widget.user.profilePictureUrl,      
      role: widget.user.role,
      password: _changePassword ? _passwordCtrl.text : '',
      passwordRepeat: _changePassword ? _passwordRepeatCtrl.text : '',
    );

    context.read<UpdateProfileBloc>().add(SubmitUpdateProfile(updated));
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Upload failed')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateProfileBloc, UpdateProfileState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated!',
                style: AppTheme.bodyStyle
                    .copyWith(color: AppTheme.white, fontSize: 14),
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context, true);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage.toString(),
                style: AppTheme.bodyStyle
                    .copyWith(color: AppTheme.white, fontSize: 14),
              ),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.fourtenary,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: _isUploadingImage ? null : _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                backgroundImage: _selectedImage != null
                                    ? FileImage(File(_selectedImage!.path))
                                    : (_uploadedImageUrl != null
                                        ? NetworkImage(_uploadedImageUrl!)
                                        : (widget.user.profilePictureUrl.isNotEmpty
                                            ? NetworkImage(widget.user.profilePictureUrl)
                                            : null)) as ImageProvider?,
                                child: (_selectedImage == null &&
                                        _uploadedImageUrl == null &&
                                        widget.user.profilePictureUrl.isEmpty)
                                    ? Icon(Icons.person, size: 40, color: AppTheme.primary)
                                    : null,
                              ),
                              if (_isUploadingImage)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true))
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionLabel('Personal Info'),
                      const SizedBox(height: 12),
                      _InfoCard(children: [
                        _buildField(
                          controller: _nameCtrl,
                          label: 'Name',
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                        _fieldDivider(),
                        _buildField(
                          controller: _emailCtrl,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        _fieldDivider(),
                        _buildField(
                          controller: _phoneCtrl,
                          label: 'Phone',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Phone is required'
                              : null,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      _sectionLabel('Security'),
                      const SizedBox(height: 12),
                      _InfoCard(children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _changePassword = !_changePassword),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.lock_outline,
                                      size: 18, color: AppTheme.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Change Password',
                                    style: AppTheme.cardTitle
                                        .copyWith(fontSize: 14),
                                  ),
                                ),
                                Switch(
                                  value: _changePassword,
                                  onChanged: (v) =>
                                      setState(() => _changePassword = v),
                                  activeColor: AppTheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_changePassword) ...[
                          _fieldDivider(),
                          _buildPasswordField(
                            controller: _passwordCtrl,
                            label: 'New Password',
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),
                          _fieldDivider(),
                          _buildPasswordField(
                            controller: _passwordRepeatCtrl,
                            label: 'Confirm Password',
                            obscure: _obscurePasswordRepeat,
                            onToggle: () => setState(() =>
                                _obscurePasswordRepeat =
                                    !_obscurePasswordRepeat),
                            validator: (v) {
                              if (v != _passwordCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ]),

                      const SizedBox(height: 32),
                      _SubmitButton(onTap: _submit),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 18, color: AppTheme.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Edit Profile',
                style: AppTheme.headingStyle.copyWith(color: AppTheme.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: AppTheme.titleDetail.copyWith(fontSize: 14),
      );

  Widget _fieldDivider() => Divider(
        height: 1,
        color: Colors.grey.shade100,
        indent: 16,
        endIndent: 16,
      );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTheme.cardTitle.copyWith(fontSize: 14),
              validator: validator,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: AppTheme.cardBody.copyWith(
                    color: Colors.grey.shade500, fontSize: 11),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                errorStyle: TextStyle(
                    color: Colors.red.shade600, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline,
                size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              style: AppTheme.cardTitle.copyWith(fontSize: 14),
              validator: validator,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: AppTheme.cardBody.copyWith(
                    color: Colors.grey.shade500, fontSize: 11),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: onToggle,
                ),
                errorStyle: TextStyle(
                    color: Colors.red.shade600, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}


class _SubmitButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SubmitButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              disabledBackgroundColor:
                  AppTheme.primary.withValues(alpha: 0.4),
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true))
                : Text(
                    'Save Changes',
                    style: AppTheme.buttonStyle,
                  ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/features/authentication/signup/bloc/signup_bloc.dart';
import 'package:foodapin/features/authentication/signup/bloc/signup_event.dart';
import 'package:foodapin/features/authentication/signup/bloc/signup_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isVisible = false;
  bool isVisibleRepeat = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordRepeatController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
  bool get isPasswordValid {
    final password = passwordController.text.trim();
    final repeat = passwordRepeatController.text.trim();

    return password.length >= 6 && password == repeat;
  }
  String? get passwordError {
    final password = passwordController.text.trim();
    final repeat = passwordRepeatController.text.trim();

    if (password.isEmpty || repeat.isEmpty) return null;
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != repeat) return 'Passwords do not match';
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state){
        if(state is SignUpLoading){
        } else if (state is SignUpSuccess){
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Success Sign up. Redirecting to Sign In Page",
                style: AppTheme.bodyStyle,
              ),
            ),
          );
          Navigator.pushReplacementNamed(context, '/signin');
        } else if (state is SignUpError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Image.asset("assets/logo signin.png"),
                const SizedBox(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.84,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        key: const Key("name_input_text"),
                        height: 56,
                        decoration: AppTheme.inputContainerDecoration,
                        child: TextField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          decoration: AppTheme.inputDecoration("Name"),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        key: const Key("email_input_text"),
                        height: 56,
                        decoration: AppTheme.inputContainerDecoration,
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: AppTheme.inputDecoration("Email"),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        key: const Key("password_input_text"),
                        decoration: AppTheme.inputContainerDecoration,
                        child: TextField(
                          controller: passwordController,
                          obscureText: !isVisible,
                          keyboardType: TextInputType.text,
                          onChanged: (_) => setState(() {}),
                          decoration: AppTheme.inputDecoration("Password").copyWith(
                            errorText: passwordError,
                              errorMaxLines: 2,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisible = !isVisible;
                                  });
                                }, 
                                icon: Icon(
                                  isVisible ? Icons.visibility_off : Icons.visibility,
                                ), style: ButtonStyle(iconColor: WidgetStateProperty.all(Colors.grey)),
                              )
                          ),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        key: const Key("password_repeat_input_text"),
                        decoration: AppTheme.inputContainerDecoration,
                        child: TextField(
                          controller: passwordRepeatController,
                          obscureText: !isVisibleRepeat,
                          keyboardType: TextInputType.text,
                          onChanged: (_) => setState(() {}),
                          decoration: AppTheme.inputDecoration("Password Repeat").copyWith(
                            errorText: passwordError,
                              errorMaxLines: 2,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisibleRepeat = !isVisibleRepeat;
                                  });
                                }, 
                                icon: Icon(
                                  isVisibleRepeat ? Icons.visibility_off : Icons.visibility,
                                ), style: ButtonStyle(iconColor: WidgetStateProperty.all(Colors.grey)),
                              )
                          ),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        key: const Key("phone_number_input_text"),
                        decoration: AppTheme.inputContainerDecoration,
                        child: TextField(
                          controller: phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: AppTheme.inputDecoration("Phone Number"),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already a user?", style: AppTheme.subtitleDetail),
                          SizedBox(width:4),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/my-cart'),
                            child: Text(
                              "Sign In", 
                              style: AppTheme.subtitleDetail.copyWith(
                                color:AppTheme.primary
                              )
                            )
                          )
                        ],
                      ),
                      const SizedBox(height: 28),
                      Container(
                        decoration: AppTheme.buttonDecorationPrimary,
                        child: ElevatedButton(
                          key: const Key('signin_button'),
                          onPressed: isPasswordValid
                            ? () {
                                context.read<SignUpBloc>().add(
                                  SignUpWithEmailEvent(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                    passwordRepeat: passwordRepeatController.text.trim(),
                                    role: "user",
                                    phoneNumber: phoneNumberController.text.trim(),
                                  ),
                                );
                              }
                            : null,
                          child: Text(
                            "SIGN UP",
                            style: AppTheme.buttonStyle,
                          ),
                        ),
                      )
                    ],
                  )
                ),
                const SizedBox(height: 20)
              ],
            ),
            )
          )
        ),
      ),
    );
  }
}
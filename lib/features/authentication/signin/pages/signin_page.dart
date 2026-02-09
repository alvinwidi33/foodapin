import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_bloc.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_event.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_state.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool isVisible = false;
  bool isPasswordValid = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  @override
  void dispose() {
  emailController.dispose();
  passwordController.dispose();
  super.dispose();
  }

  bool _isPasswordValid(String value) {
    final password = passwordController.text;
    final hasMinLength = password.length >= 6;
    return hasMinLength;
  }
  @override
  Widget build(BuildContext context) {

    return BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state is SignInLoading) {
         } else if(state is SignInSuccess){
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hello ${state.user.name}. Welcome back!", style:AppTheme.bodyStyle)),
          );
          if(state.user.role == 'user') Navigator.pushReplacementNamed(context, '/home');
          else if(state.user.role == 'admin') Navigator.pushReplacementNamed(context, '/dashboard');
         } else if (state is SignInError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
            );
        }
    },
    child: Scaffold(
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
                          onChanged: (value) {
                            setState(() {
                              isPasswordValid = _isPasswordValid(value.trim());
                            });
                          },
                          decoration: AppTheme.inputDecoration("Password").copyWith(
                            errorText: isPasswordValid ? null : 'Password should be 6 characters or more',
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
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Not a user yet?", style: AppTheme.subtitleDetail),
                          SizedBox(width:4),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                            child: Text(
                              "Sign Up", 
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
                          onPressed: () {
                            context.read<SignInBloc>().add(
                              SignInWithEmailEvent(
                                email: emailController.text.trim(), 
                                password: passwordController.text.trim()
                              )
                            );
                          },
                          child: Text(
                            "SIGN IN",
                            style: AppTheme.buttonStyle,
                          ),
                        ),
                      ),
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
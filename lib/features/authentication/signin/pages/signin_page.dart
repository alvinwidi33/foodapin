import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_bloc.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool isVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  @override
    void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state is SignInLoading) {
         } else if(state is SignInSuccess){
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hello ${state.user.name}. Welcome back!", style:AppTheme.bodyStyle)),
          );
          if(state.user.role == 'Customer') Navigator.pushReplacementNamed(context, '/home');
          else if(state.user.role == 'Admin') Navigator.pushReplacementNamed(context, '/dashboard');
          else if(state.user.role == 'Toko') Navigator.pushReplacementNamed(context, '/toko');
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
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Email",
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          key: const Key('email_text_field'),
                          decoration: AppTheme.inputContainerDecoration,
                          clipBehavior: Clip.antiAlias,
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: AppTheme.inputDecoration("Email"),
                          ),
                        ),
                    ],
                  )
                )
              ],
            ),
            )
          )
        ),
      ),
    );
  }
}
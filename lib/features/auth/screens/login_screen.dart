import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/routes/routes.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _textFieldBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Color(0xFFF9EDFF),
      width: 2.0,
    ),
  );

  final _errorBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Colors.red,
      width: 2.0,
    ),
  );

  final _hintTextStyle = TextStyle(
    color: Color(0xFFF9EDFF),
  );

  final _inputTextStyle = TextStyle(
    color: Color(0xFFF9EDFF),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA7B9FF), // Top color
              Color(0xFFB482F6), // Bottom color
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Top section (logo/header)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          _buildHeader(),
                          SizedBox(height: 20),
                        ],
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEmailField(),
                          SizedBox(height: 16),
                          _buildPasswordField(),
                          SizedBox(height: 24),
                          _buildSignInButton(context),
                          SizedBox(height: 16),
                          _buildSignUpLink(context),
                          _buildErrorMessage(),
                        ],
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDivider(),
                          _buildSocialLoginButtons(context),
                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'LIPHT',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: _inputTextStyle,
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: _hintTextStyle,
        enabledBorder: _textFieldBorderStyle,
        focusedBorder: _textFieldBorderStyle,
        errorBorder: _errorBorderStyle,
        focusedErrorBorder: _errorBorderStyle,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      style: _inputTextStyle,
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: _hintTextStyle,
        enabledBorder: _textFieldBorderStyle,
        focusedBorder: _textFieldBorderStyle,
        errorBorder: _errorBorderStyle,
        focusedErrorBorder: _errorBorderStyle,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            bool success = await authProvider.signIn(
            _emailController.text.trim(),
            _passwordController.text,
            );

            // Navigate to home if login was successful
            if (success && mounted) {
                Navigator.of(context).pushReplacementNamed(Routes.home);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF9EDFF),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isLoading
                ? CircularProgressIndicator(color: Color(0xFFA764FF))
                : Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA764FF),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.register);
      },
      child: Text(
        'Don\'t have an account? Sign Up',
        style: TextStyle(
          color: Colors.deepPurple[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              authProvider.error!,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Color(0xFFF9EDFF),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'or',
              style: TextStyle(
                color: Color(0xFFF9EDFF),
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Color(0xFFF9EDFF),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 45,
          child: SignInButton(
            Buttons.google,
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.signInWithGoogle();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: SignInButton(
            Buttons.apple,
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.signInWithApple();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

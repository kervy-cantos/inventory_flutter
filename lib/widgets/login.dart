import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future signIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!context.mounted) return;
      // If login is successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email address'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong password'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // In case of any unknown errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unknown error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please sign in',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              // Username TextField
              TextFormField(
                obscureText: false,
                controller: _usernameController,
                style: theme.textTheme.labelLarge,
                autocorrect: false,
                enableSuggestions: false,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Email address is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email Address',
                  labelStyle: theme.textTheme.labelSmall,
                ),
                textInputAction: TextInputAction.next, // Move to the next field
              ),
              const SizedBox(height: 10),
              // Password TextField
              TextFormField(
                obscureText: true,
                autocorrect: false,
                style: theme.textTheme.labelLarge,
                controller: _passwordController,
                enableSuggestions: false,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  labelStyle: theme.textTheme.labelSmall,
                ),
                textInputAction: TextInputAction.done, // Done action on Enter
                onFieldSubmitted: (_) async {
                  if (_formKey.currentState!.validate()) {
                    await signIn(context); // Call signIn when Enter is pressed
                  }
                },
              ),
              const SizedBox(height: 10),
              // Submit Button
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: theme.buttonTheme.colorScheme == null
                      ? MaterialStateProperty.all<Color>(theme.primaryColor)
                      : MaterialStateProperty.all<Color>(
                          theme.buttonTheme.colorScheme!.primary),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Call the signIn method and pass the current BuildContext
                    await signIn(context);
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

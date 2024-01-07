/*

import 'package:bosquemustakisfrontend/signin_page.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_signin_button/flutter_signin_button.dart';
 class _EmailPasswordForm extends StatefulWidget {
  const _EmailPasswordForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Sign in with email and password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (String? value) {
                  if (value!.isEmpty) return 'Please enter some text';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (String? value) {
                  if (value!.isEmpty) return 'Please enter some text';
                  return null;
                },
                obscureText: true,
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: SignInButton(
                  Buttons.Email,
                  text: 'Sign In',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                    //  await _signInWithEmailAndPassword();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



class _AnonymouslySignInSection extends StatefulWidget {
  const _AnonymouslySignInSection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnonymouslySignInSectionState();
}
class _AnonymouslySignInSectionState extends State<_AnonymouslySignInSection> {
  bool? _success;
  String _userID = '';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: const Text('Test sign in anonymously',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16),
              alignment: Alignment.center,
              child: SignInButtonBuilder(
                text: 'Sign In',
                icon: Icons.person_outline,
                backgroundColor: Colors.deepPurple,
                onPressed: _signInAnonymously,
              ),
            ),
            Visibility(
              visible: _success != null,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _success == null
                      ? ''
                      : (_success!
                          ? 'Successfully signed in, uid: $_userID'
                          : 'Sign in failed'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Example code of how to sign in anonymously.
  Future<void> _signInAnonymously() async {
    try {
      final User user = (await _auth.signInAnonymously()).user!;
      ScaffoldSnackbar.of(context)
          .show('Signed in Anonymously as user ${user.uid}');
    } catch (e) {
      ScaffoldSnackbar.of(context).show('Failed to sign in Anonymously');
    }
  }
}

class _PhoneSignInSection extends StatefulWidget {
  const _PhoneSignInSection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhoneSignInSectionState();
}

class _PhoneSignInSectionState extends State<_PhoneSignInSection> {
  final _phoneNumberController = TextEditingController();
  final _smsController = TextEditingController();

  String _message = '';
  late String _verificationId;
  ConfirmationResult? webConfirmationResult;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                alignment: Alignment.center,
                child: const Text(
                  'Test sign in with phone number',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone number (+x xxx-xxx-xxxx)',
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Phone number (+x xxx-xxx-xxxx)';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: SignInButtonBuilder(
                  padding: const EdgeInsets.only(top: 16),
                  icon: Icons.contact_phone,
                  backgroundColor: Colors.deepOrangeAccent[700]!,
                  text: 'Verify Number',
                  onPressed: _verifyWebPhoneNumber,
                ),
              ),
              TextField(
                controller: _smsController,
                decoration:
                    const InputDecoration(labelText: 'Verification code'),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: SignInButtonBuilder(
                  icon: Icons.phone,
                  backgroundColor: Colors.deepOrangeAccent[400]!,
                  onPressed: _confirmCodeWeb,
                  text: 'Sign In',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Test sign in with phone number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone number (+x xxx-xxx-xxxx)',
              ),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Phone number (+x xxx-xxx-xxxx)';
                }
                return null;
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: SignInButtonBuilder(
                icon: Icons.contact_phone,
                backgroundColor: Colors.deepOrangeAccent[700]!,
                text: 'Verify Number',
                onPressed: _verifyPhoneNumber,
              ),
            ),
            TextField(
              controller: _smsController,
              decoration: const InputDecoration(labelText: 'Verification code'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16),
              alignment: Alignment.center,
              child: SignInButtonBuilder(
                icon: Icons.phone,
                backgroundColor: Colors.deepOrangeAccent[400]!,
                onPressed: _signInWithPhoneNumber,
                text: 'Sign In',
              ),
            ),
            Visibility(
              visible: _message.isNotEmpty,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _verifyWebPhoneNumber() async {
    ConfirmationResult confirmationResult =
        await _auth.signInWithPhoneNumber(_phoneNumberController.text);

    webConfirmationResult = confirmationResult;
  }

  Future<void> _confirmCodeWeb() async {
    if (webConfirmationResult != null) {
      try {
        await webConfirmationResult!.confirm(_smsController.text);
      } catch (e) {
        ScaffoldSnackbar.of(context).show('Failed to sign in: ${e.toString()}');
      }
    } else {
      ScaffoldSnackbar.of(context)
          .show('Please input sms code received after verifying phone number');
    }
  }

  // Example code of how to verify phone number
  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      ScaffoldSnackbar.of(context).show(
          'Phone number automatically verified and user signed in: $phoneAuthCredential');
    };

    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        _message =
            'Phone number verification failed. Code: ${authException.code}. '
            'Message: ${authException.message}';
      });
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      ScaffoldSnackbar.of(context)
          .show('Please check your phone for the verification code.');

      _verificationId = verificationId;
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: _phoneNumberController.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      ScaffoldSnackbar.of(context).show('Failed to Verify Phone Number: $e');
    }
  }

  // Example code of how to sign in with phone.
  Future<void> _signInWithPhoneNumber() async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      final User user = (await _auth.signInWithCredential(credential)).user!;
      ScaffoldSnackbar.of(context)
          .show('Successfully signed in UID: ${user.uid}');
    } catch (e) {
      print(e);
      ScaffoldSnackbar.of(context).show('Failed to sign in');
    }
  }
}

 */

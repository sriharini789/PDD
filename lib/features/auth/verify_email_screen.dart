import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/auth_service.dart';
import '../../core/router.dart';
import '../../core/responsive.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String token;
  final String email;

  const VerifyEmailScreen({super.key, this.token = '', this.email = ''});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.token);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final response = await authService.verifyEmail(_tokenController.text);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Go to verify success screen
      Navigator.pushReplacementNamed(context, AppRoutes.verifySuccess);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  // Illustration / Icon
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C3D) : AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 64,
                      color: isDark ? AppColors.primaryDarkAccent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Header
                  Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Description
                  Text(
                    'We\'ve sent a verification link to your email address:\n${widget.email.isNotEmpty ? widget.email : "your email address"}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Input verification token (for ease of manual verification)
                  CustomTextField(
                    controller: _tokenController,
                    labelText: 'Verification Token',
                    hintText: 'Paste token from backend logs',
                    prefixIcon: Icons.verified_user_outlined,
                    textInputAction: TextInputAction.done,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Verification token is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Verify Button
                  CustomButton(
                    text: 'Verify Account',
                    isLoading: _isLoading,
                    onPressed: _verify,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Resend Link
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email resent! Check backend console logs.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: Text(
                      'Resend Email',
                      style: TextStyle(
                        color: isDark ? AppColors.primaryDarkAccent : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

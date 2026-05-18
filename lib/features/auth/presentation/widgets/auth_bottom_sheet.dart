import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key, required this.subtitle});

  final String subtitle;

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _infoMessage; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _completeAuthWithEmail() {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    context.read<AuthCubit>().submitAuth(email, password);
  }

  void _completeSocialAuth() {
    setState(() {
      _infoMessage = AppLocalizations.of(context)!.socialComingSoon;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _infoMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: CustomGlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        borderColor: AppColors.cffffff.withOpacity(0.10),
        color: AppColors.cffffff.withOpacity(0.01),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cffffff.withOpacity(0.06),
            const Color(0xFF091822),
          ],
        ),
        child: SafeArea(
          top: false, 
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              
              String? errorMessage;
              if (state is AuthError) {
                errorMessage = state.message == 'network_error' 
                    ? l10n.networkError 
                    : state.message;
              }

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, bottomInset + 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _CircleAction(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authWelcomeBack,
                        style: TextStyle(color: AppColors.cffffff, fontSize: 36, fontWeight: FontWeight.w500, height: 1.1),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          l10n.authSubtitleDefault,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.cffffff.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w300),
                        ),
                      ),
                      const SizedBox(height: 22),

                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_infoMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _infoMessage!,
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      _AuthTextField(
                        hintText: l10n.authEmailHint,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return l10n.authEmailRequired;
                          final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                          if (!emailRegex.hasMatch(value)) return l10n.authEmailInvalid;
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      _AuthTextField(
                          hintText: l10n.authPasswordHint,
                          controller: _passwordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.authPasswordRequired;
                            if (value.length < 8) return l10n.authPasswordTooShort;
                            return null;
                          },
                        ),
                      const SizedBox(height: 12),
                      
                      _PrimaryContinueButton(
                        text: l10n.authContinue,
                        isLoading: isLoading,
                        onTap: isLoading ? () {} : _completeAuthWithEmail,
                      ),
                      
                      const SizedBox(height: 14),
                      Text(l10n.authOr, style: TextStyle(color: AppColors.cffffff, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      _SocialAuthButton(icon: Icons.g_mobiledata_rounded, label: l10n.authGoogle, onTap: isLoading ? () {} : _completeSocialAuth),
                      const SizedBox(height: 8),
                      _SocialAuthButton(icon: Icons.apple_rounded, label: l10n.authApple, onTap: isLoading ? () {} : _completeSocialAuth),
                      const SizedBox(height: 8),
                      _SocialAuthButton(icon: Icons.window_rounded, label: l10n.authMicrosoft, onTap: isLoading ? () {} : _completeSocialAuth),
                      const SizedBox(height: 8),
                      _SocialAuthButton(icon: Icons.phone_outlined, label: l10n.authPhone, onTap: isLoading ? () {} : _completeSocialAuth),

                      const SizedBox(height: 18),
                      
                      Text(l10n.authGuestPrompt, textAlign: TextAlign.center, style: TextStyle(color: AppColors.cffffff.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w300)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Text(l10n.authStayLoggedOut, style: TextStyle(color: AppColors.cffffff, fontSize: 15, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: CustomGlassContainer(
          width: 30,
          height: 30,
          borderRadius: BorderRadius.circular(20),
          borderColor: AppColors.cffffff.withOpacity(0.10),
          color: AppColors.cffffff.withOpacity(0.02),
          gradient: LinearGradient(colors: [AppColors.cffffff.withOpacity(0.10), AppColors.cffffff.withOpacity(0)]),
          child: Icon(icon, size: 16, color: AppColors.cffffff),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: CustomGlassContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(50),
          borderColor: AppColors.cffffff.withOpacity(0.10),
          color: AppColors.cffffff.withOpacity(0.02),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.cffffff.withOpacity(0.05), AppColors.cffffff.withOpacity(0)]),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.cffffff),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: AppColors.cffffff, fontSize: 12, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({required this.hintText, required this.controller, this.isPassword = false, this.validator});
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return CustomGlassContainer(
      width: double.infinity,
      borderRadius: BorderRadius.circular(50),
      borderColor: AppColors.cffffff.withOpacity(0.10),
      color: AppColors.cffffff.withOpacity(0.02),
      gradient: LinearGradient(colors: [AppColors.cffffff.withOpacity(0.04), AppColors.cffffff.withOpacity(0)]),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        style: TextStyle(color: AppColors.cffffff, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.cffffff.withOpacity(0.50), fontSize: 13),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.redAccent, height: 0.8),
        ),
      ),
    );
  }
}

class _PrimaryContinueButton extends StatelessWidget {
  const _PrimaryContinueButton({required this.onTap, required this.text, this.isLoading = false});
  final VoidCallback onTap;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: CustomGlassContainer(
          width: 290,
          borderRadius: BorderRadius.circular(50),
          borderColor: AppColors.cffffff.withOpacity(0.10),
          color: AppColors.cffffff.withOpacity(0.04),
          gradient: LinearGradient(colors: [AppColors.cffffff.withOpacity(0.10), AppColors.cffffff.withOpacity(0)]),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 24),
          child: Center(
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(text, style: TextStyle(color: AppColors.cffffff, fontSize: 15, fontWeight: FontWeight.w400)),
          ),
        ),
      ),
    );
  }
}
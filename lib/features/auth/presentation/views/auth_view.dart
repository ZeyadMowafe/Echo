import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/app_loading.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.socialComingSoon),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating, 
      ),
    );
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(context, AppRoutes.homeView);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Center(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                Navigator.pushReplacementNamed(context, AppRoutes.homeView);
              } else if (state is AuthError) {
                String displayMessage = state.message == 'network_error' 
                    ? AppLocalizations.of(context)!.networkError 
                    : state.message;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(displayMessage, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating, 
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gap(20.h),
                      Text(
                        l10n.authWelcomeBack,
                        style: TextStyle(color: AppColors.cffffff, fontSize: 32.sp, fontWeight: FontWeight.w600, height: 1.2),
                      ),
                      Gap(ScreenUtils.md),
                      Text(
                        l10n.authSubtitleDefault,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.cffffff.withOpacity(0.85), fontSize: 14.sp, fontWeight: FontWeight.w300, height: 1.4),
                      ),
                      Gap(ScreenUtils.xl),
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
                      Gap(12.h),
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
                      Gap(ScreenUtils.lg),
                      _PrimaryContinueButton(
                        text: l10n.authContinue,
                        isLoading: isLoading,
                        onTap: isLoading ? () {} : _completeAuthWithEmail,
                      ),
                      Gap(ScreenUtils.lg),
                      Text(l10n.authOr, style: TextStyle(color: AppColors.cffffff, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      Gap(ScreenUtils.lg),
                      _SocialAuthButton(icon: Icons.g_mobiledata_rounded, label: l10n.authGoogle, onTap: isLoading ? () {} : _completeSocialAuth),
                      Gap(12.h),
                      _SocialAuthButton(icon: Icons.apple_rounded, label: l10n.authApple, onTap: isLoading ? () {} : _completeSocialAuth),
                      Gap(12.h),
                      _SocialAuthButton(icon: Icons.window_rounded, label: l10n.authMicrosoft, onTap: isLoading ? () {} : _completeSocialAuth),
                      Gap(12.h),
                      _SocialAuthButton(icon: Icons.phone_outlined, label: l10n.authPhone, onTap: isLoading ? () {} : _completeSocialAuth),
                      Gap(40.h),
                      Text(l10n.authGuestPrompt, textAlign: TextAlign.center, style: TextStyle(color: AppColors.cffffff.withOpacity(0.9), fontSize: 14.sp, fontWeight: FontWeight.w300)),
                      Gap(ScreenUtils.sm),
                      InkWell(
                        onTap: isLoading ? null : _continueAsGuest,
                        borderRadius: BorderRadius.circular(4.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Text(l10n.authContinueGuest, style: TextStyle(color: AppColors.cffffff, fontSize: 15.sp, decoration: TextDecoration.underline, decorationColor: AppColors.cffffff)),
                        ),
                      ),
                      Gap(20.h),
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
      borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
      borderColor: AppColors.cffffff.withOpacity(0.15),
      color: AppColors.cffffff.withOpacity(0.02),
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 20.w),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        style: TextStyle(color: AppColors.cffffff, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.cffffff.withOpacity(0.50), fontSize: 13.sp),
          border: InputBorder.none,
          errorStyle: TextStyle(color: Colors.redAccent, height: 0.8),
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
        borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
        child: CustomGlassContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
          borderColor: AppColors.cffffff.withOpacity(0.15),
          color: AppColors.cffffff.withOpacity(0.02),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20.r, color: AppColors.cffffff),
              Gap(12.w),
              Text(label, style: TextStyle(color: AppColors.cffffff, fontSize: 13.sp, fontWeight: FontWeight.w400)),
            ],
          ),
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
        borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
        child: CustomGlassContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
          borderColor: AppColors.cffffff.withOpacity(0.15),
          color: AppColors.cffffff.withOpacity(0.06),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
          child: Center(
            child: isLoading
                ? AppLoading.button()
                : Text(text, style: TextStyle(color: AppColors.cffffff, fontSize: 16.sp, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}
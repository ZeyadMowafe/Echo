import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

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

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final valid = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
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

  void _navigateToRegister() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoutes.registerView,
      arguments: {'email': email, 'password': password},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [Colors.white.withOpacity(0.01), Colors.white.withOpacity(0.01)]
                  : [Colors.white, Colors.white],
            ),
            border: isDark
                ? Border.all(color: const Color(0x1AFFFFFF))
                : null,
          ),
          child: SafeArea(
          top: false,
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                Navigator.pop(context);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message == 'network_error'
                          ? l10n.networkError
                          : state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, topPad + 10.h, 24.w, bottomInset + 24.h),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: _CircleAction(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
                      ),
                      Gap(10.h),
                      Text(
                        l10n.authWelcomeBack,
                        style: TextStyle(color: AppColors.of(context).footer, fontSize: 32.sp, fontWeight: FontWeight.w600, height: 1.2),
                      ),
                      Gap(ScreenUtils.md),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.of(context).footer.withOpacity(0.85), fontSize: 14.sp, fontWeight: FontWeight.w300, height: 1.4),
                      ),
                      Gap(22.h),
                      AuthTextField(
                        hintText: l10n.authEmailHint,
                        controller: _emailController,
                        onChanged: _onFieldChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) return l10n.authEmailRequired;
                          final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                          );
                          if (!emailRegex.hasMatch(value)) return l10n.authEmailInvalid;
                          return null;
                        },
                      ),
                      Gap(12.h),
                      AuthTextField(
                        hintText: l10n.authPasswordHint,
                        controller: _passwordController,
                        isPassword: true,
                        onChanged: _onFieldChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) return l10n.authPasswordRequired;
                          if (value.length < 8) return l10n.authPasswordTooShort;
                          return null;
                        },
                      ),
                      Gap(ScreenUtils.lg),
                      PrimaryContinueButton(
                        text: l10n.authContinue,
                        isLoading: isLoading,
                        isEnabled: _isFormValid,
                        onTap: _completeAuthWithEmail,
                      ),
                      Gap(ScreenUtils.md),
                      PrimaryContinueButton(
                        text: l10n.authRegister,
                        isLoading: isLoading,
                        onTap: _navigateToRegister,
                      ),
                      Gap(ScreenUtils.lg),
                      Text(l10n.authOr, style: TextStyle(color: AppColors.of(context).footer, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      Gap(ScreenUtils.lg),
                      SocialAuthButton(
                        iconPath: "assets/icons/google_icon.svg",
                        label: l10n.authGoogle,
                        onTap: isLoading
                            ? () {}
                            : () => context.read<AuthCubit>().googleSignIn(),
                      ),
                      Gap(12.h),
                      InkWell(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(4.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Text(
                            l10n.authStayLoggedOut,
                            style: TextStyle(
                              color: AppColors.of(context).footer,
                              fontSize: 15.sp,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.of(context).footer,
                            ),
                          ),
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
        borderRadius: BorderRadius.circular(20.r),
        child: CustomGlassContainer(
          width: 30.r,
          height: 30.r,
          borderRadius: BorderRadius.circular(20.r),
          borderColor: AppColors.of(context).footer.withOpacity(0.10),
          color: AppColors.of(context).footer.withOpacity(0.02),
          gradient: LinearGradient(colors: [AppColors.of(context).footer.withOpacity(0.10), AppColors.of(context).footer.withOpacity(0)]),
          child: Icon(icon, size: 16.r, color: AppColors.of(context).footer),
        ),
      ),
    );
  }
}
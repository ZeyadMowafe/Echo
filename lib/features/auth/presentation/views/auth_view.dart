import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/features/auth/presentation/widgets/auth_widgets.dart';
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
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF0D1215), Color(0xFF1C252A)]
                : [Colors.white, Colors.white],
          ),
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
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
                        content: Text(
                          displayMessage,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 20.h,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gap(20.h),
                          Text(
                            l10n.authWelcomeBack,
                            style: TextStyle(
                              color: AppColors.of(context).footer,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          Gap(ScreenUtils.md),
                          Text(
                            l10n.authSubtitleDefault,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.of(
                                context,
                              ).footer.withOpacity(0.85),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w300,
                              height: 1.4,
                            ),
                          ),
                          Gap(ScreenUtils.xl),
                          AuthTextField(
                            hintText: l10n.authEmailHint,
                            controller: _emailController,
                            onChanged: _onFieldChanged,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return l10n.authEmailRequired;
                              final emailRegex = RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                              );
                              if (!emailRegex.hasMatch(value))
                                return l10n.authEmailInvalid;
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
                              if (value == null || value.isEmpty)
                                return l10n.authPasswordRequired;
                              if (value.length < 8)
                                return l10n.authPasswordTooShort;
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
                            color: AppColors.c162410,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.registerView,
                              arguments: {
                                'email': _emailController.text.trim(),
                                'password': _passwordController.text,
                              },
                            ),
                          ),
                          Gap(ScreenUtils.lg),
                          Text(
                            l10n.authOr,
                            style: TextStyle(
                              color: AppColors.of(context).footer,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap(ScreenUtils.lg),
                          SocialAuthButton(
                            iconPath: "assets/icons/google_icon.svg",
                            label: l10n.authGoogle,
                            onTap: isLoading
                                ? () {}
                                : () =>
                                      context.read<AuthCubit>().googleSignIn(),
                          ),
                          Gap(12.h),

                          InkWell(
                            onTap: isLoading ? null : _continueAsGuest,
                            borderRadius: BorderRadius.circular(4.r),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.authContinueGuest,
                                    style: TextStyle(
                                      color: AppColors.of(context).footer,
                                      fontSize: 15.sp,
                                    ),
                                  ),

                                  Container(
                                    width: 120,
                                    height: 1,
                                    color: AppColors.of(context).footer,
                                  ),
                                ],
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
      ),
    );
  }
}

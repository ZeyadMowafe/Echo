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

class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
    this.initialEmail = '',
    this.initialPassword = '',
  });
  final String initialEmail;
  final String initialPassword;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedLang = 'en';
  bool _isFormValid = false;

  void _onFieldChanged() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  static const _langCodes = [
    'en',
    'ar',
    'fr',
    'de',
    'es',
    'zh',
    'ru',
    'it',
    'ja',
    'ko',
    'pt',
  ];

  String _langName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©';
      case 'fr':
        return 'FranÃ§ais';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'EspaÃ±ol';
      case 'zh':
        return 'ä¸­æ–‡';
      case 'ru':
        return 'Ð ÑƒÑÑÐºÐ¸Ð¹';
      case 'it':
        return 'Italiano';
      case 'ja':
        return 'æ—¥æœ¬èªž';
      case 'ko':
        return 'í•œêµ­ì–´';
      case 'pt':
        return 'PortuguÃªs';
      default:
        return code;
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
    _passwordController.text = widget.initialPassword;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      lang: _selectedLang,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.of(context).footer,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.registerTitle,
          style: TextStyle(
            color: AppColors.of(context).footer,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1215), Color(0xFF1C252A)],
          ),
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
          child: Center(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.homeView,
                    (_) => false,
                  );
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message == 'network_error'
                            ? AppLocalizations.of(context)!.networkError
                            : state.message,
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
                      children: [
                        AuthTextField(
                          hintText: l10n.registerNameHint,
                          controller: _nameController,
                          onChanged: _onFieldChanged,
                          validator: (v) {
                            final name = v?.trim();
                            if (name == null || name.isEmpty) return 'Name is required';
                            if (name.length < 2) return 'Name must be at least 2 characters';
                            if (name.length > 200) return 'Name must be at most 200 characters';
                            final nameRegex = RegExp(
                              r"^[\p{L}\p{M}\s.\-']+$",
                              unicode: true,
                            );
                            if (!nameRegex.hasMatch(name)) {
                              return 'Only letters, spaces, hyphens, apostrophes, and dots allowed';
                            }
                            return null;
                          },
                        ),
                        Gap(12.h),
                        AuthTextField(
                          hintText: l10n.authEmailHint,
                          controller: _emailController,
                          onChanged: _onFieldChanged,
                          validator: (v) {
                            if (v == null || v.isEmpty) return l10n.authEmailRequired;
                            final emailRegex = RegExp(
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                            );
                            if (!emailRegex.hasMatch(v)) return l10n.authEmailInvalid;
                            return null;
                          },
                        ),
                        Gap(12.h),
                        AuthTextField(
                          hintText: l10n.registerPhoneHint,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),

                        Gap(12.h),
                        AuthTextField(
                          hintText: l10n.authPasswordHint,
                          controller: _passwordController,
                          isPassword: true,
                          onChanged: _onFieldChanged,
                          validator: (v) {
                            if (v == null || v.isEmpty) return l10n.authPasswordRequired;
                            if (v.length < 8) return l10n.authPasswordTooShort;
                            if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must contain at least 1 uppercase letter (A-Z)';
                            if (!RegExp(r'[a-z]').hasMatch(v)) return 'Must contain at least 1 lowercase letter (a-z)';
                            if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain at least 1 number (0-9)';
                            return null;
                          },
                        ),
                        Gap(12.h),
                        AuthTextField(
                          hintText: l10n.registerConfirmPasswordHint,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          onChanged: _onFieldChanged,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return l10n.authPasswordRequired;
                            if (v != _passwordController.text)
                              return l10n.registerPasswordMismatch;
                            return null;
                          },
                        ),
                        Gap(12.h),
                        CustomGlassContainer(
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.radiusFull,
                          ),
                          borderColor: AppColors.of(
                            context,
                          ).footer.withOpacity(0.15),
                          color: AppColors.of(context).footer.withOpacity(0.02),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLang,
                              isExpanded: true,
                              dropdownColor: AppColors.of(context).background,
                              icon: Icon(
                                Icons.language_rounded,
                                color: AppColors.of(context).footer,
                              ),
                              style: TextStyle(
                                color: AppColors.of(context).footer,
                                fontSize: 14.sp,
                              ),
                              hint: Text(
                                l10n.registerLanguageHint,
                                style: TextStyle(
                                  color: AppColors.of(
                                    context,
                                  ).footer.withOpacity(0.50),
                                  fontSize: 13.sp,
                                ),
                              ),
                              items: _langCodes.map((code) {
                                return DropdownMenuItem(
                                  value: code,
                                  child: Text(_langName(code)),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null)
                                  setState(() => _selectedLang = v);
                              },
                            ),
                          ),
                        ),
                        Gap(ScreenUtils.lg),
                        PrimaryContinueButton(
                          text: l10n.registerCreateAccount,
                          isLoading: isLoading,
                          isEnabled: _isFormValid,
                          color: AppColors.secondary,
                          onTap: _submit,
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
                              : () => context.read<AuthCubit>().googleSignIn(),
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
    )); 
  }
}

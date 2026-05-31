import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class PrimaryContinueButton extends StatelessWidget {
  const PrimaryContinueButton({
    required this.onTap,
    required this.text,
    this.isLoading = false,
    this.color,
    this.isEnabled = true,
  });
  final VoidCallback onTap;
  final String text;
  final bool isLoading;
  final Color? color;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final opacity = isEnabled ? 1.0 : 0.4;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled && !isLoading ? onTap : null,
        borderRadius: BorderRadius.circular(50.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: Container(
              width: 290.w,
              height: 45.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.02 * opacity),
                    Colors.white.withOpacity(0),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10 * opacity),
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Center(
                child: isLoading
                    ? AppLoading.button()
                    : Text(
                        text,
                        style: TextStyle(
                          color: Colors.white.withOpacity(opacity),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.iconPath,
  });
  final String label;
  final VoidCallback onTap;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: Container(
              width: double.infinity,
              height: 45.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.02),
                    Colors.white.withOpacity(0),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 50.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(iconPath, width: 20.r, height: 20.r),
                  Gap(10.w),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
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

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  String? _errorText;
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    final borderColor = hasError
        ? Colors.redAccent
        : _isFocused
        ? Colors.white.withOpacity(0.25)
        : Colors.white.withOpacity(0.10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 45.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.02),
                    Colors.white.withOpacity(0),
                  ],
                ),
                border: Border.all(
                  color: borderColor,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 20.w),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.isPassword,
                keyboardType: widget.keyboardType,
                onChanged: (value) {
                  widget.onChanged?.call();
                },
                validator: (value) {
                  final error = widget.validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _errorText = error);
                  });
                  return error;
                },
                style: TextStyle(
                  color: AppColors.of(context).footer,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.of(context).footer.withOpacity(0.50),
                    fontSize: 13.sp,
                  ),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 16.w),
            child: Text(
              _errorText!,
              style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }
}

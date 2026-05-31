import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/themes/theme_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSend;

  const ChatInputField({super.key, required this.onSend});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 45.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [const Color(0x06FFFFFF), const Color(0x06FFFFFF)]
                            : [
                                const Color(0x1A162410),
                                const Color(0x1A162410),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x0DFFFFFF)
                            : const Color(0xFF162410),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: TextStyle(
                        color: isDark ? AppColors.cffffff : AppColors.c000000,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.chatHintMessage,
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.cffffff.withValues(alpha: 0.4)
                              : AppColors.c000000.withValues(alpha: 0.4),
                        ),

                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 11.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(8.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(50.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [const Color(0x06FFFFFF), const Color(0x06FFFFFF)]
                          : [const Color(0x1A162410), const Color(0x1A162410)],
                    ),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x0DFFFFFF)
                          : const Color(0xFF162410),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: IconButton(
                    onPressed: _send,
                    icon: Icon(
                      Icons.send_rounded,
                      color: isDark ? Colors.white : AppColors.c000000,

                      size: 20.r,
                    ),

                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

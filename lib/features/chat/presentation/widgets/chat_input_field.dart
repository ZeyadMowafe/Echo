import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 45.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x06FFFFFF),
                      Color(0x06FFFFFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0x0DFFFFFF)),
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: TextStyle(color: AppColors.cffffff, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.cffffff.withValues(alpha: 0.4),
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
            Gap(8.w),
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x06FFFFFF),
                    Color(0x06FFFFFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(color: const Color(0x0DFFFFFF)),
              ),
              child: IconButton(
                onPressed: _send,
                icon: Icon(
                  Icons.send_rounded,
                  color: AppColors.secondary,
                  size: 20.r,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

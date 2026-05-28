import 'package:echo_explorer/core/widgets/custom_glass_app_bar.dart';
import 'package:flutter/material.dart';

class CustomDiscoverAppBar extends StatelessWidget {
  const CustomDiscoverAppBar({
    super.key,
    required this.previousState,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final String previousState;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomGlassAppBar(
      previousState: previousState,
      title: title,
      onPressed: onPressed,
      rtlAware: true,
    );
  }
}

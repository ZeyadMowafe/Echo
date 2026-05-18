import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';

class CustomSettingItem extends StatelessWidget {
  final IconData? leadingIcon;
  final String title;
  final bool hasSwitch;
  final bool switchValue;
  final Function(bool)? onSwitchChanged;
  final Function()? onTap;
  final IconData? trailingIcon;

  const CustomSettingItem({
    super.key,
    this.leadingIcon,
    required this.title,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomGlassContainer(
        color: AppColors.of(context).background.withOpacity(0.3),
        borderColor: AppColors.of(context).footer.withOpacity(0.6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.only(bottom: 12),
        borderRadius: BorderRadius.circular(16),
        height: 56,
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: AppColors.of(context).footer,
                size: 24,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.of(context).footer,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (hasSwitch)
              SizedBox(
                height: 24,
                width: 38,
                child: Switch(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.secondary,
                  inactiveThumbColor: AppColors.secondary,
                  inactiveTrackColor: AppColors.cf9f9f9.withOpacity(0.1),
                ),
              )
            else if (onTap != null&& trailingIcon != null) 
              Icon(
                trailingIcon,
                color: AppColors.of(context).footer,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';

class CustomDiscoverAppBar extends StatelessWidget {
  const CustomDiscoverAppBar({super.key,required this.previousState,required this.title,required this.onPressed});
  final String title;
  final String previousState;
  final Function() onPressed ;

  @override
  Widget build(BuildContext context) {
    return CustomGlassContainer(
        color: AppColors.of(context).discoverAppBar.withOpacity(0.25),
        gradient: LinearGradient(
          colors: [
            AppColors.of(context).discoverAppBar.withOpacity(0.30),
            AppColors.of(context).discoverAppBar.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderColor: AppColors.c162410.withOpacity(0.50),
        padding: const EdgeInsets.only(top: 6, bottom:6, left: 20, right: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          spacing: 8,
          children: [
            CustomGlassContainer(
              width: 34,
              height: 34,
              borderRadius: BorderRadius.circular(50),
              borderColor: AppColors.cffffff.withOpacity(0.10),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: AppColors.cffffff.withOpacity(0.10),
              gradient: LinearGradient(
                colors: [
                  AppColors.cffffff.withOpacity(0.20),
                  AppColors.cffffff.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        
              child: CustomGlassContainer(
                width: 34,
                height: 34,
                color: AppColors.cffffff.withOpacity(0.25),
                borderColor: AppColors.cffffff.withOpacity(0.04),
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(
                  colors: [
                    AppColors.cffffff.withOpacity(0.30),
                    AppColors.cffffff.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                child: IconButton(
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.of(context).footer,
                    size: 22,
                  ),
                  onPressed: onPressed,
                ),
              ),
            ),
            Text(title,style: TextStyle(
              color: AppColors.of(context).footer,
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),),
          ],
        ),
      ),
    );
  }
}

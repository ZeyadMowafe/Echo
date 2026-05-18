import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key,required this.onPressed});
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomGlassContainer(
      width: 72,
      height: 72,
      color: AppColors.secondary.withOpacity(0.5),
      gradient: LinearGradient(
        colors: [
          AppColors.secondary,
          AppColors.secondary,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderColor: AppColors.c162410,
      borderRadius: BorderRadius.circular(100),
      child: FloatingActionButton(
        backgroundColor:  AppColors.c162410.withOpacity(0.25),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100)),
        onPressed: onPressed,
        child: Icon(Icons.crop_free , color: AppColors.cf9f9f9,size: 36,),
      ),
    );
  }
}

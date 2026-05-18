import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';

class CustomSectionButton extends StatelessWidget {
  const CustomSectionButton({
    super.key,
    required this.onTap,
    required this.image,
    required this.title,
  });

  final Function() onTap;
  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
            AppColors.c000000.withOpacity(0.15),
            BlendMode.darken,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 17,
                right: 6,
                left: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end, 
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          height: 1.2,
                          color: AppColors.cffffff,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), 
                    CustomGlassContainer(
                      width: 28,
                      height: 28,
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
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.cf9f9f9,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:readmore/readmore.dart';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';

class EraTimelineCard extends StatefulWidget {
  final String title;
  final String description;
  final String? imagePath;
  final bool isImageRight;
  final bool isLast;

  const EraTimelineCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isImageRight = false,
    this.isLast = false,
  });

  @override
  State<EraTimelineCard> createState() => _EraTimelineCardState();
}

class _EraTimelineCardState extends State<EraTimelineCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomGlassContainer(
                padding: EdgeInsets.all(20.r),
                borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
                color: AppColors.of(context).footer.withOpacity(0.05),
                borderColor: AppColors.of(context).footer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(10.h),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: AppColors.of(context).footer,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(ScreenUtils.sm),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: ReadMoreText(
                        widget.description,
                        trimLines: 4,
                        colorClickableText: AppColors.secondary,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: l10n.readMore,
                        trimExpandedText: l10n.showless,
                        style: TextStyle(
                          color: AppColors.of(context).footer.withOpacity(0.7),
                          fontSize: 12.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (widget.imagePath != null)
              Positioned(
                top: -80.h,
                right: widget.isImageRight ? 24.w : null,
                left: !widget.isImageRight ? 24.w : null,
                child: Image.asset(
                  widget.imagePath!,
                  height: 110.h,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
        if (!widget.isLast)
          Container(
            width: 2.w,
            height: 100.h, 
            color: AppColors.of(context).footer.withOpacity(0.6),
          ),
      ],
    );
  }
}

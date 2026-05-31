import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/features/home/data/models/slider_model.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomHomeSlider extends StatefulWidget {
  const CustomHomeSlider({super.key});

  @override
  State<CustomHomeSlider> createState() => _CustomHomeSliderState();
}

class _CustomHomeSliderState extends State<CustomHomeSlider> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<SliderModel> sliders = [
      SliderModel(
        imagePath: AppImages.homeSlider.homeSliderOne,
        description: l10n.homeSliderDescOne,
      ),
      SliderModel(
        imagePath: AppImages.homeSlider.homeSliderTwo,
        description: l10n.homeSliderDescTwo,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: sliders.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildCard(index, sliders); 
            },
          ),
        ),
        Gap(13.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliders.length,
            (index) => _buildDot(index: index),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index, List<SliderModel> sliders) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
        }
        return RepaintBoundary(
          child: Center(
          child: SizedBox(
            height: Curves.easeOut.transform(value) * 240,
            width: double.infinity,
            child: child,
          ),
        ),
      );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
          color: AppColors.of(context).background,
          image: DecorationImage(
            image: AssetImage(sliders[index].imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal,
                ),
                children: [
                  TextSpan(
                    text: sliders[index].description.split('*')[0],
                    style: TextStyle(color: AppColors.cffffff),
                  ),
                  TextSpan(
                    text: sliders[index].description.split('*')[1],
                    style: TextStyle(color: AppColors.secondary),
                  ),
                  TextSpan(
                    text: sliders[index].description.split('*')[2],
                    style: TextStyle(color: AppColors.cffffff),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(right: 6.w),
      height: 8.h,
      width: _currentPage == index ? 12.w : 8.w,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.secondary
            : AppColors.of(context).icons.withOpacity(0.30),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
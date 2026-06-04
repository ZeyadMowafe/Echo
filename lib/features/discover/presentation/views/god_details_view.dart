import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/core/widgets/custom_glass_app_bar.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/features/discover/data/gods_data.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class GodDetailsView extends StatefulWidget {
  const GodDetailsView({super.key, required this.godIndex});
  final int godIndex;

  @override
  State<GodDetailsView> createState() => _GodDetailsViewState();
}

class _GodDetailsViewState extends State<GodDetailsView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final godsList = GodsData.getGodsData(context);

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawer: CustomGlassDrawer(
        currentFeature: AppStrings.discoverFeature.key, 
        onTap: (featureKey){
          Navigator.popUntil(context, (route) => route.isFirst);
          context.read<FeaturesCubit>().changeFeature(featureName: featureKey);
      }),
      drawerBarrierDismissible: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              godsList[widget.godIndex].bgImagePath,
              cacheWidth: 800,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.c000000.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          Column(
            children: [
              CustomGlassAppBar(
                previousState: AppStrings.discoverFeature.key,
                title: godsList[widget.godIndex].title,
                subtitle: godsList[widget.godIndex].subtitle,
                onPressed: () => Navigator.pop(context),
                textColor: AppColors.cffffff,
                iconColor: AppColors.cf9f9f9,
                barColor: AppColors.cffffff,
                barBorderColor: AppColors.cffffff.withOpacity(0.05),
                trailing: Builder(
                  builder: (innerContext) {
                    return IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: AppColors.cf9f9f9,
                        size: 30.r,
                      ),
                      onPressed: () {
                        Scaffold.of(innerContext).openDrawer();
                      },
                    );
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.all(ScreenUtils.md),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 0.65.sh,
                  ),
                  child: CustomGlassContainer(
                    padding: EdgeInsets.all(ScreenUtils.lg),
                    borderRadius: BorderRadius.circular(ScreenUtils.xl),
                    color: AppColors.cffffff.withOpacity(0.1),
                    borderColor: AppColors.cffffff.withOpacity(0.2),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        godsList[widget.godIndex].description,
                        style: TextStyle(
                          color: AppColors.cffffff,
                          fontSize: 16.sp,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Gap(40.h),
            ],
          ),
        ],
      ),
    );
  }
}
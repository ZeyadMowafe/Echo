import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/features/discover/data/gods_data.dart';
import 'package:echo_explorer/features/home/presentation/view_model/features_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 

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
      endDrawer: CustomGlassDrawer(
        currentFeature: AppStrings.discoverFeature.key, 
        onTap: (featureKey){
          context.read<FeaturesCubit>().changeFeature(featureName: featureKey);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
      }),
      endDrawerEnableOpenDragGesture: false,
      drawerBarrierDismissible: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              godsList[widget.godIndex].bgImagePath,
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
              CustomGlassContainer(
                color: AppColors.cffffff.withOpacity(0.25),
                gradient: LinearGradient(
                  colors: [
                    AppColors.cffffff.withOpacity(0.30),
                    AppColors.cffffff.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderColor: AppColors.cffffff.withOpacity(0.05),
                padding: const EdgeInsets.only(
                  top: 6,
                  bottom: 12,
                  left: 20,
                  right: 20,
                ),
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
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                              Directionality.of(context) == TextDirection.rtl 
                                  ? Icons.arrow_forward_rounded 
                                  : Icons.arrow_back_rounded,
                              color: AppColors.cf9f9f9,
                              size: 22,
                            ),
                            onPressed: ()=> Navigator.pop(context),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            godsList[widget.godIndex].title,
                            style: TextStyle(
                              color: AppColors.cffffff,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (godsList[widget.godIndex].subtitle != null)
                          Text(
                            godsList[widget.godIndex].subtitle!,
                            style: TextStyle(
                              color: AppColors.cffffff.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Builder(
                        builder: (innerContext) {
                          return IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: AppColors.cf9f9f9,
                              size: 30,
                            ),
                            onPressed: () {
                              Scaffold.of(innerContext).openEndDrawer();
                            },
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
          
              const Spacer(),
          
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.65,
                  ),
                  child: CustomGlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: BorderRadius.circular(32),
                    color: AppColors.cffffff.withOpacity(0.1),
                    borderColor: AppColors.cffffff.withOpacity(0.2),
          
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        godsList[widget.godIndex].description,
                        style:  TextStyle(
                          color: AppColors.cffffff,
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          
              const SizedBox(height: 40), 
            ],
          ),
        ],
      ),
    );
  }
}
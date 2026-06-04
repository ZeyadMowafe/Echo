import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/localization/locale_cubit.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/themes/theme_cubit.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/core/widgets/custom_glass_app_bar.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/features/profile/presentation/widgets/custom_setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isCameraPermissionGranted = true;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final isLightMode = !context.watch<ThemeCubit>().state;

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawer: CustomGlassDrawer(
        currentFeature: AppStrings.settingsFeature.key,
        onTap: (featureKey) {
          Navigator.popUntil(context, (route) => route.isFirst);
          context.read<FeaturesCubit>().changeFeature(featureName: featureKey);
        },
      ),
      drawerBarrierDismissible: true,
      backgroundColor: appColors.background,

      body: Column(
        children: [
          CustomGlassAppBar(
            previousState: '',
            title: AppLocalizations.of(context)!.settings,
            onPressed: () => Navigator.pop(context),
            rtlAware: true,
            trailing: Builder(
              builder: (innerContext) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: appColors.footer,
                    size: 30.r,
                  ),
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 48.h, left: 18.w, right: 18.w),
              children: [
                _buildSectionTitle(
                  AppLocalizations.of(context)!.settingsAppPreferences,
                  appColors,
                ),
                CustomSettingItem(
                  leadingIcon: Icons.language,
                  title: AppLocalizations.of(context)!.language,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onTap: () => _showLanguagePicker(context, appColors),
                ),
                CustomSettingItem(
                  title: AppLocalizations.of(context)!.settingsLightMood,
                  hasSwitch: true,
                  switchValue: isLightMode,
                  onSwitchChanged: (value) {
                    context.read<ThemeCubit>().toggleTheme(value);
                  },
                ),
                CustomSettingItem(
                  leadingIcon: Icons.camera_alt_outlined,
                  title: AppLocalizations.of(context)!.settingsCameraPermission,
                  hasSwitch: true,
                  switchValue: isCameraPermissionGranted,
                  onSwitchChanged: (value) {
                    setState(() => isCameraPermissionGranted = value);
                  },
                ),
                Gap(35.h),
                _buildSectionTitle(
                  AppLocalizations.of(context)!.settingsSupportAbout,
                  appColors,
                ),
                CustomSettingItem(
                  leadingIcon: Icons.info_outline_rounded,
                  title: AppLocalizations.of(context)!.settingsSupportAbout,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onTap: () => _showAboutBottomSheet(context, appColors),
                ),
                CustomSettingItem(
                  leadingIcon: Icons.lock_outline_rounded,
                  title: AppLocalizations.of(context)!.settingsPrivacyPolicy,
                  onTap: () {},
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    final isGuest = authState is UnAuthenticated;
                    return CustomSettingItem(
                      leadingIcon: isGuest
                          ? Icons.login_rounded
                          : Icons.logout_rounded,
                      title: isGuest
                          ? AppLocalizations.of(context)!.authLogin
                          : AppLocalizations.of(context)!.settingsLogOut,
                      onTap: () async {
                        if (isGuest) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.authView,
                            (route) => false,
                          );
                        } else {
                          await context.read<AuthCubit>().logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.authView,
                              (route) => false,
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BaseThemeColors appColors) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          color: appColors.footer,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, BaseThemeColors appColors) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = context.read<LocaleCubit>().state.locale.languageCode;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: appColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 0.8.sh),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: appColors.footer.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: appColors.footer),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                    Expanded(
                      child: Text(
                        l10n.appLanguage,
                        style: TextStyle(
                          color: appColors.footer,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: appColors.footer.withOpacity(0.6),
                  thickness: 0.5,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'en',
                          'English',
                          l10n.english,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'ar',
                          'العربية',
                          l10n.arabic,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'fr',
                          'Français',
                          l10n.french,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'de',
                          'Deutsch',
                          l10n.german,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'es',
                          'Español',
                          l10n.spanish,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'zh',
                          '中文',
                          l10n.chinese,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'ru',
                          'Русский',
                          l10n.russian,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'it',
                          'Italiano',
                          l10n.italian,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'ja',
                          '日本語',
                          l10n.japanese,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'ko',
                          '한국어',
                          l10n.korean,
                          appColors,
                        ),
                        _buildLanguageTile(
                          sheetContext,
                          currentCode,
                          'pt',
                          'Português',
                          l10n.portuguese,
                          appColors,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String currentCode,
    String languageCode,
    String nativeName,
    String localizedName,
    BaseThemeColors appColors,
  ) {
    return RadioListTile<String>(
      value: languageCode,
      groupValue: currentCode,
      activeColor: const Color(0xFF00E676),
      title: RichText(
        text: TextSpan(
          text: '$nativeName\n',
          style: TextStyle(color: appColors.footer, fontSize: 16.sp),
          children: <TextSpan>[
            TextSpan(
              text: localizedName,
              style: TextStyle(
                color: appColors.footer.withOpacity(0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
      onChanged: (selectedCode) async {
        if (selectedCode == null) return;
        await context.read<LocaleCubit>().changeLanguage(selectedCode);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  void _showAboutBottomSheet(BuildContext context, BaseThemeColors appColors) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return CustomGlassContainer(
              color: appColors.background.withOpacity(0.9),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ScreenUtils.glassBorderRadius),
              ),
              padding: EdgeInsets.all(ScreenUtils.lg),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: appColors.footer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Text(
                    l10n.aboutTitle,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: appColors.footer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(ScreenUtils.sm),
                  Text(
                    l10n.aboutSubtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontStyle: FontStyle.italic,
                      color: appColors.footer.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(ScreenUtils.lg),
                  _buildAboutSection(
                    l10n.aboutPhilosophyTitle,
                    l10n.aboutPhilosophyBody,
                    appColors,
                  ),
                  _buildAboutSection(
                    l10n.aboutMoreTitle,
                    l10n.aboutMoreBody,
                    appColors,
                  ),
                  _buildAboutSection(
                    l10n.aboutBridgeTitle,
                    l10n.aboutBridgeBody,
                    appColors,
                  ),
                  _buildAboutSection(
                    l10n.aboutTeamTitle,
                    l10n.aboutTeamBody,
                    appColors,
                  ),
                  Gap(ScreenUtils.lg),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAboutSection(
    String title,
    String body,
    BaseThemeColors appColors,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00E676),
            ),
          ),
          Gap(ScreenUtils.sm),
          Text(
            body,
            style: TextStyle(
              fontSize: 14.sp,
              color: appColors.footer,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

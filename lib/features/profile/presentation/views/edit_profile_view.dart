import 'dart:io';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/localization/locale_cubit.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController; 
  late String _selectedLanguage;
  
  File? _coverImage;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  static const Map<String, String> _languageNames = {
    'en': 'English', 'ar': 'العربية', 'fr': 'Français', 'de': 'Deutsch',
    'es': 'Español', 'zh': '中文', 'ru': 'Русский', 'it': 'Italiano',
    'ja': '日本語', 'ko': '한국어', 'pt': 'Português',
  };

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    
    if (authState is Authenticated) {
      _nameController = TextEditingController(text: authState.userName);
      _emailController = TextEditingController(text: authState.userEmail); 
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
    }

    _selectedLanguage = context.read<LocaleCubit>().state.locale.languageCode;

    final cachedProfile = CacheHelper.getData(key: 'profile_image');
    final cachedCover = CacheHelper.getData(key: 'cover_image');
    if (cachedProfile != null) _profileImage = File(cachedProfile);
    if (cachedCover != null) _coverImage = File(cachedCover);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose(); 
    super.dispose();
  }

  Future<void> _pickImage({required bool isCover}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          if (isCover) _coverImage = File(pickedFile.path);
          else _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _saveChanges() {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    
    if (newName.isNotEmpty && newEmail.isNotEmpty) {
      context.read<AuthCubit>().updateProfile(newName: newName, email: newEmail, lang: _selectedLanguage);
    }
  }

  void _showLanguagePicker(BuildContext context, BaseThemeColors appColors) {
    final currentCode = _selectedLanguage;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: appColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
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
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: appColors.footer.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.close, color: appColors.footer), onPressed: () => Navigator.pop(sheetContext)),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.appLanguage, style: TextStyle(color: appColors.footer, fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                Divider(color: appColors.footer.withOpacity(0.6), thickness: 0.5),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        for (final entry in _languageNames.entries)
                          RadioListTile<String>(
                            value: entry.key,
                            groupValue: currentCode,
                            activeColor: const Color(0xFF00E676),
                            title: RichText(
                              text: TextSpan(
                                text: '${entry.value}\n',
                                style: TextStyle(color: appColors.footer, fontSize: 16.sp),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: _localizedLanguageName(entry.key),
                                    style: TextStyle(color: appColors.footer.withOpacity(0.6), fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (selectedCode) async {
                              if (selectedCode == null) return;
                              Navigator.pop(sheetContext);
                              await context.read<LocaleCubit>().changeLanguage(selectedCode);
                              setState(() => _selectedLanguage = selectedCode);
                            },
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

  String _localizedLanguageName(String code) {
    switch (code) {
      case 'en': return AppLocalizations.of(context)!.english;
      case 'ar': return AppLocalizations.of(context)!.arabic;
      case 'fr': return AppLocalizations.of(context)!.french;
      case 'de': return AppLocalizations.of(context)!.german;
      case 'es': return AppLocalizations.of(context)!.spanish;
      case 'zh': return AppLocalizations.of(context)!.chinese;
      case 'ru': return AppLocalizations.of(context)!.russian;
      case 'it': return AppLocalizations.of(context)!.italian;
      case 'ja': return AppLocalizations.of(context)!.japanese;
      case 'ko': return AppLocalizations.of(context)!.korean;
      case 'pt': return AppLocalizations.of(context)!.portuguese;
      default: return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (_profileImage != null) CacheHelper.putData(key: 'profile_image', value: _profileImage!.path);
            if (_coverImage != null) CacheHelper.putData(key: 'cover_image', value: _coverImage!.path);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final appColors = AppColors.of(context);

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 220.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0, right: 0, top: 0, height: 150.h,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2328),
                            image: _coverImage != null ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover) : null,
                          ),
                          child: Center(
                            child: _EditOverlayButton(
                              icon: Icons.camera_alt_outlined,
                              label: l10n.editProfileChangeCover,
                              onTap: () => _pickImage(isCover: true),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12.w, top: topPad + 4.h,
                        child: IconButton(
                          icon: Icon(
                            Directionality.of(context) == TextDirection.rtl 
                              ? Icons.arrow_forward_ios_rounded 
                              : Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        left: 0.5.sw - 55.w, top: 95.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110.r, height: 110.r, padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(color: AppColors.of(context).background, shape: BoxShape.circle),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.of(context).footer, shape: BoxShape.circle,
                                  image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
                                ),
                                alignment: Alignment.center,
                                child: _profileImage == null ? Icon(Icons.person, size: 60.r, color: AppColors.of(context).background.withOpacity(0.5)) : null,
                              ),
                            ),
                            Positioned(
                              bottom: 5.r, right: 5.r,
                              child: InkWell(
                                onTap: () => _pickImage(isCover: false),
                                child: Container(
                                  padding: EdgeInsets.all(ScreenUtils.sm),
                                  decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                  child: Icon(Icons.edit, color: Colors.white, size: ScreenUtils.iconSm),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(40.h),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.editProfileName, style: TextStyle(color: AppColors.of(context).footer.withOpacity(0.7), fontSize: 14.sp)),
                      Gap(ScreenUtils.sm),
                      CustomGlassContainer(
                        width: double.infinity, borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                        borderColor: AppColors.of(context).footer.withOpacity(0.15),
                        color: AppColors.of(context).footer.withOpacity(0.02),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: AppColors.of(context).footer, fontSize: 16.sp),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Gap(ScreenUtils.md),

                      Text("Email", style: TextStyle(color: AppColors.of(context).footer.withOpacity(0.7), fontSize: 14.sp)),
                      Gap(ScreenUtils.sm),
                      CustomGlassContainer(
                        width: double.infinity, borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                        borderColor: AppColors.of(context).footer.withOpacity(0.15),
                        color: AppColors.of(context).footer.withOpacity(0.02),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: AppColors.of(context).footer, fontSize: 16.sp),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Gap(ScreenUtils.lg),

                      Text(l10n.appLanguage, style: TextStyle(color: AppColors.of(context).footer.withOpacity(0.7), fontSize: 14.sp)),
                      Gap(ScreenUtils.sm),
                      CustomGlassContainer(
                        width: double.infinity, borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                        borderColor: AppColors.of(context).footer.withOpacity(0.15),
                        color: AppColors.of(context).footer.withOpacity(0.02),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: InkWell(
                          onTap: () => _showLanguagePicker(context, appColors),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Row(
                              children: [
                                Icon(Icons.language, color: AppColors.of(context).footer.withOpacity(0.7), size: ScreenUtils.iconMd),
                                Gap(12.w),
                                Expanded(
                                  child: Text(
                                    _languageNames[_selectedLanguage] ?? _selectedLanguage,
                                    style: TextStyle(color: AppColors.of(context).footer, fontSize: 16.sp),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.of(context).footer.withOpacity(0.4), size: ScreenUtils.iconSm),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap(40.h),
                      
                      InkWell(
                        onTap: isLoading ? null : _saveChanges, 
                        borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                        child: CustomGlassContainer(
                          width: double.infinity, borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                          borderColor: AppColors.of(context).footer.withOpacity(0.15),
                          color: AppColors.of(context).footer.withOpacity(0.06),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: isLoading 
                              ? SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(l10n.editProfileSave, style: TextStyle(color: AppColors.cffffff, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditOverlayButton extends StatelessWidget {
  const _EditOverlayButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenUtils.sm),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(ScreenUtils.sm)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: ScreenUtils.iconSm),
            Gap(ScreenUtils.sm),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
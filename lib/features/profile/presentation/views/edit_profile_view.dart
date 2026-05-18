import 'dart:io';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/localization/locale_cubit.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                                style: TextStyle(color: appColors.footer, fontSize: 16),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: _localizedLanguageName(entry.key),
                                    style: TextStyle(color: appColors.footer.withOpacity(0.6), fontSize: 14),
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
                  height: 220,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0, right: 0, top: 0, height: 150,
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
                        left: 12, top: topPad + 4,
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
                        left: MediaQuery.of(context).size.width / 2 - 55, top: 95,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110, height: 110, padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(color: AppColors.of(context).background, shape: BoxShape.circle),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.of(context).footer, shape: BoxShape.circle,
                                  image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
                                ),
                                alignment: Alignment.center,
                                child: _profileImage == null ? Icon(Icons.person, size: 60, color: AppColors.of(context).background.withOpacity(0.5)) : null,
                              ),
                            ),
                            Positioned(
                              bottom: 5, right: 5,
                              child: InkWell(
                                onTap: () => _pickImage(isCover: false),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.editProfileName, style: TextStyle(color: AppColors.of(context).footer.withOpacity(0.7), fontSize: 14)),
                      const SizedBox(height: 8),
                      CustomGlassContainer(
                        width: double.infinity, borderRadius: BorderRadius.circular(16),
                        borderColor: AppColors.of(context).footer.withOpacity(0.15),
                        color: AppColors.of(context).footer.withOpacity(0.02),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: AppColors.of(context).footer, fontSize: 16),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text("Email", style: TextStyle(color: AppColors.of(context).footer.withOpacity(0.7), fontSize: 14)),
                      const SizedBox(height: 8),
                      CustomGlassContainer(
                        width: double.infinity, borderRadius: BorderRadius.circular(16),
                        borderColor: AppColors.of(context).footer.withOpacity(0.15),
                        color: AppColors.of(context).footer.withOpacity(0.02),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: AppColors.of(context).footer, fontSize: 16),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(l10n.appLanguage, style: TextStyle(color: AppColors.of(context).footer.withOpacity(0.7), fontSize: 14)),
                      const SizedBox(height: 8),
                      CustomGlassContainer(
                        width: double.infinity, borderRadius: BorderRadius.circular(16),
                        borderColor: AppColors.of(context).footer.withOpacity(0.15),
                        color: AppColors.of(context).footer.withOpacity(0.02),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: InkWell(
                          onTap: () => _showLanguagePicker(context, appColors),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.language, color: AppColors.of(context).footer.withOpacity(0.7), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _languageNames[_selectedLanguage] ?? _selectedLanguage,
                                    style: TextStyle(color: AppColors.of(context).footer, fontSize: 16),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.of(context).footer.withOpacity(0.4), size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      InkWell(
                        onTap: isLoading ? null : _saveChanges, 
                        borderRadius: BorderRadius.circular(50),
                        child: CustomGlassContainer(
                          width: double.infinity, borderRadius: BorderRadius.circular(50),
                          borderColor: AppColors.of(context).footer.withOpacity(0.15),
                          color: AppColors.of(context).footer.withOpacity(0.06),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(l10n.editProfileSave, style: TextStyle(color: AppColors.cffffff, fontSize: 16, fontWeight: FontWeight.bold)),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
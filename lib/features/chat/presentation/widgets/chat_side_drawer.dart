import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_glass_back_button.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ChatSideDrawer extends StatefulWidget {
  final List<SessionEntity> sessions;
  final VoidCallback onNewChat;
  final ValueChanged<String> onSessionTap;
  final ValueChanged<String> onDeleteSession;

  const ChatSideDrawer({
    super.key,
    required this.sessions,
    required this.onNewChat,
    required this.onSessionTap,
    required this.onDeleteSession,
  });

  @override
  State<ChatSideDrawer> createState() => _ChatSideDrawerState();
}

class _ChatSideDrawerState extends State<ChatSideDrawer> {
  final _searchController = TextEditingController();
  List<SessionEntity> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _filteredSessions = widget.sessions;
    _searchController.addListener(_filterSessions);
  }

  @override
  void didUpdateWidget(ChatSideDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessions != widget.sessions) {
      _filterSessions();
    }
  }

  void _filterSessions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSessions = widget.sessions
          .where((s) => s.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      backgroundColor: Colors.transparent,
      width: 0.75.sw,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.cffffff.withValues(alpha: 0.02),
                  AppColors.cffffff.withValues(alpha: 0.005),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.cffffff.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(2, 0),
                  blurRadius: 20,
                  color: AppColors.cffffff.withValues(alpha: 0.10),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(27.h),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 29.w),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: CustomGlassBackButton(
                        size: 33,
                        iconSize: 22,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Gap(85.h - 27.h - 33.h),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 29.w),
                    child: SizedBox(
                      width: 216.w,
                      height: 36.h,
                      child: _buildSearch(),
                    ),
                  ),
                  Gap(ScreenUtils.md),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 29.w),
                    child: _buildNewChatButton(),
                  ),
                  Gap(ScreenUtils.sm),
                  Expanded(child: _buildSessionsList()),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 30.w),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        width: 200.w,
                        height: 1,
                        color: AppColors.cffffff.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 30.w),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _buildSettings(),
                    ),
                  ),
                  Gap(ScreenUtils.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: AppColors.cf9f9f9, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.chatSearchHint,
        hintStyle: TextStyle(
          color: AppColors.cf9f9f9.withValues(alpha: 0.4),
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.cf9f9f9.withValues(alpha: 0.5),
          size: ScreenUtils.iconMd,
        ),
        filled: true,
        fillColor: AppColors.cffffff.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.r),
          borderSide: BorderSide(
            color: AppColors.cffffff.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.r),
          borderSide: BorderSide(
            color: AppColors.cffffff.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.r),
          borderSide: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.w),
      ),
    );
  }

  Widget _buildNewChatButton() {
    final l10n = AppLocalizations.of(context)!;
    return IntrinsicWidth(
      child: Container(
        height: 35.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
          gradient: LinearGradient(
            colors: [
              AppColors.cffffff.withValues(alpha: 0.10),
              AppColors.cffffff.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            widget.onNewChat();
          },
          child: Center(
            child: Text(
              l10n.chatNewChat,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_filteredSessions.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'No sessions yet'
              : 'No matching sessions',
          style: TextStyle(
            color: AppColors.cf9f9f9.withValues(alpha: 0.4),
            fontSize: 14.sp,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.sm),
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        final session = _filteredSessions[index];
        return Padding(
          padding: EdgeInsetsDirectional.only(start: 21.w),
          child: _buildSessionTile(context, session),
        );
      },
    );
  }

  Widget _buildSessionTile(BuildContext context, SessionEntity session) {
    return Dismissible(
      key: Key('chat_session_${session.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsetsDirectional.only(end: ScreenUtils.md),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.redAccent,
          size: ScreenUtils.iconLg,
        ),
      ),
      onDismissed: (_) => widget.onDeleteSession(session.id),
      child: InkWell(
        borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
        onTap: () {
          Navigator.pop(context);
          widget.onSessionTap(session.id);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ScreenUtils.xs),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
                ),
              ),
              Gap(ScreenUtils.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title.isNotEmpty ? session.title : 'Chat Session',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.cf9f9f9,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      '${session.messageCount} messages',
                      style: TextStyle(
                        color: AppColors.cf9f9f9.withValues(alpha: 0.4),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent.withValues(alpha: 0.6),
                  size: ScreenUtils.iconMd,
                ),
                onPressed: () => widget.onDeleteSession(session.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.settingsView);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: ScreenUtils.iconMd,
              height: ScreenUtils.iconMd,
              child: Center(
                child: Icon(
                  Icons.settings_outlined,
                  color: AppColors.cf9f9f9,
                  size: ScreenUtils.iconMd,
                ),
              ),
            ),
            Gap(8.w),
            Text(
              l10n.drawerSettings,
              style: TextStyle(
                color: AppColors.cffffff,
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

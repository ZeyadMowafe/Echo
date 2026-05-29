import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_dimensions.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/app_loading.dart';
import 'package:echo_explorer/core/widgets/custom_glass_back_button.dart';
import 'package:echo_explorer/features/chat/domain/entities/message_entity.dart';
import 'package:echo_explorer/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:echo_explorer/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:echo_explorer/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:echo_explorer/features/chat/presentation/widgets/chat_side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ChatView extends StatefulWidget {
  final String? artifactId;
  final String? artifactName;
  const ChatView({super.key, this.artifactId, this.artifactName});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final artifactId = widget.artifactId;
    if (artifactId != null) {
      context.read<ChatCubit>().startArtifactSession(
        artifactId: artifactId,
        title: widget.artifactName,
      );

    } else {
      context.read<ChatCubit>().startNewSession();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();
        final sessions = cubit.cachedSessions;

        Widget body;
        if (widget.artifactId != null) {
          body = _buildChatSection(context, state);
        } else if (state is ChatInitial) {
          body = _buildWelcome(context);
        } else if (state is ChatLoading) {
          body = AppLoading.page();
        } else {
          body = _buildChatSection(context, state);
        }

        return Scaffold(
          backgroundColor: AppColors.of(context).background,
          drawer: ChatSideDrawer(
            sessions: sessions,
            onNewChat: () => cubit.startNewSession(),
            onSessionTap: (id) => cubit.loadSession(id),
            onDeleteSession: (id) {
              final name = sessions
                  .where((s) => s.id == id)
                  .firstOrNull
                  ?.title;
              cubit.deleteSession(id);
              if (name != null && context.mounted) {
                final overlay = Overlay.of(context);
                late OverlayEntry entry;
                entry = OverlayEntry(
                  builder: (ctx) => Positioned(
                    top: MediaQuery.of(ctx).padding.top + 12.h,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          width: 300.w,
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1215).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  size: 18.r,
                                  color: Colors.redAccent,
                                ),
                                Gap(10.w),
                                Flexible(
                                  child: Text(
                                    'Session "$name" deleted',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                overlay.insert(entry);
                Future.delayed(const Duration(seconds: 2), () {
                  if (entry.mounted) entry.remove();
                });
              }
            },

          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/chat_background_dark.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(color: const Color(0xFF0D1215).withValues(alpha: 0.7)),
              ),
              Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          Expanded(child: body),
                          BlocBuilder<ChatCubit, ChatState>(
                            builder: (context, state) {
                              final isLoading = state is ChatLoading || state is ChatBotLoading;
                              final showInput = state is ChatLoaded ||
                                  state is ChatBotLoading ||
                                  state is ChatError;
                              if (!showInput) return const SizedBox.shrink();
                              return AbsorbPointer(
                                absorbing: isLoading,
                                child: ChatInputField(
                                  onSend: (text) {
                                    cubit.sendMessage(text);
                                    _scrollToBottom();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassSigma,
          sigmaY: AppDimensions.glassSigma,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cffffff.withValues(alpha: 0.10),
            gradient: LinearGradient(
              colors: [
                AppColors.cffffff.withValues(alpha: 0.15),
                AppColors.cffffff.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.cffffff.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 6.h,
            bottom: 6.h,
            left: 20.w,
            right: 20.w,
          ),
          child: Row(
            spacing: 8.w,
            children: [
              CustomGlassBackButton(
                onPressed: () => Navigator.pop(context),
                rtlAware: true,
              ),
              Expanded(
                child: Text(
                  widget.artifactName ?? '',
                  style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Icon(
                    Icons.menu_rounded,
                    size: 28.r,
                    color: AppColors.of(context).footer.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_outlined,
                size: 64.r,
                color: AppColors.of(context).footer.withValues(alpha: 0.3)),
            Gap(ScreenUtils.md),
            Text(
              'Ask me about Ancient Egypt...',
              style: TextStyle(
                color: AppColors.of(context).footer.withValues(alpha: 0.6),
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(ScreenUtils.xl),
            ElevatedButton.icon(
              onPressed: () => context.read<ChatCubit>().startNewSession(),
              icon: const Icon(Icons.add),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                foregroundColor: AppColors.secondary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection(BuildContext context, ChatState state) {
    final messages = state is ChatLoaded
        ? state.messages
        : state is ChatBotLoading
            ? state.messages
            : state is ChatError
                ? state.messages
                : <MessageEntity>[];
    final isBotLoading = state is ChatBotLoading;
    final errorMsg = state is ChatError ? state.message : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
            itemCount: messages.length +
                (isBotLoading ? 1 : 0) +
                (errorMsg != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (isBotLoading && index == messages.length) {
                return _buildTypingIndicator();
              }
              if (errorMsg != null &&
                  index == messages.length + (isBotLoading ? 1 : 0)) {
                return Padding(
                  padding: EdgeInsets.all(ScreenUtils.md),
                  child: Text(
                    errorMsg,
                    style: TextStyle(color: Colors.redAccent, fontSize: 13.sp),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final msg = messages[index];
              return ChatBubble(
                message: msg.content,
                isUser: msg.role == 'user',
                timestamp: msg.createdAt,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(left: 11.w, bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.glassSigma,
                sigmaY: AppDimensions.glassSigma,
              ),
              child: Container(
                padding: EdgeInsets.all(11.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1A0D1215),
                      Color(0x1A0D1215),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0x0DFFFFFF)),
                ),
                child: const _TypingDots(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.15;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + (value * 0.5);
            final opacity = 0.3 + (value * 0.7);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

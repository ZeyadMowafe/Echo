import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';
import 'package:echo_explorer/features/chat/domain/entities/message_entity.dart';
import 'package:echo_explorer/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:echo_explorer/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:echo_explorer/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_discover_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatView extends StatefulWidget {
  final String? artifactId;
  final String? artifactName;
  const ChatView({super.key, this.artifactId, this.artifactName});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _scrollController = ScrollController();
  bool _showSessions = false;
  @override
  void initState() {
    super.initState();
    final artifactId = widget.artifactId;
    if (artifactId != null) {
      print('=== ChatView init: artifactId=$artifactId, artifactName=${widget.artifactName} ===');
      context.read<ChatCubit>().startArtifactSession(
        artifactId: artifactId,
        title: widget.artifactName,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ChatCubit>().sendMessage(artifactId);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ChatCubit>().clearArtifactContext();
        context.read<ChatCubit>().loadSessions();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.artifactId != null) return;
    final state = context.read<ChatCubit>().state;
    _showSessions = state is SessionsLoaded;
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
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Column(
          children: [
            CustomDiscoverAppBar(
              previousState: AppStrings.discoverFeature.key,
              title: '',
              onPressed: () {
                if (_showSessions) {
                  Navigator.of(context).maybePop();
                } else {
                  context.read<ChatCubit>().loadSessions();
                }
              },
            ),
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listenWhen: (_, current) => current is SessionsLoaded || current is ChatLoaded || current is ChatBotLoading || current is ChatError,
                listener: (_, state) {
                  _showSessions = state is SessionsLoaded;
                },
                builder: (context, state) {
                  if (widget.artifactId != null) {
                    final messages = state is ChatLoaded
                        ? state.messages
                        : state is ChatBotLoading
                            ? state.messages
                            : state is ChatError
                                ? state.messages
                                : <MessageEntity>[];
                    final isBotLoading = state is ChatBotLoading;
                    final errorMsg =
                        state is ChatError ? state.message : null;
                    return _buildChat(context, messages, isBotLoading, errorMsg);
                  }
                  if (state is ChatInitial) {
                    return _buildWelcome(context);
                  } else if (state is SessionsLoaded) {
                    return _buildSessionsList(context, state.sessions);
                  } else if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = state is ChatLoaded
                      ? state.messages
                      : state is ChatBotLoading
                          ? state.messages
                          : state is ChatError
                              ? state.messages
                              : <MessageEntity>[];
                  final isBotLoading = state is ChatBotLoading;
                  final errorMsg =
                      state is ChatError ? state.message : null;
                  return _buildChat(context, messages, isBotLoading, errorMsg);
                },
              ),
            ),
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
                      context.read<ChatCubit>().sendMessage(text);
                      _scrollToBottom();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_outlined,
                size: 64,
                color: AppColors.of(context).footer.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Ask me about Ancient Egypt...',
              style: TextStyle(
                color: AppColors.of(context).footer.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildNewChatButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.read<ChatCubit>().startNewSession(),
      icon: const Icon(Icons.add),
      label: const Text('New Chat'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
        foregroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildSessionsList(
      BuildContext context, List<SessionEntity> sessions) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chat Sessions',
                style: TextStyle(
                  color: AppColors.of(context).footer,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildNewChatButton(context),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionTile(context, session);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionTile(BuildContext context, SessionEntity session) {
    return Card(
      color: AppColors.c151D18.withValues(alpha: 0.6),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(Icons.chat_bubble_outline,
            color: AppColors.secondary, size: 24),
        title: Text(
          session.title.isNotEmpty ? session.title : 'Chat Session',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.cf9f9f9, fontSize: 15),
        ),
        subtitle: Text(
          '${session.messageCount} messages',
          style: TextStyle(
              color: AppColors.cf9f9f9.withValues(alpha: 0.5), fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            color: AppColors.cf9f9f9.withValues(alpha: 0.3), size: 14),
        onTap: () {
          context.read<ChatCubit>().loadSession(session.id);
        },
        onLongPress: () => _showSessionOptions(context, session),
      ),
    );
  }

  void _showSessionOptions(BuildContext context, SessionEntity session) {
    final colors = AppColors.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.footer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  session.title.isNotEmpty ? session.title : 'Chat Session',
                  style: TextStyle(
                    color: colors.footer,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.edit,
                      color: AppColors.secondary, size: 22),
                  title: Text('Rename Session',
                      style: TextStyle(color: AppColors.secondary, fontSize: 15)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showRenameDialog(context, session);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 22),
                  title: Text('Delete Session',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<ChatCubit>().deleteSession(session.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog(
      BuildContext context, SessionEntity session) async {
    final colors = AppColors.of(context, listen: false);
    final controller = TextEditingController(text: session.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Rename Session',
            style: TextStyle(color: colors.footer)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: colors.footer),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle:
                TextStyle(color: colors.footer.withValues(alpha: 0.4)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: colors.footer)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Rename',
                style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      context.read<ChatCubit>().renameSession(session.id, newTitle);
    }
  }

  Widget _buildChat(
    BuildContext context,
    List<MessageEntity> messages,
    bool isBotLoading,
    String? errorMsg,
  ) {
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.list,
                    color:
                        AppColors.of(context).footer.withValues(alpha: 0.6)),
                onPressed: () {
                  final state = context.read<ChatCubit>().state;
                  if (state is SessionsLoaded) {
                    Navigator.pop(context);
                  } else {
                    context.read<ChatCubit>().loadSessions();
                  }
                },
                tooltip: 'Sessions',
              ),
              Expanded(
                child: widget.artifactId != null && widget.artifactName != null
                    ? Text(
                        widget.artifactName!,
                        style: TextStyle(
                          color: AppColors.of(context).footer,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
              IconButton(
                icon: Icon(Icons.add,
                    color:
                        AppColors.of(context).footer.withValues(alpha: 0.6)),
                onPressed: () => context.read<ChatCubit>().startNewSession(),
                tooltip: 'New Chat',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: messages.length + (isBotLoading ? 1 : 0) +
                (errorMsg != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (isBotLoading && index == messages.length) {
                return _buildTypingIndicator();
              }
              if (errorMsg != null &&
                  index == messages.length + (isBotLoading ? 1 : 0)) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    errorMsg,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.c151D18.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: _TypingDots(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
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
          children: List.generate(3, (i) {
            final delay = i * 0.15;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final size = 8.0 + (value * 4.0);
            final opacity = 0.4 + (value * 0.6);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.cf9f9f9.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

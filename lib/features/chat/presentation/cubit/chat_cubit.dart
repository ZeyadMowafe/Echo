import 'dart:convert';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/chat/data/models/message_model.dart';
import 'package:echo_explorer/features/chat/domain/entities/message_entity.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';
import 'package:echo_explorer/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/get_sessions_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/get_session_by_id_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/rename_session_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/delete_session_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetSessionsUseCase getSessionsUseCase;
  final GetSessionByIdUseCase getSessionByIdUseCase;
  final RenameSessionUseCase renameSessionUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;
  String? _artifactId;
  String? _artifactTitle;
  List<SessionEntity> _cachedSessions = [];
  List<SessionEntity> get cachedSessions => _cachedSessions;

  ChatCubit({
    required this.sendMessageUseCase,
    required this.getSessionsUseCase,
    required this.getSessionByIdUseCase,
    required this.renameSessionUseCase,
    required this.deleteSessionUseCase,
  }) : super(ChatInitial()) {
    loadSessions();
  }

  static String _msgKey(String id) => 'chat_messages_$id';

  Future<void> _saveMessages(String sessionId, List<MessageEntity> messages) async {
    final jsonList = messages.map((m) => MessageModel(id: m.id, role: m.role, content: m.content, responseToId: m.responseToId, createdAt: m.createdAt).toJson()).toList();
    await CacheHelper.putData(key: _msgKey(sessionId), value: jsonEncode(jsonList));
  }

  List<MessageEntity> _loadMessages(String sessionId) {
    final raw = CacheHelper.getData(key: _msgKey(sessionId));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _deleteMessages(String sessionId) async {
    await CacheHelper.deleteData(key: _msgKey(sessionId));
  }

  bool _isLoggedIn() {
    final token = CacheHelper.getData(key: 'jwt_token');
    return token != null && token.toString().isNotEmpty;
  }

  void setSession(String? sessionId) {
    _currentSessionId = sessionId;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text.trim(),
      createdAt: DateTime.now(),
    );

    final currentMessages = _currentMessages();
    emit(ChatBotLoading(messages: [...currentMessages, userMessage]));

    print('=== ChatCubit.sendMessage: artifactId=$_artifactId, sessionId=$_currentSessionId, text="${text.trim()}" ===');
    final result = await sendMessageUseCase(SendMessageParams(
      message: text.trim(),
      language: CacheHelper.getData(
                key: AppStrings.hiveKeys.cacheHelper.localeLanguageCode,
                defaultValue: 'en',
              ) as String,
      artifactId: _artifactId,
      sessionId: _currentSessionId,
    ));

    result.fold(
      (failure) {
        debugPrint('[ChatCubit] sendMessage failed: ${failure.message}');
        emit(ChatError(
          messages: [...currentMessages, userMessage],
          message: failure.message,
        ));
      },
      (reply) async {
        _currentSessionId = reply.sessionId;
        final assistantMessage = MessageEntity(
          id: '${DateTime.now().millisecondsSinceEpoch}_reply',
          role: 'assistant',
          content: reply.reply,
          createdAt: DateTime.now(),
        );
        final allMessages = [
          ...currentMessages,
          userMessage,
          assistantMessage,
        ];
        print('=== ChatCubit.sendMessage success: sessionId=${reply.sessionId}, renaming with title=$_artifactTitle ===');
        await _saveMessages(reply.sessionId, allMessages);
        final sessionTitle = _artifactTitle ?? text.trim();
        if (_artifactTitle != null) {
          await _renameSessionSilent(reply.sessionId, _artifactTitle!);
          _artifactTitle = null;
        }
        if (!_cachedSessions.any((s) => s.id == reply.sessionId)) {
          _cachedSessions.insert(
            0,
            SessionEntity(
              id: reply.sessionId,
              title: sessionTitle,
      language: CacheHelper.getData(
        key: AppStrings.hiveKeys.cacheHelper.localeLanguageCode,
        defaultValue: 'en',
      ) as String,
              messageCount: allMessages.length,
              startedAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
        emit(ChatLoaded(messages: allMessages));
      },
    );
  }

  List<MessageEntity> _currentMessages() {
    if (state is ChatLoaded) return (state as ChatLoaded).messages;
    if (state is ChatBotLoading) return (state as ChatBotLoading).messages;
    if (state is ChatError) return (state as ChatError).messages;
    return [];
  }

  Future<void> loadSession(String sessionId) async {
    emit(ChatLoading());
    final cached = _loadMessages(sessionId);
    final loggedIn = _isLoggedIn();

    if (!loggedIn && cached.isNotEmpty) {
      _currentSessionId = sessionId;
      emit(ChatLoaded(messages: cached));
    }

    final result = await getSessionByIdUseCase(sessionId);
    result.fold(
      (failure) {
        debugPrint('[ChatCubit] loadSession failed: ${failure.message}');
        if (loggedIn && cached.isNotEmpty) {
          _currentSessionId = sessionId;
          emit(ChatLoaded(messages: cached));
        } else if (cached.isEmpty) {
          emit(ChatError(messages: [], message: failure.message));
        }
      },
      (session) async {
        _currentSessionId = session.id;
        final messages = session.messages ?? [];
        await _saveMessages(session.id, messages);
        emit(ChatLoaded(messages: messages));
      },
    );
  }

  Future<void> loadSessions() async {
    emit(ChatLoading());
    final result = await getSessionsUseCase(NoParams());
    result.fold(
      (failure) {
        debugPrint('[ChatCubit] loadSessions failed: ${failure.message}');
        if (_cachedSessions.isEmpty && state is ChatLoading) {
          emit(ChatError(messages: [], message: failure.message));
        }
      },
      (sessions) {
        _cachedSessions = List<SessionEntity>.from(sessions)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        if (_cachedSessions.isEmpty) {
          if (state is! ChatLoaded && state is! ChatBotLoading) {
            emit(ChatInitial());
          }
        } else {
          if (state is! ChatLoaded && state is! ChatBotLoading && state is! ChatError) {
            emit(SessionsLoaded(sessions: _cachedSessions));
          }
        }
      },
    );
  }

  void startNewSession() {
    _currentSessionId = null;
    _artifactId = null;
    emit(ChatLoaded(messages: []));
  }

  void clearArtifactContext() {
    _artifactId = null;
    _artifactTitle = null;
  }

  void startArtifactSession({required String artifactId, String? title}) {
    print('=== ChatCubit.startArtifactSession: artifactId=$artifactId, title=$title ===');
    _currentSessionId = null;
    _artifactId = artifactId;
    _artifactTitle = title;
    emit(ChatLoaded(messages: [], artifactTitle: title));
  }

  Future<void> renameSession(String id, String title) async {
    final result = await renameSessionUseCase(RenameSessionParams(id: id, title: title));
    result.fold(
      (failure) {
        debugPrint('[ChatCubit] renameSession failed: ${failure.message}');
        if (state is SessionsLoaded || state is ChatLoaded) {
          emit(ChatError(messages: _currentMessages(), message: failure.message));
        }
      },
      (_) => loadSessions(),
    );
  }

  Future<void> _renameSessionSilent(String id, String title) async {
    await renameSessionUseCase(RenameSessionParams(id: id, title: title));
  }

  Future<void> deleteSession(String id) async {
    final result = await deleteSessionUseCase(id);
    result.fold(
      (failure) {
        debugPrint('[ChatCubit] deleteSession failed: ${failure.message}');
        if (state is SessionsLoaded || state is ChatLoaded) {
          emit(ChatError(messages: _currentMessages(), message: failure.message));
        }
      },
      (_) async {
      await _deleteMessages(id);
      if (_currentSessionId == id) {
        _currentSessionId = null;
        emit(ChatInitial());
      }
      loadSessions();
    });
  }
}

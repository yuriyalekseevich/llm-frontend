import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/app_logger.dart';
import 'package:frontend/core/errors/app_exceptions.dart';
import '../../../data/models/query.dart';
import '../../../data/models/llm_response.dart';
import '../../../data/repositories/llm_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final LlmRepository _repository;

  ChatCubit({required LlmRepository repository})
      : _repository = repository,
        super(const ChatInitial());

  Future<void> sendMessage(Query query) async {
    // Changed to accept Query
    emit(const ChatLoading());

    try {
      final response = await _repository.sendChat(query);
      emit(ChatSuccess(response: response));
      Log.netResponse("Chat success", {'output': response.output, 'tokens': response.tokensUsed});
    } on AppException catch (e) {
      Log.netError("App error", {'message': e.message});
      emit(ChatFailure(error: e.message));
    } catch (e, stack) {
      Log.netError("Critical unexpected error", {'error': e.toString(), 'stack': stack.toString()});
      emit(const ChatFailure(error: "An unexpected error occurred"));
    }
  }

  void reset() {
    emit(const ChatInitial());
  }
}

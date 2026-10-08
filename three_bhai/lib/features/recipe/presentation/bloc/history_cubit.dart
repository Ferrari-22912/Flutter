import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';
import 'package:three_bhai/features/recipe/domain/usecases/history_usecases.dart';

enum HistoryStatus { loading, loaded, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.loading,
    this.records = const [],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<SearchRecord> records;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, records, errorMessage];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required GetHistory getHistory,
    required DeleteHistoryItem deleteItem,
    required ClearHistory clearAll,
  })  : _get = getHistory,
        _delete = deleteItem,
        _clear = clearAll,
        super(const HistoryState());

  final GetHistory _get;
  final DeleteHistoryItem _delete;
  final ClearHistory _clear;

  Future<void> load() async {
    emit(const HistoryState());
    try {
      emit(HistoryState(
        status: HistoryStatus.loaded,
        records: await _get(const NoParams()),
      ));
    } on Failure catch (e) {
      emit(HistoryState(status: HistoryStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(const HistoryState(
        status: HistoryStatus.failure,
        errorMessage: 'Could not load your history.',
      ));
    }
  }

  Future<void> delete(String id) async {
    emit(HistoryState(
      status: HistoryStatus.loaded,
      records: state.records.where((r) => r.id != id).toList(),
    ));
    try {
      await _delete(id);
    } catch (_) {
      await load(); // restore the truth if the delete failed
    }
  }

  Future<void> clear() async {
    emit(const HistoryState(status: HistoryStatus.loaded));
    try {
      await _clear(const NoParams());
    } catch (_) {
      await load();
    }
  }
}

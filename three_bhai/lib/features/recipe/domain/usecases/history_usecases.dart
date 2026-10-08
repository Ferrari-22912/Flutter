import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';
import 'package:three_bhai/features/recipe/domain/repositories/history_repository.dart';

class GetHistory implements UseCase<List<SearchRecord>, NoParams> {
  const GetHistory(this._repository);
  final HistoryRepository _repository;

  @override
  Future<List<SearchRecord>> call(NoParams params) =>
      _repository.getHistory();
}

class DeleteHistoryItem implements UseCase<void, String> {
  const DeleteHistoryItem(this._repository);
  final HistoryRepository _repository;

  @override
  Future<void> call(String params) => _repository.delete(params);
}

class ClearHistory implements UseCase<void, NoParams> {
  const ClearHistory(this._repository);
  final HistoryRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.clear();
}

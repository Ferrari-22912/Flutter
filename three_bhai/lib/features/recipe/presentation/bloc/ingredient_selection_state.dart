import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';

enum IngredientStatus { loading, loaded, failure }

class IngredientSelectionState extends Equatable {
  const IngredientSelectionState({
    this.status = IngredientStatus.loading,
    this.all = const [],
    this.category,
    this.query = '',
    this.selectedIds = const {},
    this.expanded = false,
    this.errorMessage,
  });

  /// Grid shows this many items before "Show all" is needed.
  static const int collapsedLimit = 15;

  final IngredientStatus status;
  final List<Ingredient> all;

  /// `null` means "All".
  final IngredientCategory? category;
  final String query;
  final Set<String> selectedIds;
  final bool expanded;
  final String? errorMessage;

  bool get isSearching => query.trim().isNotEmpty;

  List<Ingredient> get filtered {
    Iterable<Ingredient> list =
        category == null ? all : all.where((i) => i.category == category);
    if (isSearching) {
      final q = query.trim().toLowerCase();
      list = list.where((i) => i.name.toLowerCase().contains(q));
    }
    return list.toList();
  }

  bool get hasMore => !isSearching && filtered.length > collapsedLimit;

  List<Ingredient> get visible => (expanded || !hasMore)
      ? filtered
      : filtered.take(collapsedLimit).toList();

  List<Ingredient> get selected =>
      all.where((i) => selectedIds.contains(i.id)).toList();

  int get selectedCount => selectedIds.length;
  bool get canGenerate => selectedIds.isNotEmpty;

  IngredientSelectionState copyWith({
    IngredientStatus? status,
    List<Ingredient>? all,
    ValueGetter<IngredientCategory?>? category,
    String? query,
    Set<String>? selectedIds,
    bool? expanded,
    String? errorMessage,
  }) {
    return IngredientSelectionState(
      status: status ?? this.status,
      all: all ?? this.all,
      category: category != null ? category() : this.category,
      query: query ?? this.query,
      selectedIds: selectedIds ?? this.selectedIds,
      expanded: expanded ?? this.expanded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, all, category, query, selectedIds, expanded, errorMessage];
}

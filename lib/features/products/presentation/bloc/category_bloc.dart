import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/category_model.dart';
import '../../data/repository/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(const CategoryState()) {
    on<CategoryListRequested>(_onListRequested);
    on<CategoryUpsertRequested>(_onUpsertRequested);
  }

  Future<void> _onListRequested(CategoryListRequested event, Emitter<CategoryState> emit) async {
    emit(state.asLoading());
    try {
      final categories = await CategoryRepository.list();
      emit(state.copyWith(emitState: CategoryEmitState.success, categories: categories, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onUpsertRequested(CategoryUpsertRequested event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(emitState: CategoryEmitState.saving));
    try {
      final saved = await CategoryRepository.upsert(
        id: event.id,
        name: event.name,
        nameTranslations: event.nameTranslations,
      );
      final categories = [...state.categories];
      final index = categories.indexWhere((c) => c.id == saved.id);
      if (index >= 0) {
        categories[index] = saved;
      } else {
        categories.add(saved);
      }
      emit(state.copyWith(emitState: CategoryEmitState.saved, categories: categories, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}

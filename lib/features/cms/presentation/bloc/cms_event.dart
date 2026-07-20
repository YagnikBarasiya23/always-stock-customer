part of 'cms_bloc.dart';

sealed class CmsEvent extends Equatable {
  const CmsEvent();

  @override
  List<Object?> get props => [];
}

class CmsPageRequested extends CmsEvent {
  const CmsPageRequested(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}

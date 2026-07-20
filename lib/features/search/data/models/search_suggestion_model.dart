/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.searchSuggestions.
library;

import '../../../../core/utils/app_utils.dart';

enum SuggestionType {
  product('product'),
  category('category'),
  query('query'),
  unknown('unknown');

  const SuggestionType(this.value);

  final String value;

  static SuggestionType fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class SearchSuggestionModel {
  final String text;
  final SuggestionType type;
  final String? targetId;

  const SearchSuggestionModel({
    required this.text,
    this.type = SuggestionType.query,
    this.targetId,
  });

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      text: AppUtils.parseString(json['text']) ?? '',
      type: json['type'] == null ? SuggestionType.query : SuggestionType.fromValue(AppUtils.parseString(json['type'])),
      targetId: AppUtils.parseString(json['targetId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.value,
      'targetId': targetId,
    };
  }
}

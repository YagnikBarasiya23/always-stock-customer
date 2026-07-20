/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.cmsPageDetailBySlug.
library;

import '../../../../core/utils/app_utils.dart';

class CmsPageModel {
  final String id;
  final String slug;
  final String title;
  final String contentHtml;
  final DateTime? updatedAt;

  const CmsPageModel({
    required this.id,
    required this.slug,
    required this.title,
    this.contentHtml = '',
    this.updatedAt,
  });

  factory CmsPageModel.fromJson(Map<String, dynamic> json) {
    return CmsPageModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      slug: AppUtils.parseString(json['slug']) ?? '',
      title: AppUtils.parseString(json['title']) ?? '',
      contentHtml: AppUtils.parseString(json['contentHtml']) ?? '',
      updatedAt: AppUtils.parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'slug': slug,
      'title': title,
      'contentHtml': contentHtml,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

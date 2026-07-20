abstract class AppUtils {
  static String? parseString(dynamic value) {
    try {
      return value as String?;
    } catch (e) {
      return null;
    }
  }

  /// Mongo ref fields may arrive either as a plain id string or populated
  /// as an object like {_id, name, ...}. Returns the id in both cases.
  static String? parseRefId(dynamic value) {
    if (value is Map) return parseString(value['_id']);
    return parseString(value);
  }

  /// Parses a {locale: text} object, dropping non-string or empty entries.
  static Map<String, String> parseStringMap(dynamic value) {
    if (value is! Map) return const {};
    final result = <String, String>{};
    for (final entry in value.entries) {
      final key = entry.key;
      final text = parseString(entry.value);
      if (key is String && text != null && text.isNotEmpty) result[key] = text;
    }
    return result;
  }

  static int? parseInt(dynamic value) {
    try {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return value as int?;
    } catch (e) {
      return null;
    }
  }

  static double? parseDouble(dynamic value) {
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return value as double?;
    } catch (e) {
      return null;
    }
  }

  static bool? parseBool(dynamic value) {
    try {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
      return value as bool?;
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDateTime(dynamic value) {
    try {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    } catch (e) {
      return null;
    }
  }

  static List<String> parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map(parseString).whereType<String>().toList();
  }

  static List<T> parseObjectList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  static Map<String, dynamic> parseMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return const {};
  }
}

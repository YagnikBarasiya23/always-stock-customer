import 'package:flutter_bloc/flutter_bloc.dart';

import '../local/local_storage_services.dart';

class LanguageBloc extends Cubit<String> {
  LanguageBloc() : super(LocalStorageServices.getLanguageCode() ?? 'en');

  void changeLanguage(String languageCode) => emit(languageCode);
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'config/local/local_storage_services.dart';
import 'config/network/network_bloc.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/language_bloc.dart';
import 'core/utils/app_prompts.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await LocalStorageServices.instance;
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu')],
      fallbackLocale: const Locale('en'),
      child: const _AlwaysStockApp(),
    ),
  );
}

class _AlwaysStockApp extends StatelessWidget {
  const _AlwaysStockApp();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ConnectivityCubit()),
      BlocProvider(create: (_) => AuthBloc()..add(const AuthSessionRestoreRequested())),
      BlocProvider(create: (_) => LanguageBloc()),
    ],
    child: BlocListener<ConnectivityCubit, ConnectivityStatus>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, status) {
        final isOnline = status == ConnectivityStatus.online;
        if (!isOnline) {
          AppPrompts.error(context, 'common.no_internet'.tr());
        }
      },
      child: BlocListener<LanguageBloc, String>(
        listener: (context, languageCode) => context.setLocale(Locale(languageCode)),
        child: ToastificationWrapper(
          config: const ToastificationConfig(maxToastLimit: 1, maxDescriptionLines: 10, maxTitleLines: 5),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: MaterialApp.router(
              theme: AppTheme.theme,
              routerConfig: AppRoutes.goRouter,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            ),
          ),
        ),
      ),
    ),
  );
}

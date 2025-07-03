import 'package:flutter/material.dart';
import 'core/network/dio_client.dart';
import 'core/services/token_storage.dart';
import 'core/services/auth_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class Bootstrap {
  static Widget init() {
    final tokenStorage = TokenStorage();
    final dioClient = DioClient(tokenStorage);
    final authService = AuthService(dioClient.client, tokenStorage);
    final router = buildRouter(dioClient, authService);

    return MaterialApp.router(
      title: 'Tasks MVP',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

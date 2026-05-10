import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/data/catalog_repository.dart';
import 'core/data/paint_progress_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final catalogRepo = await FlutterCatalogRepository.create();

  runApp(
    ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        paintProgressRepositoryProvider
            .overrideWithValue(SharedPrefsPaintProgressRepository(prefs)),
      ],
      child: const ColorinApp(),
    ),
  );
}

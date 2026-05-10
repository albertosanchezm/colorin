import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/catalog_repository.dart';
import '../core/data/paint_progress_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (_) => throw UnimplementedError('Override in main()'),
);

final paintProgressRepositoryProvider = Provider<PaintProgressRepository>(
  (_) => throw UnimplementedError('Override in main()'),
);

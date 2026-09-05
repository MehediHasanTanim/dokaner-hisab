// The only way a caller reaches storage.
//
// AR-29 states the layering: repositories are the sole database surface,
// Riverpod notifiers are the only state mutators, and no widget touches the
// database. These providers are the join between the two halves — a screen
// watches a repository provider, never a database.
//
// `tool/check_data_access.dart` enforces the other half of the rule: a
// `package:drift` import anywhere under `lib/` outside `lib/data/` fails the
// build. Together they mean a widget CANNOT reach Drift, rather than being
// asked not to.
//
// The database provider opens the real, encrypted, on-device file. The open is
// lazy — `deviceEncryptedExecutor` returns a `LazyDatabase`, so the keystore read
// and the first decryption happen on the first query rather than blocking
// `main()`. A test (or the benchmark harness) overrides this one provider with
// a database over a temporary file and everything above it is unchanged:
//
//     ProviderScope(
//       overrides: [hisabDatabaseProvider.overrideWithValue(db)],
//       child: ...,
//     )

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/database.dart';
import 'db/platform_keystore.dart';
import 'repositories/business_repository.dart';
import 'repositories/money_account_repository.dart';
import 'repositories/money_movement_repository.dart';
import 'repositories/user_repository.dart';

/// The encrypted local database (AD-17).
///
/// One instance for the life of the app. Disposed with the scope, which closes
/// the file — Drift holds a write lock, and a second instance over the same
/// file would contend with it.
final Provider<HisabDatabase> hisabDatabaseProvider = Provider<HisabDatabase>((
  ref,
) {
  final HisabDatabase database = HisabDatabase(deviceEncryptedExecutor());
  ref.onDispose(database.close);
  return database;
});

/// The owner (FR-3).
final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>(
      (ref) => UserRepository(ref.watch(hisabDatabaseProvider)),
    );

/// The shop (FR-2).
final Provider<BusinessRepository> businessRepositoryProvider =
    Provider<BusinessRepository>(
      (ref) => BusinessRepository(ref.watch(hisabDatabaseProvider)),
    );

/// The five places money sits (FR-4, FR-12).
final Provider<MoneyAccountRepository> moneyAccountRepositoryProvider =
    Provider<MoneyAccountRepository>(
      (ref) => MoneyAccountRepository(ref.watch(hisabDatabaseProvider)),
    );

/// Every taka in or out, and the balances derived from them (AD-19).
final Provider<MoneyMovementRepository> moneyMovementRepositoryProvider =
    Provider<MoneyMovementRepository>(
      (ref) => MoneyMovementRepository(ref.watch(hisabDatabaseProvider)),
    );

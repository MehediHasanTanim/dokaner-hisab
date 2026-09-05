// Measures what NFR-1 is actually about: how long a write takes to confirm.
//
//   dart run tool/benchmark_local_write.dart
//   dart run tool/benchmark_local_write.dart --iterations=500 --warmup=100
//
// NFR-1 asks for a local write to perceived confirmation in under 100 ms,
// INCLUDING SQLCipher overhead, on a mid-range 2023 Android device. A figure
// nobody can reproduce is not a measurement, so this is a harness rather than a
// number in a document: it opens a real encrypted database, writes real
// MoneyMovement rows through the real repository, and prints the median and the
// 95th percentile plus a row ready to paste into BENCHMARKS.md.
//
// What is timed is `MoneyMovementRepository.record()` end to end — the insert
// AND the read-back that returns the written row — because that is what a
// screen awaits before it can tell the owner the money is recorded. Timing the
// INSERT alone would measure something the owner never experiences.
//
// This file imports no Flutter, on purpose: `dart run` has no engine and no
// `dart:ui`. That is why `lib/data/db/encryption.dart` is pure Dart and the
// keystore binding lives in `platform_keystore.dart` — see the note there.
//
// ── Measuring on a real phone ────────────────────────────────────────────────
// A Dart CLI runs on the development machine, and a laptop's flash is not a
// mid-range phone's. The figure that satisfies NFR-1 must come from the device.
// [runLocalWriteBenchmark] is exported for exactly that: call it from an
// `integration_test/` case built onto the handset, print the same summary, and
// record it in BENCHMARKS.md with the device name. The desktop run below is a
// regression signal, not the acceptance figure, and BENCHMARKS.md says so.

import 'dart:io';

import 'package:hisab/data/db/database.dart';
import 'package:hisab/data/db/encryption.dart';
import 'package:hisab/data/db/tables.dart';
import 'package:hisab/data/repositories/business_repository.dart';
import 'package:hisab/data/repositories/money_account_repository.dart';
import 'package:hisab/data/repositories/money_movement_repository.dart';
import 'package:hisab/data/repositories/user_repository.dart';

/// NFR-1's ceiling, in microseconds.
const int kWriteBudgetMicroseconds = 100 * 1000;

/// A set of measurements, in microseconds. Integers throughout — there is no
/// `double` in this project, and a latency is a count of microseconds.
class LatencySummary {
  const LatencySummary({
    required this.samples,
    required this.min,
    required this.median,
    required this.p95,
    required this.max,
  });

  factory LatencySummary.of(List<int> microseconds) {
    final List<int> sorted = List<int>.of(microseconds)..sort();
    return LatencySummary(
      samples: sorted.length,
      min: sorted.first,
      median: _percentile(sorted, 50),
      p95: _percentile(sorted, 95),
      max: sorted.last,
    );
  }

  final int samples;
  final int min;
  final int median;
  final int p95;
  final int max;

  bool get withinBudget => p95 < kWriteBudgetMicroseconds;

  static int _percentile(List<int> sorted, int percent) {
    // Nearest-rank, computed in integers: the smallest value at or above which
    // `percent` of the samples fall.
    final int rank = ((sorted.length * percent) + 99) ~/ 100;
    final int index = rank < 1 ? 0 : rank - 1;
    return sorted[index >= sorted.length ? sorted.length - 1 : index];
  }
}

/// Microseconds as `12.345 ms`, without going anywhere near a double.
String formatMicroseconds(int microseconds) {
  final String whole = (microseconds ~/ 1000).toString();
  final String fraction = (microseconds % 1000).toString().padLeft(3, '0');
  return '$whole.$fraction ms';
}

/// Opens an encrypted database at [file], seeds one Business and one Money
/// Account, then times [iterations] movement writes.
///
/// [warmup] writes are made and discarded first: the first insert pays for the
/// schema being created, the triggers being installed, SQLCipher deriving its
/// page state and the VM warming up, none of which the owner's tenth sale pays.
Future<LatencySummary> runLocalWriteBenchmark({
  required File file,
  int iterations = 200,
  int warmup = 50,
}) async {
  final HisabDatabase db = HisabDatabase(
    encryptedExecutor(file: file, keyHex: mintDatabaseKeyHex()),
  );

  try {
    final User owner = await UserRepository(
      db,
    ).create(phone: '+8801700000000', name: 'Benchmark');
    final Business business = await BusinessRepository(db).create(
      name: 'Benchmark Shop',
      type: BusinessType.grocery,
      ownerUserId: owner.id,
    );
    final MoneyAccount account = await MoneyAccountRepository(db).create(
      businessId: business.id,
      type: MoneyAccountType.cash,
      name: 'Cash',
    );

    final MoneyMovementRepository movements = MoneyMovementRepository(db);

    Future<void> writeOne(int index) => movements.record(
      businessId: business.id,
      moneyAccountId: account.id,
      amountPaisa: 1000 + index,
      type: MoneyMovementType.opening,
    );

    for (int i = 0; i < warmup; i++) {
      await writeOne(i);
    }

    final List<int> samples = <int>[];
    final Stopwatch stopwatch = Stopwatch();
    for (int i = 0; i < iterations; i++) {
      stopwatch
        ..reset()
        ..start();
      await writeOne(warmup + i);
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }

    return LatencySummary.of(samples);
  } finally {
    await db.close();
  }
}

int _intArg(List<String> args, String name, int fallback) {
  for (final String arg in args) {
    if (arg.startsWith('--$name=')) {
      return int.parse(arg.substring(name.length + 3));
    }
  }
  return fallback;
}

String? _stringArg(List<String> args, String name) {
  for (final String arg in args) {
    if (arg.startsWith('--$name=')) {
      return arg.substring(name.length + 3);
    }
  }
  return null;
}

Future<void> main(List<String> args) async {
  final int iterations = _intArg(args, 'iterations', 200);
  final int warmup = _intArg(args, 'warmup', 50);
  final String? explicitPath = _stringArg(args, 'db');
  final bool keep = args.contains('--keep');

  final Directory workspace = explicitPath == null
      ? Directory.systemTemp.createTempSync('hisab_benchmark')
      : Directory(File(explicitPath).parent.path);
  final File file = File(
    explicitPath ?? '${workspace.path}/$kDatabaseFileName',
  );

  stdout.writeln('benchmark_local_write');
  stdout.writeln('  database   ${file.path}');
  stdout.writeln('  warmup     $warmup writes (discarded)');
  stdout.writeln('  measured   $iterations writes');
  stdout.writeln('  budget     ${formatMicroseconds(kWriteBudgetMicroseconds)} '
      '(NFR-1, p95, on a mid-range 2023 Android device)');
  stdout.writeln('');

  late final LatencySummary summary;
  try {
    summary = await runLocalWriteBenchmark(
      file: file,
      iterations: iterations,
      warmup: warmup,
    );
  } on DatabaseNotEncryptedException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      '\nThe benchmark refuses to measure an unencrypted database: SQLCipher '
      'overhead is the part of NFR-1 that is in question, so a figure without '
      'it would be worse than no figure.',
    );
    exit(2);
  } finally {
    if (!keep && explicitPath == null && workspace.existsSync()) {
      workspace.deleteSync(recursive: true);
    }
  }

  stdout.writeln('  min        ${formatMicroseconds(summary.min)}');
  stdout.writeln('  median     ${formatMicroseconds(summary.median)}');
  stdout.writeln('  p95        ${formatMicroseconds(summary.p95)}');
  stdout.writeln('  max        ${formatMicroseconds(summary.max)}');
  stdout.writeln('');
  stdout.writeln('Paste into apps/mobile/BENCHMARKS.md:');
  stdout.writeln('');
  stdout.writeln(
    '| <date> | <device> | ${Platform.operatingSystem} | $iterations | '
    '${formatMicroseconds(summary.median)} | '
    '${formatMicroseconds(summary.p95)} | '
    '${summary.withinBudget ? "within" : "OVER"} |',
  );
  stdout.writeln('');

  if (!summary.withinBudget) {
    stderr.writeln(
      'p95 ${formatMicroseconds(summary.p95)} is at or over NFR-1\'s '
      '${formatMicroseconds(kWriteBudgetMicroseconds)} budget.',
    );
    exit(1);
  }
  stdout.writeln('p95 is within NFR-1\'s budget.');
}

# Benchmarks

Measured figures, the device each came from, and the command that reproduces
them. A performance number with no device beside it is not a measurement, and a
number nobody can re-run is an opinion — so nothing goes in this file without
both.

## NFR-1 — local write to perceived confirmation, under 100 ms

> Given the encrypted database on a mid-range 2023 Android device, when a local
> write is benchmarked, then the confirmed write is under 100 ms and the figure
> and the device are recorded here.

**What is timed.** `MoneyMovementRepository.record()` end to end: minting the
UUIDv7, deriving the business date, the INSERT, and the read-back that returns
the written row. That is what a screen awaits before it can tell the owner the
money is recorded. Timing the INSERT alone would measure something the owner
never experiences.

**What is included.** SQLCipher. The harness opens a real encrypted database
with a real 256-bit key and refuses to run against an unencrypted one — the
cipher overhead is the part of NFR-1 that was ever in question.

**The number that counts is p95, on hardware.** A run on a development machine
is a regression signal, not the acceptance figure: a laptop's SSD is not a
mid-range phone's flash, and the phone is what the owner is holding.

### Command

```sh
cd apps/mobile
dart run tool/benchmark_local_write.dart
dart run tool/benchmark_local_write.dart --iterations=500 --warmup=100
```

The harness prints min, median, p95 and max, plus a table row ready to paste
below. It exits non-zero when p95 is at or over the 100 ms budget.

### On the phone

`dart run` executes on the development machine. For the acceptance figure, call
`runLocalWriteBenchmark()` from an `integration_test/` case built onto the
handset and record what it prints:

```dart
import 'package:hisab/data/db/encryption.dart';
// tool/benchmark_local_write.dart exports runLocalWriteBenchmark and
// LatencySummary for exactly this.
```

Run it on the device that Epic 1 names as the target — a mid-range 2023 Android
phone (for example a Redmi Note 12 / Galaxy A24 class device, Android 13),
in **release or profile mode**. A debug build measures the debug VM, not the
product.

### Results

| Date | Device | OS | Iterations | Median | p95 | Verdict |
|---|---|---|---|---|---|---|
| _not yet measured_ | — | — | — | — | — | — |

**Status: OUTSTANDING.** Story 1.4 ships the harness; the on-device figure is
taken on hardware and added here as a one-line change. Until this table has a
row from a physical phone, NFR-1 is unverified — the acceptance criterion asks
for a recorded measurement, and an empty table is the honest state, not a
passing one.

## Notes for whoever runs it

- Run it more than once. A single run on a phone that is thermally throttled, or
  that has just installed the app, is not representative.
- Do not run it on an emulator and record the figure here. An emulator uses the
  host's disk.
- If p95 is over budget, the first place to look is the `beforeOpen` handler in
  `lib/data/db/database.dart` and the number of statements per write, not
  SQLCipher: the cipher cost is per page, and a single-row insert touches few.

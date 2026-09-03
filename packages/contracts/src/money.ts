/**
 * AD-1 / AR-1 — money is an integer count of paisa. 1 BDT = 100 paisa.
 * AD-2 / AR-2 — quantity is an integer count of thousandths of a Unit.
 *
 * These are STORAGE types. Every user-facing surface renders taka and whole
 * units; paisa and milli-units never reach a screen, receipt, report or export.
 * Formatting happens at the display edge and nowhere else.
 */

/** An amount in paisa. Field names carrying this end `…Paisa`. */
export type Paisa = number;

/** A quantity in thousandths of a Unit. Field names carrying this end `…Milli`. */
export type Milli = number;

export const PAISA_PER_TAKA = 100;
export const MILLI_PER_UNIT = 1000;

/** Half-to-even rounding — AD-1's rule for FIFO layer splits and percentage discounts. */
export function roundHalfToEven(value: number): number {
  const floor = Math.floor(value);
  const diff = value - floor;
  if (diff > 0.5) return floor + 1;
  if (diff < 0.5) return floor;
  return floor % 2 === 0 ? floor : floor + 1;
}

/**
 * Split `total` into `parts` shares that always re-sum to the whole.
 * AD-1: the residual paisa is assigned to the last share.
 */
export function splitPaisa(total: Paisa, parts: number): Paisa[] {
  if (parts <= 0) throw new RangeError('parts must be > 0');
  const base = Math.floor(total / parts);
  const shares = Array<number>(parts).fill(base);
  shares[parts - 1] += total - base * parts;
  return shares;
}

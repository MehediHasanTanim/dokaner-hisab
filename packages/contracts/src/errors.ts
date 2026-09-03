/**
 * AD-16 / AR-16 — one error envelope for every non-2xx response.
 * `code` is stable and machine-readable; the client resolves Bangla text from
 * it. `message` is for logs and is never shown to an owner.
 */
export interface ErrorEnvelope {
  error: {
    code: ErrorCode;
    message: string;
    details?: Record<string, unknown>;
  };
}

export const ERROR_CODES = [
  'VALIDATION_FAILED',
  'UNAUTHENTICATED',
  'FORBIDDEN',
  'NOT_FOUND',
  'CONFLICT',
  'LIMIT_EXCEEDED',
  'STOCK_INSUFFICIENT',
  'DEPENDENCY_ABSENT',
  'RATE_LIMITED',
  'RETRY_LATER',
  'INTERNAL',
] as const;

export type ErrorCode = (typeof ERROR_CODES)[number];

/**
 * AD-23 / AR-23 — sync outcomes split two ways. A transient failure retries
 * with backoff indefinitely; a permanent rejection stops immediately and moves
 * the envelope to `needs_attention`. Nothing is dropped, nothing retries into
 * a wall.
 */
export type SyncOutcome = 'transient' | 'permanent';

export function classifySync(httpStatus: number, code?: ErrorCode): SyncOutcome {
  if (code === 'RETRY_LATER') return 'transient';
  if (httpStatus >= 500 || httpStatus === 0) return 'transient';
  if (httpStatus >= 400) return 'permanent';
  return 'transient';
}

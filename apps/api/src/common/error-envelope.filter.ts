import { type ArgumentsHost, Catch, type ExceptionFilter, HttpException, Logger } from '@nestjs/common';
import type { ErrorCode, ErrorEnvelope } from '@hisab/contracts';

/**
 * AD-16 / AR-16 — every non-2xx response leaves through here in one shape.
 * The client renders Bangla from `code`; `message` is for logs only.
 *
 * AR-30 — logs carry businessId and a correlation id, never an amount, a party
 * name or a phone number.
 */
@Catch()
export class ErrorEnvelopeFilter implements ExceptionFilter {
  private readonly logger = new Logger(ErrorEnvelopeFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const reply = ctx.getResponse();
    const status = exception instanceof HttpException ? exception.getStatus() : 500;
    const code: ErrorCode = mapStatusToCode(status);
    const message = exception instanceof Error ? exception.message : 'Unhandled error';

    this.logger.error({ code, status, message });

    const body: ErrorEnvelope = { error: { code, message } };
    reply.status(status).send(body);
  }
}

function mapStatusToCode(status: number): ErrorCode {
  switch (status) {
    case 400: return 'VALIDATION_FAILED';
    case 401: return 'UNAUTHENTICATED';
    case 403: return 'FORBIDDEN';
    case 404: return 'NOT_FOUND';
    case 409: return 'CONFLICT';
    case 429: return 'RATE_LIMITED';
    default:  return status >= 500 ? 'INTERNAL' : 'VALIDATION_FAILED';
  }
}

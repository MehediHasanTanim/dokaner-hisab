"""Hisab AI service.

AD-12 / AR-12 — this service holds a READ-ONLY database role and has no write
path. A Transaction Draft is a client-side value object with no persistence;
confirming one calls the same API endpoint as a form-entered transaction.

AD-13 / AR-13 — answers come from a versioned catalogue of hand-written
parameterised queries. The model returns a catalogue entry id and typed
parameters. It never composes, completes or edits SQL.

AD-11 / AR-11 — every query is scoped server-side to the authenticated owner's
business. No prompt content or extracted parameter can widen that scope.
"""

from fastapi import FastAPI

app = FastAPI(title="Hisab AI", version="0.0.0")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "hisab-ai"}

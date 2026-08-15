-- TSO coin economy for normal-user job posting.
-- The backend also creates these objects automatically in init_db().

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS data JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE TABLE IF NOT EXISTS tso_coin_transactions (
  id TEXT PRIMARY KEY,
  username_key TEXT NOT NULL,
  amount INTEGER NOT NULL,
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_tso_coin_transactions_user_time
  ON tso_coin_transactions(username_key, created_at DESC);

-- Registered-account-only job view migration.
-- The previous viewer implementation also stored anonymous viewer fingerprints,
-- which cannot be distinguished from account hashes after the fact. Clear the
-- old rows so the displayed counts start clean under the new registered-only rule.
TRUNCATE TABLE job_post_viewers;

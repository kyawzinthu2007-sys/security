-- Talentshowoff job-post viewer counter
-- Compatible with the JSONB-backed jobs table used by the current backend.
-- Counts unique registered/authenticated account usernames per job.
-- Anonymous/unregistered visitors never create rows and do not increase the count.

CREATE TABLE IF NOT EXISTS job_post_viewers (
  job_id TEXT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  viewer_key TEXT NOT NULL,
  viewed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (job_id, viewer_key)
);

CREATE INDEX IF NOT EXISTS idx_job_post_viewers_job_id
  ON job_post_viewers(job_id);

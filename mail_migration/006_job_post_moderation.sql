-- Talentshowoff job-post moderation
-- Existing jobs are treated as approved for backward compatibility.
CREATE INDEX IF NOT EXISTS idx_jobs_approval_status
ON jobs ((data->>'approvalStatus'));

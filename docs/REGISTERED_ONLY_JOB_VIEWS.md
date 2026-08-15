# Registered-Only Job Post View Counts

The Job Board viewer count now follows this rule:

- A signed-in registered account viewing a job post can increase the count.
- The same registered account is counted only once for that job post.
- An unregistered/anonymous visitor can view the job post, but **does not increase the count**.
- Main creator and second creator accounts are authenticated accounts and are therefore eligible to count as viewers.
- The frontend still displays the current count to everyone.

## Database migration

Run `mail_migration/004_registered_only_job_views.sql` once if the previous anonymous-view version was already deployed. It clears the old viewer rows because the old records did not store whether a viewer was registered or anonymous. New counts will then contain only registered-account views.

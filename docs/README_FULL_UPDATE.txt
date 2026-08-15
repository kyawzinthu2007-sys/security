Talentshowoff full update package

Key changes:
1. Unified sign-in: same user login form for registered users, main creator, and second creators.
2. Creator email login uses username@talentshowoff.com.
3. Mail tab/webmail is creator-only.
4. Added inbound mail webhook for Gmail -> Talentshowoff mailbox delivery through Resend inbound.
5. Main creator can remove registered accounts and second creator accounts.
6. TSO Tasks tab label no longer contains the coin balance. Balance remains on the Tasks page.
7. Screenshot deterrence improved with browser-level controls and capture masking; OS Snipping Tool cannot be technically guaranteed to be blocked by a website.
8. Added MAIL_INBOUND_WEBHOOK_SECRET environment variable.

See UNIFIED_LOGIN_MAIL_SECURITY_UPDATE.md for deployment notes.

JOB POST VIEW COUNTER
- Each job card now shows how many unique viewers have seen the post.
- Opening a job detail records a view through POST /api/jobs/<job_id>/view.
- Signed-in users are counted once per job by username.
- Anonymous viewers are approximated using a SHA-256 hash of IP + User-Agent.
- Run mail_migration/003_job_post_viewers.sql before deploying this feature.
- The displayed number represents unique viewer keys, not a guaranteed count of human individuals.

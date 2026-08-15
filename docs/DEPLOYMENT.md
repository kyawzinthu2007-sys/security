# Talentshowoff — GitHub + Railway + Supabase + Resend

This version is prepared for a GitHub repository deployed to Railway, with
Supabase PostgreSQL for persistent data and Resend for email delivery.

## 1. Push the project to GitHub

The files in this folder must be at the repository root. GitHub should show:

```text
Procfile
railway.json
requirements.txt
backend/
frontend/
.env.example
.gitignore
```

Do not upload a real `.env` file or any secret values.

## 2. Supabase

1. Create/open your Supabase project.
2. Open the database connection settings and use the Session Pooler
   PostgreSQL connection string recommended for a persistent web service.
3. Put that complete connection string into Railway as `DATABASE_URL`.
4. The application creates its required tables automatically on first request.

## 3. Resend

1. Verify `talentshowoff.com` in Resend.
2. Add the DNS records Resend gives you at your domain DNS provider.
3. Create a Resend API key.
4. In Railway set:

```text
RESEND_API_KEY=your_resend_key
RESEND_FROM=Talentshowoff <noreply@talentshowoff.com>
APP_BASE_URL=https://talentshowoff.com
```

The application does not require a separate mailbox to send mail. Receiving
replies is a separate email-hosting concern.

## 4. Railway

Create a Railway project from the GitHub repository. The repository already
contains both a `Procfile` and `railway.json` with the Gunicorn start command.

Set these Railway variables:

```text
DATABASE_URL=your_supabase_session_pooler_url
TSO_OWNER_PASSWORD=choose_a_strong_unique_password
TSO_EDITOR_PASSWORD=choose_a_strong_unique_password
RESEND_API_KEY=your_resend_key
RESEND_FROM=Talentshowoff <noreply@talentshowoff.com>
APP_BASE_URL=https://talentshowoff.com
GOOGLE_CLIENT_ID=your_google_web_client_id
GEMINI_API_KEY=optional
MAIL_SUPABASE_URL=optional_see_mail_section_below
MAIL_SUPABASE_SERVICE_ROLE_KEY=optional_see_mail_section_below
MAIL_DOMAIN=talentshowoff.com
```

Railway supplies `PORT` automatically.

## 5. Domain

Attach `talentshowoff.com` as the Railway custom domain and add the DNS
record Railway provides. After the domain is live, make sure `APP_BASE_URL`
exactly matches the HTTPS address used by visitors.

## 6. Google Sign-In

In Google Cloud, configure the OAuth web client with the production HTTPS
domain under Authorized JavaScript origins. Set the resulting client ID as
`GOOGLE_CLIENT_ID` in Railway.

## 6b. Mail (optional — the "Mail" tab)

The Mail tab lets a logged-in user opt in to create a `@talentshowoff.com`
mailbox and send/receive messages. It uses a **separate** Supabase project
from the job board's own `DATABASE_URL` — mailboxes link back to job board
accounts by username, with no separate mail password to manage.

1. Create a **second, separate** Supabase project (do not reuse the job
   board's project).
2. Open its SQL Editor and run the full contents of
   `mail_migration/001_mail_schema.sql` from this repository.
3. Open Project Settings -> API (or Data API) and copy:
   - Project URL -> `MAIL_SUPABASE_URL`
   - service_role secret key -> `MAIL_SUPABASE_SERVICE_ROLE_KEY`
4. In Railway, set:

```text
MAIL_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
MAIL_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
MAIL_DOMAIN=talentshowoff.com
```

5. Sending mail reuses the same `RESEND_API_KEY` already configured above —
   no separate Resend setup needed.

If `MAIL_SUPABASE_URL` / `MAIL_SUPABASE_SERVICE_ROLE_KEY` are left unset, the
Mail tab still appears for logged-in users but shows "Mail isn't set up yet"
instead of erroring — the rest of the job board is unaffected either way.

## 7. First deployment test

- Open the Railway/custom-domain URL.
- Create a visitor account with a real email address.
- Confirm the Resend verification email arrives.
- Verify and sign in.
- Sign in as `tsoofficial` using the `TSO_OWNER_PASSWORD` you configured.
- Test posting/editing jobs and submitting an application.
- Test the creator messaging features.
- If mail is configured: sign in, open the Mail tab, create a mailbox, and
  send a test message to confirm it arrives via Resend.
- Redeploy Railway and confirm the data remains available through Supabase.

## Security notes

The application no longer contains default creator passwords. If the required
creator password variables are missing, initialization fails rather than
silently using a known credential.

Database initialization is lazy and protected by a process-local lock so a
brief Supabase startup/network issue does not prevent Gunicorn from binding to
Railway's port.

# Talentshowoff Job Board — GitHub + Railway + Supabase + Resend

This project deploys from GitHub to Railway. Persistent data is stored in
Supabase PostgreSQL. Resend handles verification and application emails.

## Repository layout

Upload the **contents** of this folder (not the folder itself) to the root
of your GitHub repo:

```
Procfile               # tells Railway/gunicorn how to start the app
railway.json            # Railway build/deploy config (Nixpacks)
requirements.txt         # single source of truth for Python deps
start.sh / start-windows.bat
.env.example             # placeholder values only — never commit real secrets
.gitignore
.gitattributes            # forces LF line endings on text files (prevents corruption)
README.md

backend/
  app.py                  # Flask app — all routes + Supabase logic

frontend/
  index.html               # the whole React app (Babel-in-browser, no build step)
  logo.jpg

mail_migration/
  001_mail_schema.sql
  003_job_post_viewers.sql
  004_registered_only_job_views.sql
  005_tso_coins.sql

docs/
  DEPLOYMENT.md
  README_FULL_UPDATE.txt
  REGISTERED_ONLY_JOB_VIEWS.md
  UNIFIED_LOGIN_MAIL_SECURITY_UPDATE.md
```

Do not commit a real `.env` file or any API keys/passwords.

## How to upload correctly

`frontend/index.html` is one large file (~2,100 lines, no line breaks inside
the script logic in places). GitHub's drag-and-drop **Upload files** page can
silently fail to save changes if you navigate away before clicking the green
**"Commit changes"** button at the bottom of the page — the file can look
uploaded in the UI without actually being committed. After uploading:

1. Scroll to the bottom of the upload page and click **Commit changes**.
2. Refresh the repo's main page and confirm the commit count increased.
3. Open `frontend/index.html` in GitHub and confirm it ends with:
   `root.render(<App />);` followed by `</script>`.

## Environment variables

Set these in Railway → your service → **Variables** (never in a Dockerfile
or committed file):

| Variable | Required | Notes |
|---|---|---|
| `DATABASE_URL` | Yes | Supabase Postgres session pooler URL |
| `TSO_OWNER_PASSWORD` | Yes | Password for the `tsoofficial` creator account |
| `TSO_EDITOR_PASSWORD` | Yes (first boot only) | Password for the built-in `pageadmin` account |
| `RESEND_API_KEY` | Yes | For verification/application emails |
| `RESEND_FROM` | Yes | e.g. `Talentshowoff <noreply@talentshowoff.com>` |
| `APP_BASE_URL` | Yes | e.g. `https://talentshowoff.com` |
| `GOOGLE_CLIENT_ID` | Optional | Enables Google Sign-In |
| `GEMINI_API_KEY` | Optional | Enables the AI Assistant feature |
| `MAIL_SUPABASE_URL` / `MAIL_SUPABASE_SERVICE_ROLE_KEY` | Optional | Separate Supabase project for the Mail tab |
| `MAIL_INBOUND_WEBHOOK_SECRET` | Optional | Secures the Resend inbound webhook |

Railway provides `PORT` automatically — don't set it manually.

**Every request, including the homepage, checks that `DATABASE_URL`,
`TSO_OWNER_PASSWORD`, and (on first boot) `TSO_EDITOR_PASSWORD` are set.**
If any are missing, the server returns an error response instead of the
page — this is the most common cause of a blank/white screen in production.

## User sign-in

Users sign in with their Talentshowoff email address, not their internal
username:

```
yourname@talentshowoff.com
Password: account password
```

The sign-up email may be Gmail or another valid address, used for
verification/recovery. Google Sign-In is available when `GOOGLE_CLIENT_ID`
is configured.

## Creator accounts

- **Main creator** — Username: `tsoofficial`, password: the value of
  `TSO_OWNER_PASSWORD`.
- **Built-in editor** — Username: `pageadmin`, password: the value of
  `TSO_EDITOR_PASSWORD` at first database initialization.

Passwords are never stored in this repository. Additional creator accounts
are managed by the main creator through the Creator management screen.

## Database

Tables are created automatically on first request. No manual setup needed.
Data lives in Supabase, not Railway's ephemeral filesystem, so deploys and
restarts don't erase it.

## Local Windows test

Install Python, set the required environment variables (especially
`DATABASE_URL`, `TSO_OWNER_PASSWORD`, `TSO_EDITOR_PASSWORD`), then run
`start-windows.bat` or:

```
python backend/app.py
```

Serves on `http://localhost:5000` by default.

## Job-post moderation and security

- Registered-user job posts are created as `pending` and are **not publicly visible** until a creator/admin approves them.
- The creator moderation queue can approve or reject submissions. Rejected submissions stay hidden and the original 2 TSO coin posting fee is refunded once.
- Existing posts without an approval status are treated as approved for backward compatibility.
- The server adds security headers, lightweight per-route abuse throttling, strict authorization checks, and no-store API responses.
- Browser-side copy, context-menu, print, common developer-tool shortcuts, drag/export actions, and visibility changes are blocked/deterred where the browser permits. **A normal website cannot technically guarantee prevention of screenshots made by the OS, another device, browser extensions, accessibility tools, or third-party capture software.**
- Keep Railway HTTPS enabled and never expose passwords/API keys in client-side code or committed files.

## Security

- Passwords are hashed before creator accounts are stored in PostgreSQL.
- Production secrets come only from environment variables, set in Railway's
  dashboard — never in a Dockerfile `ARG`/`ENV`, never committed to git.
- No default creator passwords are embedded in the application.

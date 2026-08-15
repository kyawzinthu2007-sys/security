# Talentshowoff full update — unified login, creator-only mail, account management, TSO coins

## Included
- One **Sign in** box accepts `name@talentshowoff.com` for normal registered users, the main creator, and second creators. There is no separate creator login in the navigation.
- Normal registered users keep the daily **6 TSO coin** reward and pay **2 TSO coins** for a job post. The Tasks tab no longer displays the coin balance in its tab label; the balance is shown inside Tasks.
- Main creator can remove registered user accounts and second creator accounts.
- `@talentshowoff.com` webmail is creator-only. Normal users do not see or access the Mail tab.
- Added Resend inbound webhook endpoint at `/api/mail/inbound` so mail sent from Gmail can be placed into a Talentshowoff creator mailbox.
- Added browser best-effort screenshot/capture deterrence: PrintScreen/keyboard capture shortcuts, context menu, copy/cut, and visibility masking.

## Important screenshot limitation
A normal website cannot reliably prevent the Windows Snipping Tool, another device camera, or OS-level screen capture. This release blocks common browser shortcuts and masks the page when browser visibility changes, but it cannot guarantee that no screenshot is ever taken.

## Gmail -> Talentshowoff mail receiving
For inbound mail to work, configure your mail provider/domain DNS for inbound mail and point the provider's inbound webhook to:
`POST https://YOUR-DOMAIN/api/mail/inbound`

Set `MAIL_INBOUND_WEBHOOK_SECRET` and configure the same value in the webhook request as `X-TSO-Mail-Secret`. Ensure the domain's MX/DNS records are configured according to the inbound provider's current instructions.

## Deployment
Run the existing database migrations and redeploy the `railway-ready` application. Existing user data is preserved.

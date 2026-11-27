# Candidate patch 16: "Sign in to chat" composer state and readable upload refusals

Status: **candidate, not served.** No feedback portal runs this patch. It becomes part of a release only when a
build that includes it is served; that release then gets its own `releases/<release>/` directory with the patch
copied into `patches/`, a `release.json` row, `series` and `SHA256SUMS`, as for every other release.

| | |
| --- | --- |
| Base | upstream `v0.16.1` at `4f73e31823499db8626569369cff016d56be80c6` plus the public patches of `0.16.1-void.unified25-20261126` in `series` order |
| Applies after | `15-zero-anonymous-guards.patch` |
| File | `16-widget-sign-in-to-chat.patch` (23 files, sha256 `e5a7f8a3894dfca79e4bc02ba1c941bdc19361448f99beed063d671d0e059508`) |
| Widget SDK | unchanged at runtime (`0.1.6`); only the `EventMap` type gains `auth-required` |

Checked with `git apply --check` on that public base only. The release build applies it to the complete tree, which
also contains the patches withheld under coordinated disclosure; re-run `git apply --check` there and rebase if needed
before cutting a release.

## What it changes

1. **Composer state for anonymous visitors when anonymous access is off.** The widget loader exposes the workspace's
   anonymous switch (`publicPortalConfig.features.allowAnonymous`, already client-safe). When it is off and the visitor
   is not identified, the Messages view shows "Sign in to chat" (Thai: "เข้าสู่ระบบเพื่อแชท") instead of the composer.
   Its button emits the widget event `auth-required` with `{ reason: "conversation" }` through the existing
   `quackback:event` channel, so a host page can open its own sign-in (`Quackback("on", "auth-required", ...)`). The
   prompt appears only after `identityResolved`. **Limitation:** the SDK's default anonymous identify resolves identity
   before a native host's identify ACK. If the Messages view is open during that interval, which is usually under a
   second, a signed-in visitor sees the prompt until the ACK lands; it then gives way to the thread. A visitor whose
   host identify is refused keeps the prompt, which is accurate, since their send would fail. A host should answer
   `auth-required` by re-identifying when it has a session, and open its sign-in only when it has none.
   - Why: with anonymous access off, sending fails before patch 15 is ever reached. The anonymous session the send
     needs is refused, and the composer returns silently with the text still in it, so the visitor sees nothing.
     A visitor whose host identify was refused (for example 409 `EMAIL_IN_USE`) is left anonymous and hits the same
     silent failure, attachments included.
2. **Readable upload refusals.** `uploadFile` maps any HTTP 413 to `reason: "too_large"`, including an HTML 413 from
   a proxy in front of the app; the attachment tile then shows its localized "Over {size} MB". It also maps 403
   `ANONYMOUS_DISABLED` to a new `reason: "sign_in_required"`, which shows "Sign in to send files". Before, both showed
   a bare "Upload failed" or the raw server text.

New strings are added to all 13 catalogs: `widget.signInToChat.title`, `.body`, `.action` and
`files.upload.error.signInRequired`.

## Upstream fit

- It reuses upstream's own seams: `useWidgetAuth().identityResolved` and `emitEvent`, the generic `quackback:event`
  forwarding in the SDK, the tray's `errorReason` localization, and the server's existing anonymous switch.
- Workspaces with anonymous access on are unchanged.
- It is written so it can be offered upstream as is.

## Tests

Run in `apps/web` with `bunx vitest run`:

- `src/components/widget/__tests__/widget-messenger-sign-in.test.tsx` (new, 7 tests):
  - the prompt replaces the composer, and its button emits `auth-required`
  - the Thai catalog is used
  - no prompt while identity is still resolving, and the prompt gives way to the thread when a late identify lands
  - an identified visitor gets the thread
  - an anonymous-on workspace is unchanged
- `src/lib/client/files/__tests__/upload-file-refusals.test.ts` (new, 4 tests):
  - an HTML 413 and a JSON 413 both become `too_large`, and a 100 MB video limit message is shown
  - `ANONYMOUS_DISABLED` becomes `sign_in_required`
  - any other 403 is unchanged
- `src/components/shared/__tests__/composer-attachment-tray.test.tsx`: `sign_in_required` copy.

Results on the patched public tree:

- `src/components/widget`, `src/lib/client/files`, `use-file-upload` and the tray: 44 files, 263 tests, all pass.
- Without the source changes, 6 of the 10 new tests fail (written before the late-identify test was added).
- `src/locales`: 12 failures, the same 12 as on the unpatched public unified25 tree. They are untranslated strings
  already present, and the failure list is identical before and after this patch.

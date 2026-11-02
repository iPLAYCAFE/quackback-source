# Quackback, as modified and served by iPLAYCAFE: Corresponding Source

iPLAYCAFE runs a modified version of [Quackback](https://github.com/QuackbackIO/quackback),
the open-source feedback and support platform, at its feedback portals. Quackback is licensed
under the GNU Affero General Public License, version 3 (AGPL-3.0). Section 13 of that license
says that users who interact with a modified version over a network must be offered its
Corresponding Source. This repository is that offer.

It does not copy Quackback. Each release here names an exact upstream commit and the ordered
patches that iPLAYCAFE applies to it, plus the recipe that builds the served container image.
The upstream source together with these patches is the source of the program you used.

## Releases

| Release | Served at | Upstream | Patches |
| --- | --- | --- | --- |
| [`0.14.1-void.serving.20261025p-u1`](releases/0.14.1-void.serving.20261025p-u1/) | the iPLAYCAFE feedback portal (`feedback.iplaycafe.dev`) | `v0.14.1` at `965e713431a3da83dd7caa63639c27dd064bea5d` | 18 in order: 15 published, 3 withheld for now |
| [`0.14.1-native.18`](releases/0.14.1-native.18/) | the brand feedback portals (PaiKaan, qcaddy, rerolla) | `v0.14.1` at `965e713431a3da83dd7caa63639c27dd064bea5d` | 23 in order: 22 published, 1 withheld for now |

Each `releases/<release>/` directory holds:

- `release.json`: the upstream repository, tag and commit, the sha256 of upstream's `bun.lock`
  (no patch changes it), the Bun version and the digest-pinned build and runtime base images,
  the digest of the image that was served, and one row per patch (order, file, sha256, a
  one-line summary, and whether it is published or withheld).
- `series`: the patch order that `apply.sh` follows.
- `patches/`: the patch files, byte-for-byte the files used for the served build.
- `SHA256SUMS`: checksums of everything in the directory.

## Rebuilding

You need `git`, a POSIX shell with `sha256sum`, and Docker.

```sh
sh apply.sh 0.14.1-native.18 ./quackback-native18
cd ./quackback-native18
docker build --file apps/web/Dockerfile --tag quackback:0.14.1-native.18 .
```

`apply.sh` checks the release's `SHA256SUMS`, clones upstream Quackback, checks out the exact
commit, confirms that `bun.lock` matches, then applies each patch with `git apply --check` and
`git apply`, in the order of `series`. The patched tree is built with upstream's own
`apps/web/Dockerfile`; the first patch of every release pins that Dockerfile's `oven/bun` base
images by digest, so the build does not depend on a floating tag. Dependencies install from the
unchanged upstream `bun.lock` (`bun install --frozen-lockfile` inside the Dockerfile).

You can do the same by hand: `git checkout --detach <commit>`, then `git apply` each file in
`series` order. Lines that start with `# ` are comments.

The patches touch the web app (`apps/web`), the database package (`packages/db`, including new
migrations), the email package (`packages/email`) and the embeddable widget SDK
(`packages/widget`). Configuration that differs per deployment (domains, credentials, storage
buckets, email transport settings) is supplied at runtime through environment variables and is
not part of the source.

## Withheld patches

Some patches fix security weaknesses that are also present in upstream Quackback. Those have
been reported to the Quackback maintainers privately, and are withheld here until upstream
publishes a fix or 30 days after the report, whichever is first. A withheld patch appears in
`series` as `#WITHHELD <file> sha256=<hex>` and in `release.json` with `"status": "withheld"`:
the sha256 is that of the exact file that will be published, so you can check it when it
appears. Until then a tree built from this repository lacks those patches and is not the
complete source of the release; `apply.sh` says so when it finishes.

## Scope

This repository covers the Quackback program only. The hosting platform that runs the
container, and the separate services that Quackback talks to over the network (such as the
email relay), are separate programs and are not derived from Quackback.

## License

Quackback is licensed under AGPL-3.0, and so are the patches in this repository; see
[`LICENSE`](LICENSE). Quackback is a trademark of its owners; this repository is not affiliated
with or endorsed by them.

## Questions

Open an issue in this repository to ask about the source of a release that is not listed here.

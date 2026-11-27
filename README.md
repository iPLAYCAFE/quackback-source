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
| [`0.16.1-void.unified26-20261127`](releases/0.16.1-void.unified26-20261127/) | published, not yet served | `v0.16.1` at `4f73e31823499db8626569369cff016d56be80c6` | 15 in order: 12 published, 3 withheld for now |
| [`0.16.1-void.unified25-20261126`](releases/0.16.1-void.unified25-20261126/) | all five iPLAYCAFE and brand feedback portals (`feedback.iplaycafe.dev`, `feedback.iplaycafe.app`, `feedback.rerolla.store`, `feedback.qcaddy.app`, `feedback.paikaan.app`) from 2026-11-26 | `v0.16.1` at `4f73e31823499db8626569369cff016d56be80c6` | 14 in order: 11 published, 3 withheld for now |
| [`0.16.1-void.unified24-20261125`](releases/0.16.1-void.unified24-20261125/) | all five iPLAYCAFE and brand feedback portals (`feedback.iplaycafe.dev`, `feedback.iplaycafe.app`, `feedback.rerolla.store`, `feedback.qcaddy.app`, `feedback.paikaan.app`) from 2026-11-24 20:11Z | `v0.16.1` at `4f73e31823499db8626569369cff016d56be80c6` | 14 in order: 11 published, 3 withheld for now |
| [`0.16.1-void.unified23-20261124`](releases/0.16.1-void.unified23-20261124/) | all five iPLAYCAFE and brand feedback portals (`feedback.iplaycafe.dev`, `feedback.iplaycafe.app`, `feedback.paikaan.app`, `feedback.qcaddy.app`, `feedback.rerolla.store`) from 2026-11-24 | `v0.16.1` at `4f73e31823499db8626569369cff016d56be80c6` | 13 in order: 10 published, 3 withheld for now |
| [`0.16.0-void.unified22-20261124`](releases/0.16.0-void.unified22-20261124/) | the iPLAYCAFE feedback portal (`feedback.iplaycafe.app`), 2026-11-24 10:21Z to 12:20Z only | `v0.16.0` at `8547f2bdadb8d2d584afec1e5faf87a4427218fc` | 12 in order: 9 published, 3 withheld for now |
| [`0.15.0-void.unified20-20261121`](releases/0.15.0-void.unified20-20261121/) | all five iPLAYCAFE and brand feedback portals (`feedback.iplaycafe.dev`, `feedback.iplaycafe.app`, `feedback.paikaan.app`, `feedback.qcaddy.app`, `feedback.rerolla.store`) | `main` (`v0.15.0+`) at `793c11db6413478308d5d5030b221513a15b7289` | 9 in order: 6 published, 3 withheld for now |
| [`0.15.0-void.unified19-20261119`](releases/0.15.0-void.unified19-20261119/) | all five iPLAYCAFE and brand feedback portals (`feedback.iplaycafe.dev`, `feedback.iplaycafe.app`, `feedback.paikaan.app`, `feedback.qcaddy.app`, `feedback.rerolla.store`) | `main` (`v0.15.0+`) at `12379251837d47a67d8a4b389370602e826c07f9` | 9 in order: 6 published, 3 withheld for now |
| [`0.15.0-void.unified18-20261116`](releases/0.15.0-void.unified18-20261116/) | all five iPLAYCAFE and brand feedback portals (`feedback.iplaycafe.dev`, `feedback.iplaycafe.app`, `feedback.paikaan.app`, `feedback.qcaddy.app`, `feedback.rerolla.store`) | `v0.15.0` at `fe575ec7e4fdbdc506c37581f63f6f6fe0fa8d70` | 9 in order: 6 published, 3 withheld for now |
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

# Nizlo Remote for macOS

This branch builds a separate macOS remote client based on RustDesk 1.5.0. It uses
`NizloRemote.app`, bundle identifier `com.nizlo.remote.client`, and the
`nizlo-remote://` URL scheme. Stock `RustDesk.app` stays installed and can be
selected as an optional provider. The Nizlo rendezvous server and its public
verification key are preset; access passwords and enrollment tokens are never
compiled into the app.
The existing lightweight `Nizlo Remote.app` web launcher keeps its own
`com.nizlo.remote` bundle identifier and `nizlo://` URL scheme.

Upstream source is the RustDesk `1.5.0` tag at commit
`fada664df7a294d1d1a9ca3e7cd3637069122f17`.

The upstream RustDesk project and its AGPL-3.0 license are retained in this
source tree. Distribute the corresponding source with every binary release.

## Build

Dispatch `.github/workflows/nizlo-macos.yml` to build unsigned Apple Silicon
and Intel disk images. It uses the pinned Flutter, Rust, vcpkg, and native build
dependencies from upstream's macOS workflow. The unsigned images are CI
artifacts, not installable release packages.

After downloading a build artifact, mount its disk image, copy
`NizloRemote.app` to a staging directory, sign all nested code and the app with
the Nizlo Developer ID Application certificate using
`.github/scripts/sign-macos-app.sh`, then create a fresh disk image. Submit the
image to Apple notarization, staple the accepted ticket, and verify the app's
bundle identifier, certificate team, Gatekeeper acceptance, and architecture
before distribution. Publish a source archive for the exact commit alongside
the image. Do not sign with the upstream RustDesk identity.

For the first owner-controlled pilot, use `scripts/install-pilot-macos.sh` on
the signed, stapled disk image. It checks the bundle identity, version,
Developer ID team, and Gatekeeper assessment before copying the app into
`/Applications/NizloRemote.app`.

## Pilot

Install the signed app alongside stock RustDesk. Verify the Nizlo server and
public key, service launch, Accessibility and Screen Recording permissions,
outbound connection to a Windows pilot, inbound connection from a Windows
pilot, and independent operation of the stock RustDesk client. Keep Nizlo as
the primary provider only after both pilot directions work.

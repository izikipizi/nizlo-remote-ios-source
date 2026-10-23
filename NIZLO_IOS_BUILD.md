# Nizlo Remote for iPhone

This companion viewer connects to the same Nizlo rendezvous server as Nizlo Remote for Mac. Its iOS bundle identifier is `com.nizlo.remote.ios`, display name is **Nizlo Remote**, and incoming connection links use `nizlo-remote://connection/new/<device-id>?password=<one-time-handoff>`. The Nizlo technician app offers RustDesk as an alternative viewer.

The iOS app applies the Nizlo server profile before Rust initialization. It does not include an endpoint password or enrollment token. Deep-link contents must never be logged; the selected remote app receives the connection link only when the technician taps Connect in Nizlo.

Dispatch `.github/workflows/nizlo-ios.yml` for an unsigned iPhone app and Xcode archive. The iPhone release starts at version `1.0.0` build `1`, independently of the upstream Flutter package version. Export the archive for App Store Connect using Apple team `2B6746PVGB` and a provisioning profile for `com.nizlo.remote.ios`, then install it on a physical iPhone and test against an authorized endpoint before release. A simulator-only build cannot validate a real remote session. Publish the corresponding source for the exact binary revision with any distribution of this AGPL-based viewer.

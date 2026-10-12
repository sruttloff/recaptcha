# Changelog

## 2.0.1 — 2026-10-12

This release expands the documentation and updates the metadata for this fork.

- Document features, requirements, installation, upgrades, and key configuration.
- Explain CAPTCHA activation, missing-key behavior, and authentication-source registration.
- Add troubleshooting, validation instructions, maintenance notes, and support links.
- Credit the original author and SaaS-Secure.com's maintenance of this fork.
- Point the plugin URL to `sruttloff/recaptcha` and align the documented version with plugin metadata.

The registration logic and gem dependency are unchanged from version 2.0.0.

## 2.0.0 — 2026-10-12

Import the local Redmine 6.x adaptation into this fork, preserving the upstream Git history.

- Declare Redmine 6.0.0 as the minimum version and update the registration template for Redmine 6.1.
- Verify CAPTCHA responses in a controller callback instead of replacing Redmine's registration action.
- Use namespaced helpers and a controller patch compatible with the plugin autoloading structure.
- Require the `recaptcha` gem in the 5.x series (`~> 5.17`).
- Render and verify the CAPTCHA only when both keys are configured.
- Preserve Redmine's authentication-source registration path without CAPTCHA verification.

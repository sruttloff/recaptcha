# reCAPTCHA for Redmine 6.1

This plugin adds a Google reCAPTCHA v2 checkbox to Redmine's account registration page and verifies the response before regular self-registration continues.

This fork is maintained for Redmine 6.1 by **[SaaS-Secure.com, S. Ruttloff](https://www.saas-secure.com/)**. It is based on the [original reCAPTCHA plugin by Christoph Dwertmann](https://github.com/cdwertmann/recaptcha).

**Version: 2.0.1.** This fork targets Redmine **6.1**. The plugin declares a minimum version of Redmine **6.0.0**, but compatibility with other Redmine versions needs separate validation. See the [changelog](CHANGELOG.md) for release notes. For Redmine 5.x, use the upstream 1.0.0 code instead of this fork's current release.

## Features

- Display a reCAPTCHA v2 checkbox on the account registration form.
- Verify CAPTCHA responses on the server before normal self-registration.
- Keep Redmine's own registration action and account activation rules.
- Redisplay the submitted form with an error if CAPTCHA verification fails.
- Use the current Redmine interface language for the CAPTCHA widget.
- Configure the site key and secret key in Redmine's plugin settings.
- Leave registration available when a complete key pair has not been configured.

## Requirements

- Redmine 6.1 and the Ruby/Rails versions supported by that Redmine release.
- The `recaptcha` gem in the plugin's `Gemfile`: `~> 5.17` (5.17 or later within the 5.x series).
- A Google reCAPTCHA **v2 checkbox** site key and matching secret key for the hostname used by your Redmine installation.
- Browser access to Google's CAPTCHA resources and server access to Google's verification service over HTTPS.
- Self-registration enabled in Redmine if users should be able to create accounts themselves.

The current integration uses the v2 widget and verification flow. It does not implement reCAPTCHA v3 scores or the reCAPTCHA Enterprise assessment API.

## Installation

Check out the desired published revision of this fork in Redmine's plugin directory. The directory must be named exactly `recaptcha`:

```sh
cd /path/to/redmine/plugins
git clone --branch v2.0.1 https://github.com/sruttloff/recaptcha.git recaptcha
cd /path/to/redmine
bundle install
```

Then restart the Redmine application server. The restart command depends on your deployment, such as Puma under systemd, Passenger, or Docker.

This plugin has no database migrations and ships no local JavaScript or stylesheet assets. It does not require a plugin migration or asset compilation step of its own.

For Docker deployments, include the plugin and its gems in the application image or persistent plugin setup used by your installation, then recreate or restart the application service as appropriate.

## Setup

1. Create a matching key pair for **reCAPTCHA v2, checkbox** in Google's [reCAPTCHA administration](https://www.google.com/recaptcha/admin). Include the hostname on which users access Redmine.
2. In Redmine, open **Administration → Plugins → Recaptcha plugin → Configure**.
3. Enter the keys as follows:

   | Plugin setting | Google key | Purpose |
   | --- | --- | --- |
   | Public Key | Site key | Display the widget in the browser |
   | Private Key | Secret key | Verify the submitted response on the server |

4. Save the plugin settings.
5. Under **Administration → Settings → Authentication**, enable the required self-registration mode. Email activation, manual activation, and automatic activation continue to follow Redmine's configuration.
6. Open `/account/register` in a signed-out browser session and check the registration flow.

The private key is stored in Redmine's plugin settings and the configuration form displays it as a text field. Include it in your handling of application configuration and database backups; do not include it in issue reports.

### When the CAPTCHA is active

Both keys must contain a nonblank value. Leading and trailing whitespace is ignored.

| Situation | Behavior |
| --- | --- |
| Both keys configured; normal self-registration POST | The response is verified before Redmine processes registration |
| Verification succeeds | Redmine continues with its configured registration and activation rules |
| Verification fails | The registration form is rendered again with the CAPTCHA error; registration does not continue |
| Either key missing or blank | The widget is hidden and verification is skipped |
| Registration through Redmine's authentication-source session | The plugin skips verification |
| Self-registration disabled | Redmine's normal access rules apply |

When a normal registration POST arrives without a complete key pair, the plugin writes this warning to the Rails log:

```text
Recaptcha plugin: no key pair configured, skipping captcha verification
```

The plugin protects regular account self-registration. It does not add CAPTCHA checks to login, password recovery, issue forms, or API requests.

## Upgrade

Back up the plugin directory and Redmine database, and commit or save any local plugin changes before switching revisions. For an existing checkout of this fork:

```sh
cd /path/to/redmine/plugins/recaptcha
git fetch origin --tags
git checkout v2.0.1
cd /path/to/redmine
bundle install
```

Restart Redmine and repeat the registration checks below. Existing public/private key settings retain their names and can be reused if they are a matching v2 checkbox key pair.

When replacing a plugin directory manually, remove the old plugin files first rather than copying the new version over them. In particular, the old `lib/account_controller_patch.rb` from version 1.0.0 must not remain alongside the new namespaced patch.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| No CAPTCHA appears | Confirm both keys are saved, self-registration is enabled, and the page is opened while signed out |
| Invalid site key or domain error | Check that the key is for a v2 checkbox and that the current hostname is allowed in Google's configuration |
| Verification fails after solving the CAPTCHA | Check that public/private keys belong together and that the server can reach Google's verification service; reload the form and try a fresh response |
| Widget remains empty or does not load | Check browser network errors, content blockers, and any content security policy that restricts Google's resources |
| Missing gem or initialization error | Run `bundle install` in the Redmine root, restart the application, and check that no obsolete plugin files remain |
| Registration form differs from another plugin's form | Check for competing overrides of `app/views/account/register.html.erb` |

See Google's documentation for [displaying the v2 widget](https://developers.google.com/recaptcha/docs/display) and [verifying responses](https://developers.google.com/recaptcha/docs/verify) for details about the provider integration.

## Changes for Redmine 6.1

- Replace the old override of `AccountController#register` with a `before_action`, preserving Redmine's own registration logic.
- Place plugin helpers and the controller patch in a namespace that follows Rails/Zeitwerk autoloading conventions.
- Apply the controller patch through Redmine's plugin initialization cycle, including code reloads.
- Update the registration template for Redmine 6.1 fields and settings.
- Use the `recaptcha` 5.x integration and pass the plugin's keys explicitly.
- Skip rendering and verification when a complete key pair is unavailable.

## Validation and development

From the Redmine root, check autoloading in the environment used by the installation:

```sh
RAILS_ENV=production bundle exec rake zeitwerk:check
```

After installation or an upgrade, check these workflows in a test installation:

1. With both keys set, the signed-out registration page displays the CAPTCHA.
2. Submitting without a valid CAPTCHA response redisplays the form with an error and does not create an account.
3. A valid response allows registration to proceed with the configured Redmine activation mode.
4. Clearing either key hides the widget and leaves ordinary registration available.
5. Disabled self-registration and authentication-source registration retain Redmine's expected behavior.
6. Restarting the application, and reloading code in development, do not produce duplicate callbacks or autoloading errors.

Version 2.0.1 changes documentation and plugin metadata. Run the checks above when deploying it to your installation.

The plugin overrides Redmine's registration template in `app/views/account/register.html.erb`. Compare it with the core template whenever upgrading Redmine, and retain the conditional `recaptcha_tags` call. Other plugins overriding the same template may require integration work.

## More plugins from SaaS-Secure.com

- **[Redmine UX Toolkit](https://www.saas-secure.com/online-services/redmine-ux-toolkit.html)** – Interface improvements, dashboards, checklists, templates, reminders, and administration tools.
- **[SCM Creator for Redmine](https://www.saas-secure.com/online-services/redmine-scm.html)** – Repository management for Git, Subversion, Mercurial, Bazaar, and GitHub.

These plugins are optional additions and are not required by reCAPTCHA. For hosting and other services, visit **[www.saas-secure.com](https://www.saas-secure.com/)**.

## Support and credits

Report issues with this fork through **[GitHub Issues](https://github.com/sruttloff/recaptcha/issues)**. Include your Redmine, Ruby, Rails, and `recaptcha` gem versions, the registration mode, and steps to reproduce the problem. Remove keys and personal data from logs and screenshots before sharing them.

- Original plugin: [Christoph Dwertmann](https://github.com/cdwertmann/recaptcha).
- Redmine 6.1 adaptation and maintenance of this fork: [SaaS-Secure.com, S. Ruttloff](https://www.saas-secure.com/).
- CAPTCHA service: Google reCAPTCHA; Ruby integration: the `recaptcha` gem.

## License

The original plugin identifies its license as **MIT** in the upstream README. The original author attribution is retained in this fork.

Recaptcha Redmine 6.x plugin
============================

Redmine 6.x plugin that adds a reCAPTCHA to the account registration page.

- Installation: clone it to your plugins directory, run `bundle install` and restart Redmine.
- Configuration: on the plugin setting page, enter your reCAPTCHA v2 keypair.
  Without a keypair the captcha is neither rendered nor verified, so registration keeps working.
- Compatibility: Redmine 6.x (tested against 6.1). For Redmine 5.x use version 1.0.0 of this plugin.
- Copyright: MIT License

Implementation notes
--------------------

- The captcha is verified in a `before_action` on `AccountController#register`
  (`lib/recaptcha_plugin/patches/account_controller_patch.rb`). Redmine's own
  `register` action is left untouched, so core changes to the registration flow
  are picked up automatically.
- `app/views/account/register.html.erb` overrides the core template and has to be
  kept in sync with it when upgrading Redmine; it is a copy of the Redmine 6.1
  template plus the `recaptcha_tags` call.

Cheers,

  Christoph

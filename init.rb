# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register :recaptcha do
  name 'Recaptcha plugin'
  author 'Christoph Dwertmann'
  description 'Adds a recaptcha to the account registration page'
  version '2.0.0'
  url 'https://github.com/cdwertmann/recaptcha'
  author_url 'https://github.com/cdwertmann'
  requires_redmine :version_or_higher => '6.0.0'
  settings({
     :partial => 'settings/settings',
     :default => {
       'recaptcha_private_key' => '',
       'recaptcha_public_key' => ''
      }
  })
end

# Redmine's plugin loader runs init.rb inside Rails' to_prepare block, so the
# patch is (re)applied after every code reload. RecaptchaPlugin::* is autoloaded
# from the plugin's lib directory and must not be required explicitly.
unless AccountController.include?(RecaptchaPlugin::Patches::AccountControllerPatch)
  AccountController.include RecaptchaPlugin::Patches::AccountControllerPatch
end

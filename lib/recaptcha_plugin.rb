# frozen_string_literal: true

require 'recaptcha'

# Helpers shared by the plugin's controller patch and views.
#
# The file lives in the plugin's `lib` directory, which Redmine 6 registers as
# a Zeitwerk eager load path, so it must not be loaded with `require`/
# `require_relative` from init.rb.
module RecaptchaPlugin
  module_function

  def settings
    Setting.plugin_recaptcha || {}
  end

  def site_key
    settings['recaptcha_public_key'].to_s.strip
  end

  def secret_key
    settings['recaptcha_private_key'].to_s.strip
  end

  def configured?
    site_key.present? && secret_key.present?
  end

  # recaptcha >= 5 ships its Rails integration as Recaptcha::Adapters::*,
  # older releases used Recaptcha::Verify / Recaptcha::ClientHelper.
  def controller_methods
    if defined?(::Recaptcha::Adapters::ControllerMethods)
      ::Recaptcha::Adapters::ControllerMethods
    elsif defined?(::Recaptcha::Verify)
      ::Recaptcha::Verify
    end
  end

  def view_methods
    if defined?(::Recaptcha::Adapters::ViewMethods)
      ::Recaptcha::Adapters::ViewMethods
    elsif defined?(::Recaptcha::ClientHelper)
      ::Recaptcha::ClientHelper
    end
  end
end

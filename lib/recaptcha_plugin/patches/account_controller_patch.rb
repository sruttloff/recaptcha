# frozen_string_literal: true

module RecaptchaPlugin
  module Patches
    # Verifies the captcha in a before_action instead of overriding
    # AccountController#register. The registration logic itself therefore stays
    # Redmine's own and does not have to be kept in sync with core.
    module AccountControllerPatch
      extend ActiveSupport::Concern

      included do
        controller_methods = RecaptchaPlugin.controller_methods
        include controller_methods if controller_methods && !include?(controller_methods)

        view_methods = RecaptchaPlugin.view_methods
        helper view_methods if view_methods

        before_action :recaptcha_plugin_verify_registration, :only => [:register]
      end

      private

      def recaptcha_plugin_verify_registration
        return unless request.post?
        return if session[:auth_source_registration]
        return unless Setting.self_registration?

        unless RecaptchaPlugin.configured?
          Rails.logger.warn('Recaptcha plugin: no key pair configured, skipping captcha verification')
          return
        end

        @user = recaptcha_plugin_new_user
        return if verify_recaptcha(:model => @user, :secret_key => RecaptchaPlugin.secret_key)

        # The failure is already reported on the user object, no need for an
        # additional flash message on top of the form.
        flash.delete(:recaptcha_error)
        no_store
        render :register
      end

      # Rebuilds the submitted user so the registration form can be redisplayed
      # with the entered values and the captcha error.
      def recaptcha_plugin_new_user
        user_params = params[:user] || {}
        user = User.new
        user.safe_attributes = user_params
        user.pref.safe_attributes = params[:pref]
        user.admin = false
        user.register
        unless user_params[:password].blank? && user_params[:password_confirmation].blank?
          user.password, user.password_confirmation =
            user_params[:password], user_params[:password_confirmation]
        end
        user
      end
    end
  end
end

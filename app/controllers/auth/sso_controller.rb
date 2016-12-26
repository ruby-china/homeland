module Auth
  class SSOController < ApplicationController
    def show
      return render_404 if !Setting.sso_enabled?

      destination_url = cookies.delete(:destination_url)
      return_path = params[:return_path] || root_path

      if destination_url && return_path == root_path
        uri = URI::parse(destination_url)
        return_path = "#{uri.path}#{uri.query ? "?" << uri.query : ""}"
      end

      sso = Homeland::SSO.generate_sso(return_path)
      Rails.logger.warn("Verbose SSO log: Started SSO process\n\n#{sso.diagnostics}")
      redirect_to sso.to_url
    end

    def login
      return render_404 if !Setting.sso_enabled?

      sso = Homeland::SSO.parse(request.query_string)
      if !sso.nonce_valid?
        return render(plain: I18n.t("sso.timeout_expired"), status: 419)
      end

      return_path = sso.return_path
      sso.expire_nonce!

      begin
        user = sso.find_or_create_user(request)
        sign_in :user, user
      rescue => e
        message = sso.diagnostics
        message << "\n\n" << "-" * 100 << "\n\n"
        message << e.message
        message << "\n\n" << "-" * 100 << "\n\n"
        message << e.backtrace.join("\n")

        puts message

        ExceptionLog.create(title: "SSO Failed to create or lookup user:", body: message)
        render plain: I18n.t("sso.unknown_error"), status: 500
        return
      end

      if !user
        render plain: I18n.t("sso.not_found"), status: 500
        return
      end

      redirect_to return_path
    end

    def provider
      return render_404 if !Setting.sso_provider_enabled?

      payload ||= request.query_string

      if !current_user
        store_location
        redirect_to new_session_path(:user)
        return
      end

      sso = SingleSignOn.parse(payload, Setting.sso['secret'])
      sso.name = current_user.name
      sso.username = current_user.login
      sso.email = current_user.email
      sso.bio = current_user.bio
      sso.external_id = current_user.id.to_s
      sso.admin = current_user.admin?
      sso.avatar_url = current_user.avatar.url(:lg)

      redirect_to sso.to_url(sso.return_sso_url)
    end
  end
end
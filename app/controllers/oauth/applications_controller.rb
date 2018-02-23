# frozen_string_literal: true

module Oauth
  class ApplicationsController < Doorkeeper::ApplicationsController
    before_action :authenticate_user!
    helper_method :unread_notify_count

    def index
      @applications = current_user.oauth_applications
      @authorized_applications = Doorkeeper::Application.authorized_for(current_user)
      @devices = current_user.devices.all
    end

    # only needed if each application must have some owner
    def create
      @application       = Doorkeeper::Application.new(application_params)
      @application.uid   = SecureRandom.hex(4)
      @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?

      if @application.save
        flash[:notice] = I18n.t(:notice, scope: %i[doorkeeper flash applications create])
        redirect_to oauth_application_url(@application)
      else
        render :new
      end
    end

    def unread_notify_count
      return 0 if current_user.blank?
      @unread_notify_count ||= Notification.unread_count(current_user)
    end
  end
end

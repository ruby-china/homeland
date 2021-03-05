# frozen_string_literal: true

module Oauth
  class ApplicationsController < Doorkeeper::ApplicationsController
    before_action :authenticate_user!
    include Homeland::UserNotificationHelper

    before_action :set_application, only: %i[show edit update destroy]

    def index
      @applications = current_user.oauth_applications
      @authorized_applications = Doorkeeper::Application.authorized_for(current_user)
      @devices = current_user.devices.all
    end

    def show
      respond_to do |format|
        format.html
        format.json { render json: @application }
      end
    end

    def new
      @application = Doorkeeper::Application.new
    end

    # only needed if each application must have some owner
    def create
      @application = Doorkeeper::Application.new(application_params)
      @application.uid = SecureRandom.hex(4)
      @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?

      if @application.save
        flash[:notice] = I18n.t(:notice, scope: %i[doorkeeper flash applications create])
        redirect_to oauth_application_url(@application)
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @application.update(application_params)
        flash[:notice] = I18n.t(:notice, scope: %i[doorkeeper flash applications update])

        respond_to do |format|
          format.html { redirect_to oauth_application_url(@application) }
          format.json { render json: @application }
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: {errors: @application.errors.full_messages}, status: :unprocessable_entity }
        end
      end
    end

    def set_application
      @application = current_user.oauth_applications.find(params[:id])
    end
  end
end
